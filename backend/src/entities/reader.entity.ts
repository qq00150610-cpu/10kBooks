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

@Entity('reading_progress')
export class ReadingProgress {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  @Index()
  chapterId: string;

  @Column({ default: 0 })
  progress: number; // 百分比 0-100

  @Column({ nullable: true })
  scrollPosition: number; // 滚动位置

  @Column({ default: 0 })
  wordOffset: number; // 字符偏移量

  @Column({ default: 0 })
  readingTime: number; // 阅读时长（秒）

  @Column({ nullable: true })
  lastReadAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('bookmarks')
export class Bookmark {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  chapterId: string;

  @Column()
  title: string;

  @Column({ nullable: true })
  note: string;

  @Column({ nullable: true })
  position: number; // 字符位置

  @Column({ nullable: true })
  selectedText: string; // 选中的文本

  @Column({ default: true })
  isPublic: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('notes')
export class Note {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  chapterId: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  noteType: 'highlight' | 'note' | 'review'; // 标注类型

  @Column({ nullable: true })
  color: string; // 高亮颜色

  @Column({ nullable: true })
  pageNumber: number;

  @Column({ nullable: true })
  position: number;

  @Column({ default: false })
  isShared: boolean;

  @Column({ nullable: true })
  sharedAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('reading_history')
export class ReadingHistory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  chapterId: string;

  @Column({ nullable: true })
  chapterTitle: string;

  @Column({ nullable: true })
  progress: number;

  @Column({ nullable: true })
  deviceInfo: string; // 设备信息

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('reading_sessions')
export class ReadingSession {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  chapterId: string;

  @Column()
  startTime: Date;

  @Column({ nullable: true })
  endTime: Date;

  @Column({ default: 0 })
  duration: number; // 秒

  @Column({ default: 0 })
  pagesRead: number;

  @Column({ nullable: true })
  deviceInfo: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('offline_cache')
export class OfflineCache {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  chapterId: string;

  @Column({ type: 'text' })
  content: string;

  @Column()
  size: number; // bytes

  @Column({ default: true })
  isValid: boolean;

  @Column({ nullable: true })
  expiresAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
