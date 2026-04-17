import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from '../../entities/user.entity';
import { AuthorApplication } from '../../entities/user.entity';
import { Book, BookStatus } from '../../entities/book.entity';
import { Order, Withdrawal } from '../../entities/payment.entity';
import { ReviewTask, ReviewStatus, Report } from '../../entities/review.entity';
import { VipSubscription } from '../../entities/vip.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(AuthorApplication)
    private authorApplicationRepository: Repository<AuthorApplication>,
    @InjectRepository(Book)
    private bookRepository: Repository<Book>,
    @InjectRepository(Order)
    private orderRepository: Repository<Order>,
    @InjectRepository(Withdrawal)
    private withdrawalRepository: Repository<Withdrawal>,
    @InjectRepository(ReviewTask)
    private reviewTaskRepository: Repository<ReviewTask>,
    @InjectRepository(Report)
    private reportRepository: Repository<Report>,
    @InjectRepository(VipSubscription)
    private vipSubscriptionRepository: Repository<VipSubscription>,
  ) {}

  // 用户管理
  async getUsers(page: number = 1, pageSize: number = 20, role?: UserRole) {
    const where: any = {};
    if (role) where.role = role;

    const [users, total] = await this.userRepository.findAndCount({
      where,
      select: ['id', 'email', 'username', 'avatar', 'role', 'isActive', 'createdAt', 'balance'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return { list: users, pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) } };
  }

  async updateUserRole(userId: string, role: UserRole) {
    await this.userRepository.update(userId, { role });
    return { message: '用户角色已更新' };
  }

  async toggleUserStatus(userId: string) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('用户不存在');

    user.isActive = !user.isActive;
    await this.userRepository.save(user);
    return { message: user.isActive ? '用户已启用' : '用户已禁用' };
  }

  // 作者申请管理
  async getAuthorApplications(page: number = 1, pageSize: number = 20, status?: string) {
    const where: any = {};
    if (status) where.status = status;

    const [applications, total] = await this.authorApplicationRepository.findAndCount({
      where,
      relations: ['user'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return { list: applications, pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) } };
  }

  async reviewAuthorApplication(applicationId: string, action: 'approve' | 'reject', reviewerId: string, note?: string) {
    const application = await this.authorApplicationRepository.findOne({ where: { id: applicationId } });
    if (!application) throw new NotFoundException('申请不存在');

    application.status = action === 'approve' ? 'approved' : 'rejected';
    application.reviewedBy = reviewerId;
    application.reviewedAt = new Date();
    application.reviewNote = note;

    await this.authorApplicationRepository.save(application);

    if (action === 'approve') {
      await this.userRepository.update(application.userId, { role: UserRole.AUTHOR });
    }

    return { message: action === 'approve' ? '已通过申请' : '已拒绝申请' };
  }

  // 书籍管理
  async getBooks(page: number = 1, pageSize: number = 20, status?: BookStatus) {
    const where: any = {};
    if (status) where.status = status;

    const [books, total] = await this.bookRepository.findAndCount({
      where,
      relations: ['author'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return { list: books, pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) } };
  }

  async toggleBookStatus(bookId: string) {
    const book = await this.bookRepository.findOne({ where: { id: bookId } });
    if (!book) throw new NotFoundException('书籍不存在');

    book.status = book.status === BookStatus.PUBLISHED ? BookStatus.OFFLINE : BookStatus.PUBLISHED;
    await this.bookRepository.save(book);
    return { message: '书籍状态已更新' };
  }

  // 订单管理
  async getOrders(page: number = 1, pageSize: number = 20, status?: string) {
    const where: any = {};
    if (status) where.status = status;

    const [orders, total] = await this.orderRepository.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return { list: orders, pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) } };
  }

  // 提现管理
  async getWithdrawals(page: number = 1, pageSize: number = 20, status?: string) {
    const where: any = {};
    if (status) where.status = status;

    const [withdrawals, total] = await this.withdrawalRepository.findAndCount({
      where,
      relations: ['user'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return { list: withdrawals, pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) } };
  }

  async processWithdrawal(withdrawalId: string, action: 'approve' | 'reject', adminId: string, note?: string) {
    const withdrawal = await this.withdrawalRepository.findOne({ where: { id: withdrawalId } });
    if (!withdrawal) throw new NotFoundException('提现申请不存在');

    if (action === 'approve') {
      withdrawal.status = 'completed';
      withdrawal.processedBy = adminId;
      withdrawal.processedAt = new Date();
    } else {
      withdrawal.status = 'rejected';
      withdrawal.rejectReason = note;
      withdrawal.processedBy = adminId;
      withdrawal.processedAt = new Date();

      // 解冻金额
      // TODO: 实现解冻逻辑
    }

    await this.withdrawalRepository.save(withdrawal);
    return { message: action === 'approve' ? '提现已通过' : '提现已拒绝' };
  }

  // 举报管理
  async getReports(page: number = 1, pageSize: number = 20, status?: string) {
    const where: any = {};
    if (status) where.status = status;

    const [reports, total] = await this.reportRepository.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return { list: reports, pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) } };
  }

  async handleReport(reportId: string, action: 'resolve' | 'dismiss', adminId: string, note?: string) {
    await this.reportRepository.update(reportId, {
      status: action === 'resolve' ? 'resolved' : 'dismissed',
      handledBy: adminId,
      handleNote: note,
      handledAt: new Date(),
    });
    return { message: '处理完成' };
  }

  // 统计报表
  async getDashboardStats() {
    const [
      totalUsers,
      totalAuthors,
      totalBooks,
      totalOrders,
      pendingWithdrawals,
      pendingReports,
      activeVips,
    ] = await Promise.all([
      this.userRepository.count(),
      this.userRepository.count({ where: { role: UserRole.AUTHOR } }),
      this.bookRepository.count({ where: { status: BookStatus.PUBLISHED } }),
      this.orderRepository.count({ where: { status: 'completed' } }),
      this.withdrawalRepository.count({ where: { status: 'pending' } }),
      this.reportRepository.count({ where: { status: 'pending' } }),
      this.vipSubscriptionRepository.count({ where: { status: 'active' } }),
    ]);

    const revenue = await this.orderRepository
      .createQueryBuilder('order')
      .where('order.status = :status', { status: 'completed' })
      .select('SUM(order.amount)', 'total')
      .getRawOne();

    return {
      totalUsers,
      totalAuthors,
      totalBooks,
      totalOrders,
      totalRevenue: parseFloat(revenue?.total || '0'),
      pendingWithdrawals,
      pendingReports,
      activeVips,
    };
  }

  async getRevenueStats(startDate?: Date, endDate?: Date) {
    const query = this.orderRepository
      .createQueryBuilder('order')
      .where('order.status = :status', { status: 'completed' });

    if (startDate) query.andWhere('order.createdAt >= :startDate', { startDate });
    if (endDate) query.andWhere('order.createdAt <= :endDate', { endDate });

    const result = await query
      .select([
        'SUM(order.amount) as total',
        'COUNT(*) as count',
        'DATE(order.createdAt) as date',
      ])
      .groupBy('DATE(order.createdAt)')
      .orderBy('date', 'DESC')
      .limit(30)
      .getRawMany();

    return result;
  }
}
