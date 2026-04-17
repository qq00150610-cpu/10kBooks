import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
  Index,
} from 'typeorm';

export enum VipLevel {
  NONE = 0,
  MONTHLY = 1,
  QUARTERLY = 2,
  YEARLY = 3,
  LIFETIME = 4,
}

@Entity('vip_packages')
export class VipPackage {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  level: number;

  @Column()
  name: string;

  @Column({ nullable: true })
  nameEn: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number;

  @Column({ nullable: true })
  originalPrice: number;

  @Column()
  duration: number; // 天数

  @Column({ nullable: true })
  description: string;

  @Column({ nullable: true })
  features: string; // JSON array

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: 0 })
  sortOrder: number;

  @Column({ nullable: true })
  tag: string; // 推荐标签

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('vip_subscriptions')
export class VipSubscription {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  packageId: string;

  @Column({ type: 'enum', enum: VipLevel })
  level: VipLevel;

  @Column()
  startDate: Date;

  @Column()
  endDate: Date;

  @Column({ type: 'enum', enum: ['active', 'expired', 'cancelled'], default: 'active' })
  status: string;

  @Column({ nullable: true })
  autoRenew: boolean;

  @Column({ nullable: true })
  subscriptionId: string; // 第三方订阅ID

  @Column({ nullable: true })
  cancelledAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('vip_privileges')
export class VipPrivilege {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  nameEn: string;

  @Column({ nullable: true })
  description: string;

  @Column({ nullable: true })
  icon: string;

  @Column({ type: 'jsonb', nullable: true })
  applicableLevels: number[]; // 适用的VIP等级

  @Column({ type: 'jsonb', nullable: true })
  config: Record<string, any>; // 配置参数

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: 0 })
  sortOrder: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('vip_benefits_log')
export class VipBenefitLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  subscriptionId: string;

  @Column()
  benefitId: string;

  @Column({ nullable: true })
  bookId: string;

  @Column({ nullable: true })
  chapterId: string;

  @Column({ nullable: true })
  orderId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  value: number;

  @CreateDateColumn()
  createdAt: Date;
}
