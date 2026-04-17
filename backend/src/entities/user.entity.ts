import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  Index,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { UserRole } from '../common/constants';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  @Index()
  email: string;

  @Column({ nullable: true })
  @Index()
  phone: string;

  @Column()
  @Exclude()
  password: string;

  @Column({ nullable: true })
  @Exclude()
  passwordSalt: string;

  @Column({ nullable: true })
  username: string;

  @Column({ nullable: true })
  avatar: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.USER })
  role: UserRole;

  @Column({ default: false })
  isEmailVerified: boolean;

  @Column({ default: false })
  isPhoneVerified: boolean;

  @Column({ default: false })
  isRealNameVerified: boolean;

  @Column({ nullable: true })
  realName: string;

  @Column({ nullable: true })
  idCardNumber: string;

  @Column({ nullable: true })
  idCardFront: string;

  @Column({ nullable: true })
  idCardBack: string;

  @Column({ nullable: true })
  inviteCode: string;

  @Column({ nullable: true })
  @Index()
  invitedBy: string;

  @Column({ nullable: true })
  bio: string;

  @Column({ nullable: true })
  birthday: Date;

  @Column({ nullable: true })
  gender: 'male' | 'female' | 'other';

  @Column({ nullable: true })
  language: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  balance: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  totalRecharge: number;

  @Column({ nullable: true })
  lastLoginAt: Date;

  @Column({ nullable: true })
  lastLoginIp: string;

  @Column({ default: true })
  isActive: boolean;

  @Column({ nullable: true })
  @Exclude()
  refreshToken: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  @Exclude()
  deletedAt: Date;
}

@Entity('user_profiles')
export class UserProfile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column({ nullable: true })
  displayName: string;

  @Column({ nullable: true })
  bio: string;

  @Column({ nullable: true })
  website: string;

  @Column({ nullable: true })
  socialLinks: string; // JSON string

  @Column({ nullable: true })
  timezone: string;

  @Column({ nullable: true })
  country: string;

  @Column({ nullable: true })
  city: string;

  @Column({ type: 'jsonb', nullable: true })
  preferences: Record<string, any>; // 用户偏好设置

  @Column({ type: 'jsonb', nullable: true })
  readingStats: {
    totalBooks: number;
    totalChapters: number;
    totalReadingTime: number;
    favoriteGenres: string[];
  };

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('author_applications')
export class AuthorApplication {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  penName: string;

  @Column({ nullable: true })
  avatar: string;

  @Column({ nullable: true })
  bio: string;

  @Column({ nullable: true })
  idCardNumber: string;

  @Column({ nullable: true })
  idCardFront: string;

  @Column({ nullable: true })
  idCardBack: string;

  @Column({ nullable: true })
  writingExperience: string;

  @Column({ nullable: true })
  previousWorks: string; // JSON array of previous works

  @Column({ type: 'enum', enum: ['pending', 'approved', 'rejected'], default: 'pending' })
  status: string;

  @Column({ nullable: true })
  reviewNote: string;

  @Column({ nullable: true })
  reviewedBy: string;

  @Column({ nullable: true })
  reviewedAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
