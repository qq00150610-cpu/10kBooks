import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { User, AuthorApplication } from '../../entities/user.entity';
import { Book, Chapter, BookStatus } from '../../entities/book.entity';
import { AuthorEarning } from '../../entities/payment.entity';
import { UserRole } from '../../common/constants';
import { IsOptional, IsString, IsArray, IsNumber, IsEnum } from 'class-validator';

export class ApplyAuthorDto {
  @IsString()
  penName: string;

  @IsOptional()
  @IsString()
  avatar?: string;

  @IsOptional()
  @IsString()
  bio?: string;

  @IsString()
  idCardNumber: string;

  @IsString()
  idCardFront: string;

  @IsString()
  idCardBack: string;

  @IsOptional()
  @IsString()
  writingExperience?: string;
}

export class CreateBookDto {
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  originalTitle?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  cover?: string;

  @IsEnum(BookStatus)
  status?: BookStatus;

  @IsOptional()
  @IsString()
  language?: string;

  @IsOptional()
  @IsArray()
  tags?: string[];

  @IsOptional()
  @IsArray()
  categories?: string[];
}

export class UpdateBookDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  cover?: string;

  @IsOptional()
  @IsEnum(BookStatus)
  status?: BookStatus;

  @IsOptional()
  @IsArray()
  tags?: string[];

  @IsOptional()
  @IsArray()
  categories?: string[];
}

export class CreateChapterDto {
  @IsNumber()
  chapterNumber: number;

  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  content?: string;

  @IsOptional()
  @IsNumber()
  price?: number;

  @IsOptional()
  isVipChapter?: boolean;

  @IsOptional()
  isFreePreview?: boolean;
}

export class UpdateChapterDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  content?: string;

  @IsOptional()
  @IsNumber()
  price?: number;

  @IsOptional()
  isVipChapter?: boolean;

  @IsOptional()
  isFreePreview?: boolean;

  @IsOptional()
  @IsString()
  status?: string;
}

@Injectable()
export class AuthorService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(AuthorApplication)
    private authorApplicationRepository: Repository<AuthorApplication>,
    @InjectRepository(Book)
    private bookRepository: Repository<Book>,
    @InjectRepository(Chapter)
    private chapterRepository: Repository<Chapter>,
    @InjectRepository(AuthorEarning)
    private authorEarningRepository: Repository<AuthorEarning>,
    private configService: ConfigService,
  ) {}

  async applyForAuthor(userId: string, dto: ApplyAuthorDto) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    // 检查是否已经是作者
    if (user.role === UserRole.AUTHOR || user.role === UserRole.ADMIN) {
      throw new BadRequestException('您已经是作者');
    }

    // 检查是否有待处理的申请
    const existingApplication = await this.authorApplicationRepository.findOne({
      where: { userId, status: 'pending' },
    });

    if (existingApplication) {
      throw new BadRequestException('您有待处理的申请');
    }

    // 创建申请
    const application = this.authorApplicationRepository.create({
      userId,
      ...dto,
    });

    await this.authorApplicationRepository.save(application);

    return { message: '申请已提交，请等待审核' };
  }

  async getAuthorApplication(userId: string) {
    const application = await this.authorApplicationRepository.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });

    if (!application) {
      throw new NotFoundException('暂无申请记录');
    }

    return application;
  }

  async createBook(authorId: string, dto: CreateBookDto) {
    await this.validateAuthor(authorId);

    const book = this.bookRepository.create({
      authorId,
      ...dto,
      tags: JSON.stringify(dto.tags || []),
      categories: JSON.stringify(dto.categories || []),
      status: dto.status || BookStatus.DRAFT,
    });

    await this.bookRepository.save(book);

    return book;
  }

  async updateBook(authorId: string, bookId: string, dto: UpdateBookDto) {
    const author = await this.validateAuthor(authorId);

    const book = await this.bookRepository.findOne({
      where: { id: bookId, authorId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    if (dto.tags) dto.tags = JSON.stringify(dto.tags);
    if (dto.categories) dto.categories = JSON.stringify(dto.categories);

    Object.assign(book, dto);
    await this.bookRepository.save(book);

    return book;
  }

  async deleteBook(authorId: string, bookId: string) {
    await this.validateAuthor(authorId);

    const book = await this.bookRepository.findOne({
      where: { id: bookId, authorId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    // 软删除
    book.status = BookStatus.DELETED;
    await this.bookRepository.save(book);

    return { message: '书籍已删除' };
  }

  async getMyBooks(authorId: string, page: number = 1, pageSize: number = 20) {
    await this.validateAuthor(authorId);

    const skip = (page - 1) * pageSize;

    const [books, total] = await this.bookRepository.findAndCount({
      where: { authorId },
      order: { updatedAt: 'DESC' },
      skip,
      take: pageSize,
    });

    return {
      list: books,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async createChapter(authorId: string, bookId: string, dto: CreateChapterDto) {
    await this.validateAuthor(authorId);

    const book = await this.bookRepository.findOne({
      where: { id: bookId, authorId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    // 检查章节号是否重复
    const existingChapter = await this.chapterRepository.findOne({
      where: { bookId, chapterNumber: dto.chapterNumber },
    });

    if (existingChapter) {
      throw new BadRequestException('章节号已存在');
    }

    const chapter = this.chapterRepository.create({
      bookId,
      authorId,
      ...dto,
    });

    await this.chapterRepository.save(chapter);

    // 更新书籍统计
    book.totalChapters = await this.chapterRepository.count({ where: { bookId } });
    await this.bookRepository.save(book);

    return chapter;
  }

  async updateChapter(authorId: string, chapterId: string, dto: UpdateChapterDto) {
    await this.validateAuthor(authorId);

    const chapter = await this.chapterRepository.findOne({
      where: { id: chapterId, authorId },
    });

    if (!chapter) {
      throw new NotFoundException('章节不存在');
    }

    Object.assign(chapter, dto);
    await this.chapterRepository.save(chapter);

    return chapter;
  }

  async deleteChapter(authorId: string, chapterId: string) {
    await this.validateAuthor(authorId);

    const chapter = await this.chapterRepository.findOne({
      where: { id: chapterId, authorId },
    });

    if (!chapter) {
      throw new NotFoundException('章节不存在');
    }

    await this.chapterRepository.softDelete(chapterId);

    // 更新书籍统计
    const book = await this.bookRepository.findOne({ where: { id: chapter.bookId } });
    if (book) {
      book.totalChapters = await this.chapterRepository.count({ where: { bookId: book.id } });
      await this.bookRepository.save(book);
    }

    return { message: '章节已删除' };
  }

  async batchCreateChapters(authorId: string, bookId: string, chapters: CreateChapterDto[]) {
    await this.validateAuthor(authorId);

    const book = await this.bookRepository.findOne({
      where: { id: bookId, authorId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    const createdChapters = [];
    for (const dto of chapters) {
      const chapter = this.chapterRepository.create({
        bookId,
        authorId,
        ...dto,
      });
      createdChapters.push(chapter);
    }

    await this.chapterRepository.save(createdChapters);

    // 更新书籍统计
    book.totalChapters = await this.chapterRepository.count({ where: { bookId } });
    await this.bookRepository.save(book);

    return { message: `成功创建${createdChapters.length}个章节`, chapters: createdChapters };
  }

  async publishChapter(authorId: string, chapterId: string) {
    await this.validateAuthor(authorId);

    const chapter = await this.chapterRepository.findOne({
      where: { id: chapterId, authorId },
    });

    if (!chapter) {
      throw new NotFoundException('章节不存在');
    }

    chapter.status = 'published';
    chapter.publishedAt = new Date();
    await this.chapterRepository.save(chapter);

    // 更新书籍统计
    const book = await this.bookRepository.findOne({ where: { id: chapter.bookId } });
    if (book) {
      book.publishedChapters = await this.chapterRepository.count({
        where: { bookId: book.id, status: 'published' },
      });
      book.lastChapterAt = new Date();
      await this.bookRepository.save(book);
    }

    return chapter;
  }

  async getEarnings(authorId: string, page: number = 1, pageSize: number = 20) {
    await this.validateAuthor(authorId);

    const skip = (page - 1) * pageSize;

    const [earnings, total] = await this.authorEarningRepository.findAndCount({
      where: { authorId },
      order: { createdAt: 'DESC' },
      skip,
      take: pageSize,
    });

    // 计算统计
    const stats = {
      totalRevenue: 0,
      pendingSettlement: 0,
      withdrawn: 0,
    };

    for (const earning of await this.authorEarningRepository.find({ where: { authorId } })) {
      stats.totalRevenue += earning.revenue;
      if (earning.status === 'pending') stats.pendingSettlement += earning.authorAmount;
      if (earning.status === 'withdrawn') stats.withdrawn += earning.withdrawalAmount;
    }

    return {
      list: earnings,
      stats,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async getBookChapters(authorId: string, bookId: string, page: number = 1, pageSize: number = 50) {
    await this.validateAuthor(authorId);

    const book = await this.bookRepository.findOne({
      where: { id: bookId, authorId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    const skip = (page - 1) * pageSize;

    const [chapters, total] = await this.chapterRepository.findAndCount({
      where: { bookId },
      order: { chapterNumber: 'ASC' },
      skip,
      take: pageSize,
    });

    return {
      list: chapters,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  private async validateAuthor(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    if (user.role !== UserRole.AUTHOR && user.role !== UserRole.ADMIN) {
      throw new ForbiddenException('您还不是作者');
    }

    return user;
  }
}
