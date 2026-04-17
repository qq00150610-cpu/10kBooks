import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToOne,
  JoinColumn,
  Index,
} from 'typeorm';

export enum OrderType {
  RECHARGE = 'recharge',
  PURCHASE_CHAPTER = 'purchase_chapter',
  PURCHASE_BOOK = 'purchase_book',
  VIP_SUBSCRIBE = 'vip_subscribe',
  VIP_RENEW = 'vip_renew',
  AUTHOR_WITHDRAW = 'author_withdraw',
  PLATFORM_REWARD = 'platform_reward',
}

export enum OrderStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
}

export enum PaymentChannel {
  STRIPE = 'stripe',
  PAYPAL = 'paypal',
  ALIPAY = 'alipay',
  WECHAT = 'wechat',
  BALANCE = 'balance',
}

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  orderNo: string;

  @Column()
  @Index()
  userId: string;

  @Column({ type: 'enum', enum: OrderType })
  orderType: OrderType;

  @Column({ type: 'enum', enum: OrderStatus, default: OrderStatus.PENDING })
  @Index()
  status: OrderStatus;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  originalAmount: number;

  @Column({ nullable: true })
  currency: string; // CNY, USD

  @Column({ type: 'enum', enum: PaymentChannel })
  paymentChannel: PaymentChannel;

  @Column({ nullable: true })
  paymentId: string; // 第三方支付ID

  @Column({ nullable: true })
  paymentTime: Date;

  @Column({ nullable: true })
  targetId: string; // 关联的书籍/章节/VIP订单ID

  @Column({ nullable: true })
  targetInfo: string; // JSON

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  platformFee: number; // 平台手续费

  @Column({ nullable: true })
  couponId: string;

  @Column({ nullable: true })
  discountAmount: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ nullable: true })
  ipAddress: string;

  @Column({ nullable: true })
  userAgent: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('user_balances')
export class UserBalance {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  @Index()
  userId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  balance: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  frozenBalance: number; // 冻结金额

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  totalRecharge: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  totalWithdraw: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  totalEarning: number;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('withdrawals')
export class Withdrawal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  amount: number;

  @Column({ nullable: true })
  bankName: string;

  @Column({ nullable: true })
  bankAccount: string;

  @Column({ nullable: true })
  bankAccountName: string;

  @Column({ nullable: true })
  paymentMethod: string; // bank, alipay, wechat

  @Column({ nullable: true })
  paymentInfo: string; // JSON

  @Column({ type: 'enum', enum: ['pending', 'processing', 'completed', 'rejected'], default: 'pending' })
  status: string;

  @Column({ nullable: true })
  rejectReason: string;

  @Column({ nullable: true })
  processedBy: string;

  @Column({ nullable: true })
  processedAt: Date;

  @Column({ nullable: true })
  transactionId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('author_earnings')
export class AuthorEarning {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  authorId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  chapterId: string;

  @Column()
  orderId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  revenue: number; // 收入金额

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  platformFee: number; // 平台抽成

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  authorAmount: number; // 作者实际所得

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  withdrawalAmount: number; // 已提现金额

  @Column({ type: 'enum', enum: ['pending', 'settled', 'withdrawn'], default: 'pending' })
  status: string;

  @Column({ nullable: true })
  settledAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('coupons')
export class Coupon {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  code: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  description: string;

  @Column({ type: 'enum', enum: ['fixed', 'percentage'] })
  type: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  value: number; // 优惠金额或折扣

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  minAmount: number; // 最低消费金额

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  maxDiscount: number; // 最高优惠金额

  @Column()
  totalCount: number;

  @Column()
  usedCount: number;

  @Column()
  perUserLimit: number;

  @Column()
  validFrom: Date;

  @Column()
  validUntil: Date;

  @Column({ nullable: true })
  applicableBooks: string; // JSON array

  @Column({ nullable: true })
  applicableCategories: string; // JSON array

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('user_coupons')
export class UserCoupon {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  couponId: string;

  @ManyToOne(() => Coupon)
  @JoinColumn({ name: 'couponId' })
  coupon: Coupon;

  @Column({ nullable: true })
  orderId: string;

  @Column({ default: false })
  isUsed: boolean;

  @Column({ nullable: true })
  usedAt: Date;

  @Column({ nullable: true })
  validUntil: Date;

  @CreateDateColumn()
  createdAt: Date;
}
