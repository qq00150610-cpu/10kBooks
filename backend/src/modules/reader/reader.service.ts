import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ReadingProgress, Bookmark, Note, ReadingHistory, ReadingSession, OfflineCache } from '../../entities/reader.entity';
import { Book, Chapter } from '../../entities/book.entity';
import { IsOptional, IsString, IsNumber, IsBoolean } from 'class-validator';

export class UpdateProgressDto {
  @IsString()
  bookId: string;

  @IsString()
  chapterId: string;

  @IsNumber()
  progress: number;

  @IsOptional()
  @IsNumber()
  scrollPosition?: number;

  @IsOptional()
  @IsNumber()
  wordOffset?: number;
}

export class CreateBookmarkDto {
  @IsString()
  bookId: string;

  @IsOptional()
  @IsString()
  chapterId?: string;

  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsNumber()
  position?: number;

  @IsOptional()
  @IsString()
  selectedText?: string;
}

export class CreateNoteDto {
  @IsString()
  bookId: string;

  @IsOptional()
  @IsString()
  chapterId?: string;

  @IsString()
  content: string;

  @IsOptional()
  @IsString()
  noteType?: 'highlight' | 'note' | 'review';

  @IsOptional()
  @IsString()
  color?: string;

  @IsOptional()
  @IsNumber()
  pageNumber?: number;

  @IsOptional()
  @IsNumber()
  position?: number;
}

@Injectable()
export class ReaderService {
  constructor(
    @InjectRepository(ReadingProgress)
    private progressRepository: Repository<ReadingProgress>,
    @InjectRepository(Bookmark)
    private bookmarkRepository: Repository<Bookmark>,
    @InjectRepository(Note)
    private noteRepository: Repository<Note>,
    @InjectRepository(ReadingHistory)
    private historyRepository: Repository<ReadingHistory>,
    @InjectRepository(ReadingSession)
    private sessionRepository: Repository<ReadingSession>,
    @InjectRepository(OfflineCache)
    private cacheRepository: Repository<OfflineCache>,
    @InjectRepository(Book)
    private bookRepository: Repository<Book>,
    @InjectRepository(Chapter)
    private chapterRepository: Repository<Chapter>,
  ) {}

  async getReadingProgress(userId: string, bookId: string) {
    let progress = await this.progressRepository.findOne({
      where: { userId, bookId },
    });

    if (!progress) {
      progress = this.progressRepository.create({
        userId,
        bookId,
        progress: 0,
        readingTime: 0,
      });
      await this.progressRepository.save(progress);
    }

    return progress;
  }

  async updateReadingProgress(userId: string, dto: UpdateProgressDto) {
    let progress = await this.progressRepository.findOne({
      where: { userId, bookId: dto.bookId },
    });

    if (!progress) {
      progress = this.progressRepository.create({
        userId,
        ...dto,
        lastReadAt: new Date(),
      });
    } else {
      progress.chapterId = dto.chapterId;
      progress.progress = dto.progress;
      progress.scrollPosition = dto.scrollPosition;
      progress.wordOffset = dto.wordOffset;
      progress.lastReadAt = new Date();
    }

    await this.progressRepository.save(progress);

    // 添加到阅读历史
    await this.addToHistory(userId, dto.bookId, dto.chapterId, dto.progress);

    return progress;
  }

  async getBookmarks(userId: string, bookId?: string) {
    const where: any = { userId };
    if (bookId) where.bookId = bookId;

    return this.bookmarkRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  async createBookmark(userId: string, dto: CreateBookmarkDto) {
    const bookmark = this.bookmarkRepository.create({
      userId,
      ...dto,
    });

    await this.bookmarkRepository.save(bookmark);

    return bookmark;
  }

  async updateBookmark(userId: string, bookmarkId: string, dto: Partial<CreateBookmarkDto>) {
    const bookmark = await this.bookmarkRepository.findOne({
      where: { id: bookmarkId, userId },
    });

    if (!bookmark) {
      throw new NotFoundException('书签不存在');
    }

    Object.assign(bookmark, dto);
    await this.bookmarkRepository.save(bookmark);

    return bookmark;
  }

  async deleteBookmark(userId: string, bookmarkId: string) {
    await this.bookmarkRepository.delete({ id: bookmarkId, userId });
    return { message: '书签已删除' };
  }

  async getNotes(userId: string, bookId?: string) {
    const where: any = { userId };
    if (bookId) where.bookId = bookId;

    return this.noteRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  async createNote(userId: string, dto: CreateNoteDto) {
    const note = this.noteRepository.create({
      userId,
      ...dto,
    });

    await this.noteRepository.save(note);

    return note;
  }

  async updateNote(userId: string, noteId: string, dto: Partial<CreateNoteDto>) {
    const note = await this.noteRepository.findOne({
      where: { id: noteId, userId },
    });

    if (!note) {
      throw new NotFoundException('笔记不存在');
    }

    Object.assign(note, dto);
    await this.noteRepository.save(note);

    return note;
  }

  async deleteNote(userId: string, noteId: string) {
    await this.noteRepository.delete({ id: noteId, userId });
    return { message: '笔记已删除' };
  }

  async shareNote(userId: string, noteId: string) {
    const note = await this.noteRepository.findOne({
      where: { id: noteId, userId },
    });

    if (!note) {
      throw new NotFoundException('笔记不存在');
    }

    note.isShared = true;
    note.sharedAt = new Date();
    await this.noteRepository.save(note);

    return note;
  }

  async getReadingHistory(userId: string, page: number = 1, pageSize: number = 20) {
    const skip = (page - 1) * pageSize;

    const [history, total] = await this.historyRepository.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip,
      take: pageSize,
    });

    // 获取书籍信息
    const bookIds = [...new Set(history.map(h => h.bookId))];
    const books = await this.bookRepository.findBy({ id: In(bookIds) });
    const bookMap = new Map(books.map(b => [b.id, b]));

    const formattedHistory = history.map(h => ({
      ...h,
      book: bookMap.get(h.bookId) ? {
        id: bookMap.get(h.bookId).id,
        title: bookMap.get(h.bookId).title,
        cover: bookMap.get(h.bookId).cover,
      } : null,
    }));

    return {
      list: formattedHistory,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async getReadingStats(userId: string) {
    const [totalBooks, totalChapters, totalTime] = await Promise.all([
      this.progressRepository.count({ where: { userId } }),
      this.historyRepository.createQueryBuilder('history')
        .where('history.userId = :userId', { userId })
        .select('COUNT(DISTINCT history.chapterId)', 'count')
        .getRawOne(),
      this.progressRepository
        .createQueryBuilder('progress')
        .where('progress.userId = :userId', { userId })
        .select('SUM(progress.readingTime)', 'total')
        .getRawOne(),
    ]);

    return {
      totalBooksRead: totalBooks,
      totalChaptersRead: parseInt(totalChapters?.count || '0'),
      totalReadingTime: parseInt(totalTime?.total || '0'), // 秒
      readingStreak: 0, // TODO: 计算连续阅读天数
    };
  }

  async startReadingSession(userId: string, bookId: string, chapterId?: string) {
    const session = this.sessionRepository.create({
      userId,
      bookId,
      chapterId,
      startTime: new Date(),
    });

    await this.sessionRepository.save(session);

    return session;
  }

  async endReadingSession(userId: string, sessionId: string) {
    const session = await this.sessionRepository.findOne({
      where: { id: sessionId, userId },
    });

    if (!session) {
      throw new NotFoundException('阅读会话不存在');
    }

    session.endTime = new Date();
    session.duration = Math.floor((session.endTime.getTime() - session.startTime.getTime()) / 1000);

    await this.sessionRepository.save(session);

    return session;
  }

  async cacheChapter(userId: string, bookId: string, chapterId: string, content: string) {
    // 检查缓存是否存在
    let cache = await this.cacheRepository.findOne({
      where: { userId, bookId, chapterId },
    });

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7天后过期

    if (cache) {
      cache.content = content;
      cache.size = Buffer.byteLength(content, 'utf8');
      cache.expiresAt = expiresAt;
      cache.isValid = true;
    } else {
      cache = this.cacheRepository.create({
        userId,
        bookId,
        chapterId,
        content,
        size: Buffer.byteLength(content, 'utf8'),
        expiresAt,
      });
    }

    await this.cacheRepository.save(cache);

    return { message: '缓存成功' };
  }

  async getOfflineChapters(userId: string, bookId: string) {
    return this.cacheRepository.find({
      where: { userId, bookId, isValid: true },
      order: { createdAt: 'DESC' },
    });
  }

  async clearOfflineCache(userId: string, bookId?: string) {
    const where: any = { userId, isValid: true };
    if (bookId) where.bookId = bookId;

    await this.cacheRepository.update(where, { isValid: false });

    return { message: '缓存已清除' };
  }

  private async addToHistory(
    userId: string,
    bookId: string,
    chapterId: string,
    progress: number,
  ) {
    const chapter = chapterId
      ? await this.chapterRepository.findOne({ where: { id: chapterId } })
      : null;

    const history = this.historyRepository.create({
      userId,
      bookId,
      chapterId,
      chapterTitle: chapter?.title,
      progress,
    });

    // 限制历史记录数量，保留最近100条
    const count = await this.historyRepository.count({ where: { userId } });
    if (count > 100) {
      const oldest = await this.historyRepository.find({
        where: { userId },
        order: { createdAt: 'ASC' },
        take: count - 100,
      });
      await this.historyRepository.remove(oldest);
    }

    await this.historyRepository.save(history);
  }
}
