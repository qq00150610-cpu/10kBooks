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

@Entity('follows')
export class Follow {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  followerId: string;

  @Column()
  @Index()
  followingId: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('user_dynamics')
export class UserDynamic {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  dynamicType: 'book_update' | 'new_book' | 'review' | 'follow_milestone';

  @Column({ nullable: true })
  targetId: string; // 关联的书籍、评论等ID

  @Column({ type: 'text', nullable: true })
  content: string;

  @Column({ nullable: true })
  images: string; // JSON array

  @Column({ default: true })
  isPublic: boolean;

  @Column({ default: 0 })
  likes: number;

  @Column({ default: 0 })
  comments: number;

  @Column({ default: false })
  isPinned: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('comments')
export class Comment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column({ nullable: true })
  @Index()
  bookId: string;

  @Column({ nullable: true })
  @Index()
  chapterId: string;

  @Column({ nullable: true })
  @Index()
  parentId: string; // 回复的评论ID

  @Column({ nullable: true })
  dynamicId: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ default: 0 })
  likes: number;

  @Column({ default: false })
  isPinned: boolean;

  @Column({ default: false })
  isDeleted: boolean;

  @Column({ nullable: true })
  deletedAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('ratings')
export class Rating {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ type: 'tinyint' })
  score: number; // 1-5分

  @Column({ type: 'text', nullable: true })
  content: string;

  @Column({ default: false })
  isDeleted: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('booklists')
export class Booklist {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  title: string;

  @Column({ nullable: true })
  description: string;

  @Column({ nullable: true })
  cover: string;

  @Column({ default: true })
  isPublic: boolean;

  @Column({ default: false })
  isFeatured: boolean;

  @Column({ default: 0 })
  books: number;

  @Column({ default: 0 })
  followers: number;

  @Column({ default: 0 })
  views: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('booklist_books')
export class BooklistBook {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  booklistId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  note: string;

  @Column()
  sortOrder: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('comment_likes')
export class CommentLike {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  commentId: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('dynamic_likes')
export class DynamicLike {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  dynamicId: string;

  @CreateDateColumn()
  createdAt: Date;
}
