import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';

export enum NotificationType {
  SYSTEM = 'system',
  BOOK_UPDATE = 'book_update',
  COMMENT_REPLY = 'comment_reply',
  FOLLOW = 'follow',
  VIP_EXPIRE = 'vip_expire',
  PAYMENT = 'payment',
  REVIEW_RESULT = 'review_result',
  REVIEW_REMINDER = 'review_reminder',
  AUTHOR_APPLICATION = 'author_application',
  WITHDRAWAL = 'withdrawal',
}

export enum NotificationStatus {
  UNREAD = 'unread',
  READ = 'read',
  DELETED = 'deleted',
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column({ type: 'enum', enum: NotificationType })
  type: NotificationType;

  @Column()
  title: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  @Index()
  relatedId: string; // 关联ID

  @Column({ nullable: true })
  relatedType: string; // 关联类型

  @Column({ nullable: true })
  image: string;

  @Column({ nullable: true })
  actionUrl: string;

  @Column({ type: 'enum', enum: NotificationStatus, default: NotificationStatus.UNREAD })
  status: NotificationStatus;

  @Column({ default: false })
  isPushed: boolean; // 是否已推送

  @Column({ nullable: true })
  pushedAt: Date;

  @Column({ nullable: true })
  readAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('notification_templates')
export class NotificationTemplate {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  code: string;

  @Column()
  titleTemplate: string;

  @Column()
  contentTemplate: string;

  @Column({ nullable: true })
  titleTemplateEn: string;

  @Column({ nullable: true })
  contentTemplateEn: string;

  @Column({ nullable: true })
  variables: string; // JSON array of variable names

  @Column({ type: 'enum', enum: NotificationType })
  type: NotificationType;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('push_devices')
export class PushDevice {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column({ nullable: true })
  deviceToken: string;

  @Column({ nullable: true })
  deviceType: string; // ios, android, web

  @Column({ nullable: true })
  deviceInfo: string; // JSON

  @Column({ default: true })
  isActive: boolean;

  @Column({ nullable: true })
  lastPushAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('email_queue')
export class EmailQueue {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  to: string;

  @Column()
  subject: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  template: string;

  @Column({ nullable: true })
  templateData: string; // JSON

  @Column({ type: 'enum', enum: ['pending', 'sending', 'sent', 'failed'], default: 'pending' })
  status: string;

  @Column({ default: 0 })
  retryCount: number;

  @Column({ nullable: true })
  sentAt: Date;

  @Column({ nullable: true })
  errorMessage: string;

  @CreateDateColumn()
  createdAt: Date;
}
