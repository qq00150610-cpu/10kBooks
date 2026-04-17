import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { Order, UserBalance, Withdrawal, AuthorEarning, Coupon, UserCoupon, OrderType, OrderStatus, PaymentChannel } from '../../entities/payment.entity';
import { User } from '../../entities/user.entity';
import { Book, Chapter } from '../../entities/book.entity';
import { CodeUtil, PriceUtil } from '../../common/utils';
import { QueueNames, PLATFORM_COMMISSION_RATE } from '../../common/constants';
import { IsOptional, IsString, IsNumber, IsEnum } from 'class-validator';

export class CreateOrderDto {
  @IsEnum(OrderType)
  orderType: OrderType;

  @IsOptional()
  @IsString()
  targetId?: string;

  @IsOptional()
  @IsNumber()
  amount?: number;

  @IsEnum(PaymentChannel)
  paymentChannel: PaymentChannel;

  @IsOptional()
  @IsString()
  couponCode?: string;
}

export class WithdrawalDto {
  @IsNumber()
  amount: number;

  @IsString()
  paymentMethod: string;

  @IsString()
  bankAccount: string;

  @IsOptional()
  @IsString()
  bankAccountName?: string;
}

@Injectable()
export class PaymentService {
  constructor(
    @InjectRepository(Order)
    private orderRepository: Repository<Order>,
    @InjectRepository(UserBalance)
    private balanceRepository: Repository<UserBalance>,
    @InjectRepository(Withdrawal)
    private withdrawalRepository: Repository<Withdrawal>,
    @InjectRepository(AuthorEarning)
    private earningRepository: Repository<AuthorEarning>,
    @InjectRepository(Coupon)
    private couponRepository: Repository<Coupon>,
    @InjectRepository(UserCoupon)
    private userCouponRepository: Repository<UserCoupon>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Book)
    private bookRepository: Repository<Book>,
    @InjectRepository(Chapter)
    private chapterRepository: Repository<Chapter>,
    private configService: ConfigService,
    @InjectQueue(QueueNames.PAYMENT_PROCESSING)
    private paymentQueue: Queue,
  ) {}

  async createOrder(userId: string, dto: CreateOrderDto) {
    let amount = dto.amount || 0;

    // 计算订单金额
    if (dto.orderType === OrderType.PURCHASE_CHAPTER && dto.targetId) {
      const chapter = await this.chapterRepository.findOne({ where: { id: dto.targetId } });
      if (!chapter) throw new NotFoundException('章节不存在');
      amount = chapter.price;
    } else if (dto.orderType === OrderType.PURCHASE_BOOK && dto.targetId) {
      const book = await this.bookRepository.findOne({ where: { id: dto.targetId } });
      if (!book) throw new NotFoundException('书籍不存在');
      amount = book.fullBookPrice;
    } else if (dto.orderType === OrderType.RECHARGE && dto.amount) {
      amount = dto.amount;
    }

    // 检查优惠券
    let discountAmount = 0;
    let couponId: string | null = null;
    if (dto.couponCode) {
      const coupon = await this.useCoupon(userId, dto.couponCode, amount);
      if (coupon) {
        discountAmount = coupon;
        couponId = dto.couponCode;
      }
    }

    const platformFee = PriceUtil.calculateCommission(amount);
    const finalAmount = Math.max(0, amount - discountAmount);

    const order = this.orderRepository.create({
      orderNo: CodeUtil.generateOrderNo(),
      userId,
      orderType: dto.orderType,
      amount: finalAmount,
      originalAmount: amount,
      paymentChannel: dto.paymentChannel,
      platformFee,
      couponId,
      discountAmount,
    });

    await this.orderRepository.save(order);

    return {
      orderId: order.id,
      orderNo: order.orderNo,
      amount: finalAmount,
      originalAmount: amount,
      discountAmount,
    };
  }

  async processPayment(userId: string, orderId: string, paymentData: any) {
    const order = await this.orderRepository.findOne({
      where: { id: orderId, userId },
    });

    if (!order) throw new NotFoundException('订单不存在');
    if (order.status !== OrderStatus.PENDING) throw new BadRequestException('订单已处理');

    order.status = OrderStatus.PROCESSING;
    await this.orderRepository.save(order);

    // 根据支付渠道处理
    try {
      switch (order.paymentChannel) {
        case PaymentChannel.STRIPE:
          await this.processStripePayment(order, paymentData);
          break;
        case PaymentChannel.PAYPAL:
          await this.processPayPalPayment(order, paymentData);
          break;
        case PaymentChannel.BALANCE:
          await this.processBalancePayment(order);
          break;
      }

      order.status = OrderStatus.COMPLETED;
      order.paymentTime = new Date();
      await this.orderRepository.save(order);

      // 更新用户余额
      if (order.orderType === OrderType.RECHARGE) {
        await this.updateUserBalance(userId, order.amount);
      }

      // 处理作者收益
      if ([OrderType.PURCHASE_CHAPTER, OrderType.PURCHASE_BOOK].includes(order.orderType)) {
        await this.distributeEarnings(order);
      }

      return { message: '支付成功', order };
    } catch (error) {
      order.status = OrderStatus.FAILED;
      await this.orderRepository.save(order);
      throw error;
    }
  }

  async getOrderDetail(userId: string, orderId: string) {
    return this.orderRepository.findOne({ where: { id: orderId, userId } });
  }

  async getMyOrders(userId: string, page: number = 1, pageSize: number = 20, status?: OrderStatus) {
    const where: any = { userId };
    if (status) where.status = status;

    const [orders, total] = await this.orderRepository.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return {
      list: orders,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async getBalance(userId: string) {
    let balance = await this.balanceRepository.findOne({ where: { userId } });
    if (!balance) {
      balance = this.balanceRepository.create({ userId, balance: 0 });
      await this.balanceRepository.save(balance);
    }
    return balance;
  }

  async getTransactionHistory(userId: string, page: number = 1, pageSize: number = 20) {
    return this.orderRepository.find({
      where: { userId, status: OrderStatus.COMPLETED },
      order: { paymentTime: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
  }

  async applyWithdrawal(userId: string, dto: WithdrawalDto) {
    const balance = await this.getBalance(userId);

    if (balance.balance < dto.amount) {
      throw new BadRequestException('余额不足');
    }

    const withdrawal = this.withdrawalRepository.create({
      userId,
      amount: dto.amount,
      paymentMethod: dto.paymentMethod,
      bankAccount: dto.bankAccount,
      bankAccountName: dto.bankAccountName,
    });

    await this.withdrawalRepository.save(withdrawal);

    // 冻结金额
    await this.balanceRepository.update({ userId }, { frozenBalance: balance.frozenBalance + dto.amount });

    return withdrawal;
  }

  async getWithdrawals(userId: string, page: number = 1, pageSize: number = 20) {
    const [withdrawals, total] = await this.withdrawalRepository.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return {
      list: withdrawals,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async getEarnings(userId: string, page: number = 1, pageSize: number = 20) {
    const [earnings, total] = await this.earningRepository.findAndCount({
      where: { authorId: userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const stats = await this.earningRepository
      .createQueryBuilder('e')
      .where('e.authorId = :userId', { userId })
      .select([
        'SUM(e.revenue) as totalRevenue',
        'SUM(e.authorAmount) as totalEarning',
        'SUM(e.withdrawalAmount) as totalWithdrawn',
      ])
      .getRawOne();

    return {
      list: earnings,
      stats: {
        totalRevenue: parseFloat(stats?.totalRevenue || '0'),
        totalEarning: parseFloat(stats?.totalEarning || '0'),
        totalWithdrawn: parseFloat(stats?.totalWithdrawn || '0'),
        pendingSettlement: parseFloat(stats?.totalEarning || '0') - parseFloat(stats?.totalWithdrawn || '0'),
      },
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async getCoupons(userId: string) {
    return this.userCouponRepository.find({
      where: { userId, isUsed: false },
      relations: ['coupon'],
      order: { validUntil: 'ASC' },
    });
  }

  async claimCoupon(userId: string, couponCode: string) {
    const coupon = await this.couponRepository.findOne({
      where: { code: couponCode, isActive: true },
    });

    if (!coupon) throw new NotFoundException('优惠券不存在');
    if (coupon.usedCount >= coupon.totalCount) throw new BadRequestException('优惠券已领完');
    if (new Date() > coupon.validUntil) throw new BadRequestException('优惠券已过期');

    const existing = await this.userCouponRepository.findOne({
      where: { userId, couponId: coupon.id },
    });

    if (existing) throw new BadRequestException('已领取过该优惠券');

    const userCoupon = this.userCouponRepository.create({
      userId,
      couponId: coupon.id,
      validUntil: coupon.validUntil,
    });

    await this.userCouponRepository.save(userCoupon);
    await this.couponRepository.increment({ id: coupon.id }, 'usedCount', 1);

    return { message: '领取成功' };
  }

  private async useCoupon(userId: string, couponCode: string, orderAmount: number): Promise<number> {
    const coupon = await this.couponRepository.findOne({
      where: { code: couponCode, isActive: true },
    });

    if (!coupon) return 0;
    if (coupon.minAmount && orderAmount < coupon.minAmount) return 0;
    if (new Date() > coupon.validUntil) return 0;

    const userCoupon = await this.userCouponRepository.findOne({
      where: { userId, couponId: coupon.id, isUsed: false },
    });

    if (!userCoupon) return 0;

    let discount = 0;
    if (coupon.type === 'fixed') {
      discount = coupon.value;
    } else if (coupon.type === 'percentage') {
      discount = orderAmount * (coupon.value / 100);
      if (coupon.maxDiscount) discount = Math.min(discount, coupon.maxDiscount);
    }

    return Math.min(discount, orderAmount);
  }

  private async processStripePayment(order: Order, paymentData: any) {
    // TODO: 调用Stripe API
    // const stripe = new Stripe(this.configService.get('STRIPE_SECRET_KEY'));
    // const paymentIntent = await stripe.paymentIntents.create({...});
    order.paymentId = `stripe_${Date.now()}`;
  }

  private async processPayPalPayment(order: Order, paymentData: any) {
    // TODO: 调用PayPal API
    order.paymentId = `paypal_${Date.now()}`;
  }

  private async processBalancePayment(order: Order) {
    const balance = await this.getBalance(order.userId);
    if (balance.balance < order.amount) {
      throw new BadRequestException('余额不足');
    }

    await this.balanceRepository.update(
      { userId: order.userId },
      { balance: balance.balance - order.amount },
    );

    order.paymentId = `balance_${Date.now()}`;
  }

  private async updateUserBalance(userId: string, amount: number) {
    let balance = await this.balanceRepository.findOne({ where: { userId } });
    if (!balance) {
      balance = this.balanceRepository.create({ userId });
      await this.balanceRepository.save(balance);
    }

    balance.balance += amount;
    balance.totalRecharge += amount;
    await this.balanceRepository.save(balance);

    await this.userRepository.update(userId, { balance: balance.balance });
  }

  private async distributeEarnings(order: Order) {
    let authorId: string;
    let bookId = order.targetId;

    if (order.orderType === OrderType.PURCHASE_CHAPTER) {
      const chapter = await this.chapterRepository.findOne({ where: { id: order.targetId } });
      authorId = chapter.authorId;
      bookId = chapter.bookId;
    } else {
      const book = await this.bookRepository.findOne({ where: { id: order.targetId } });
      authorId = book.authorId;
    }

    const revenue = order.amount;
    const platformFee = PriceUtil.calculateCommission(revenue, PLATFORM_COMMISSION_RATE);
    const authorAmount = revenue - platformFee;

    const earning = this.earningRepository.create({
      authorId,
      bookId,
      orderId: order.id,
      revenue,
      platformFee,
      authorAmount,
    });

    await this.earningRepository.save(earning);
  }
}
