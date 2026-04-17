import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

@Entity('ai_summaries')
export class AiSummary {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  @Index()
  chapterId: string;

  @Column()
  summaryType: 'book_intro' | 'chapter_summary' | 'ai_review';

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  language: string;

  @Column({ default: 0 })
  wordCount: number;

  @Column({ nullable: true })
  model: string;

  @Column({ nullable: true })
  tokens: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('ai_translations')
export class AiTranslation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  originalBookId: string;

  @Column({ nullable: true })
  @Index()
  translatedBookId: string;

  @Column({ nullable: true })
  @Index()
  chapterId: string;

  @Column()
  sourceLanguage: string;

  @Column()
  targetLanguage: string;

  @Column({ type: 'text' })
  originalText: string;

  @Column({ type: 'text' })
  translatedText: string;

  @Column({ nullable: true })
  model: string;

  @Column({ nullable: true })
  tokens: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('ai_chats')
export class AiChat {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column({ nullable: true })
  @Index()
  bookId: string;

  @Column({ nullable: true })
  context: string; // JSON: 对话上下文

  @Column({ nullable: true })
  lastMessage: string;

  @Column({ default: 0 })
  messageCount: number;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('ai_messages')
export class AiMessage {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  chatId: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  role: 'user' | 'assistant' | 'system';

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  model: string;

  @Column({ nullable: true })
  tokens: number;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('ai_writing_assists')
export class AiWritingAssist {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  authorId: string;

  @Column()
  @Index()
  bookId: string;

  @Column({ nullable: true })
  @Index()
  chapterId: string;

  @Column()
  assistType: 'outline' | 'content' | 'polish' | 'title' | 'description';

  @Column({ type: 'text' })
  input: string;

  @Column({ type: 'text' })
  output: string;

  @Column({ nullable: true })
  parameters: string; // JSON

  @Column({ nullable: true })
  model: string;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('ai_recommendations')
export class AiRecommendation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  userId: string;

  @Column()
  @Index()
  bookId: string;

  @Column()
  recommendType: 'personalized' | 'similar' | 'popular' | 'trending';

  @Column({ nullable: true })
  score: number;

  @Column({ nullable: true })
  reason: string; // 推荐理由

  @Column({ default: false })
  isClicked: boolean;

  @Column({ default: false })
  isRead: boolean;

  @Column({ default: false })
  isPurchased: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

@Entity('ai_content_checks')
export class AiContentCheck {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  targetId: string;

  @Column()
  checkType: 'sensitive' | 'quality' | 'copyright';

  @Column({ type: 'text' })
  content: string;

  @Column({ type: 'jsonb' })
  result: Record<string, any>;

  @Column({ default: false })
  hasIssue: boolean;

  @Column({ nullable: true })
  issueType: string;

  @Column({ nullable: true })
  confidence: number;

  @CreateDateColumn()
  createdAt: Date;
}
