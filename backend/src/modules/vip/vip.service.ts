import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { VipPackage, VipSubscription, VipPrivilege, VipLevel } from '../../entities/vip.entity';
import { User } from '../../entities/user.entity';
import { UserRole } from '../../common/constants';
import { DateUtil } from '../../common/utils';

@Injectable()
export class VipService {
  constructor(
    @InjectRepository(VipPackage)
    private packageRepository: Repository<VipPackage>,
    @InjectRepository(VipSubscription)
    private subscriptionRepository: Repository<VipSubscription>,
    @InjectRepository(VipPrivilege)
    private privilegeRepository: Repository<VipPrivilege>,
    @InjectRepository(VipBenefitLog)
    private benefitLogRepository: Repository<VipBenefitLog>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private configService: ConfigService,
  ) {}

  async getVipPackages() {
    return this.packageRepository.find({
      where: { isActive: true },
      order: { sortOrder: 'ASC' },
    });
  }

  async getMyVipStatus(userId: string) {
    const subscription = await this.subscriptionRepository.findOne({
      where: { userId, status: 'active' },
      relations: ['package'],
    });

    const privileges = await this.privilegeRepository.find({
      where: { isActive: true },
      order: { sortOrder: 'ASC' },
    });

    return {
      isVip: !!subscription && new Date(subscription.endDate) > new Date(),
      level: subscription?.level || 0,
      startDate: subscription?.startDate,
      endDate: subscription?.endDate,
      autoRenew: subscription?.autoRenew || false,
      privileges: subscription ? privileges.filter(p => 
        !p.applicableLevels || p.applicableLevels.includes(subscription.level)
      ) : [],
    };
  }

  async subscribe(userId: string, packageId: string, paymentData?: any) {
    const pkg = await this.packageRepository.findOne({ where: { id: packageId, isActive: true } });
    if (!pkg) throw new NotFoundException('VIP套餐不存在');

    // 检查现有订阅
    const existing = await this.subscriptionRepository.findOne({
      where: { userId, status: 'active' },
    });

    const now = new Date();
    let startDate = now;
    let endDate: Date;

    if (existing && existing.level === pkg.level) {
      // 续费
      startDate = new Date(existing.endDate);
      endDate = DateUtil.addDays(startDate, pkg.duration);
      existing.endDate = endDate;
      existing.status = 'active';
      await this.subscriptionRepository.save(existing);
    } else {
      // 新订阅
      endDate = DateUtil.addDays(now, pkg.duration);
      const subscription = this.subscriptionRepository.create({
        userId,
        packageId: pkg.id,
        level: pkg.level,
        startDate: now,
        endDate,
        status: 'active',
      });
      await this.subscriptionRepository.save(subscription);
    }

    // 更新用户角色
    await this.userRepository.update(userId, { role: UserRole.VIP });

    // TODO: 处理支付

    return { message: '订阅成功', endDate };
  }

  async cancelAutoRenew(userId: string) {
    await this.subscriptionRepository.update(
      { userId, status: 'active' },
      { autoRenew: false },
    );
    return { message: '已取消自动续费' };
  }

  async checkVipAccess(userId: string): Promise<boolean> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { userId, status: 'active' },
    });

    if (!subscription) return false;
    return new Date(subscription.endDate) > new Date();
  }

  async checkPrivilege(userId: string, privilegeKey: string): Promise<boolean> {
    const hasVip = await this.checkVipAccess(userId);
    if (!hasVip) return false;

    const subscription = await this.subscriptionRepository.findOne({
      where: { userId, status: 'active' },
    });

    const privilege = await this.privilegeRepository.findOne({
      where: { name: privilegeKey, isActive: true },
    });

    if (!privilege) return true; // 权限不存在则默认允许
    if (!privilege.applicableLevels) return true;

    return privilege.applicableLevels.includes(subscription.level);
  }

  async logBenefitUsage(userId: string, subscriptionId: string, benefitId: string, value?: number) {
    const log = this.benefitLogRepository.create({
      userId,
      subscriptionId,
      benefitId,
      value,
    });
    await this.benefitLogRepository.save(log);
  }

  async getBenefitLogs(userId: string, page: number = 1, pageSize: number = 20) {
    const [logs, total] = await this.benefitLogRepository.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return {
      list: logs,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async handleExpiredSubscriptions() {
    const expired = await this.subscriptionRepository.find({
      where: { status: 'active', endDate: new Date() },
    });

    for (const sub of expired) {
      sub.status = 'expired';
      await this.subscriptionRepository.save(sub);

      // 检查是否有更低级别的有效订阅
      const lowerSub = await this.subscriptionRepository.findOne({
        where: { userId: sub.userId, status: 'active', level: LessThanOrEqual(sub.level) },
        order: { level: 'DESC' },
      });

      const user = await this.userRepository.findOne({ where: { id: sub.userId } });
      if (user) {
        user.role = lowerSub ? UserRole.VIP : UserRole.USER;
        await this.userRepository.save(user);
      }
    }
  }
}

function LessThanOrEqual(value: number) {
  return value;
}
