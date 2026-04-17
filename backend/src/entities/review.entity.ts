import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';

export enum ReviewType {
  BOOK = 'book',
  CHAPTER = 'chapter',
  COMMENT = 'comment',
  USER_REPORT = 'user_report',
  COPYRIGHT = 'copyright',
}

export enum ReviewStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  AUTO_APPROVED = 'auto_approved',
  NEED_MANUAL = 'need_manual',
}

@Entity('review_tasks')
export class ReviewTask {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'enum', enum: ReviewType })
  reviewType: ReviewType;

  @Column()
  @Index()
  targetId: string;

  @Column({ nullable: true })
  @Index()
  bookId: string;

  @Column()
  @Index()
  reviewerId: string; // 提交者ID

  @Column({ nullable: true })
  assignedTo: string; // 分配的审核员ID

  @Column({ type: 'enum', enum: ReviewStatus, default: ReviewStatus.PENDING })
  @Index()
  status: ReviewStatus;

  @Column({ nullable: true })
  autoCheckResult: string; // JSON: 敏感词检测结果

  @Column({ nullable: true })
  copyrightCheckResult: string; // JSON: 版权检测结果

  @Column({ nullable: true })
  reviewNote: string;

  @Column({ nullable: true })
  reviewedBy: string;

  @Column({ nullable: true })
  reviewedAt: Date;

  @Column({ nullable: true })
  reviewDuration: number; // 审核时长（秒）

  @Column({ default: 0 })
  priority: number; // 优先级

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('sensitive_words')
export class SensitiveWord {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  word: string;

  @Column()
  level: number; // 1-5, 严重程度

  @Column({ nullable: true })
  category: string; // politics, porn, violence, etc.

  @Column({ nullable: true })
  replacement: string;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('review_logs')
export class ReviewLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  taskId: string;

  @Column()
  @Index()
  reviewerId: string;

  @Column()
  action: string; // approve, reject, request_modify

  @Column({ nullable: true })
  reason: string;

  @Column({ nullable: true })
  previousStatus: string;

  @Column({ nullable: true })
  newStatus: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('copyright_checks')
export class CopyrightCheck {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  author: string;

  @Column({ nullable: true })
  title: string;

  @Column({ nullable: true })
  isbn: string;

  @Column({ nullable: true })
  publisher: string;

  @Column({ nullable: true })
  externalCheckResult: string; // JSON

  @Column({ nullable: true })
  similarity: number; // 相似度 0-100

  @Column({ nullable: true })
  similarBooks: string; // JSON array

  @Column({ nullable: true })
  checkReport: string; // 检查报告URL

  @Column({ default: false })
  hasRisk: boolean;

  @Column({ nullable: true })
  riskLevel: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('reports')
export class Report {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  reporterId: string;

  @Column()
  @Index()
  reportedUserId: string;

  @Column({ nullable: true })
  @Index()
  bookId: string;

  @Column({ nullable: true })
  @Index()
  commentId: string;

  @Column()
  reason: string;

  @Column({ nullable: true })
  description: string;

  @Column({ nullable: true })
  evidence: string; // JSON array of URLs

  @Column({ type: 'enum', enum: ['pending', 'reviewed', 'resolved', 'dismissed'], default: 'pending' })
  status: string;

  @Column({ nullable: true })
  handledBy: string;

  @Column({ nullable: true })
  handleNote: string;

  @Column({ nullable: true })
  handledAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
