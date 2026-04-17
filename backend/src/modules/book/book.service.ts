import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like, In } from 'typeorm';
import { Book, Chapter, BookCategory, BookTag, BookCollection, BookStatus, PriceStrategy } from '../../entities/book.entity';
import { User } from '../../entities/user.entity';
import { Rating } from '../../entities/social.entity';
import { IsOptional, IsString, IsArray, IsNumber, IsEnum } from 'class-validator';

export class SearchBookDto {
  @IsOptional()
  @IsString()
  keyword?: string;

  @IsOptional()
  @IsArray()
  categories?: string[];

  @IsOptional()
  @IsArray()
  tags?: string[];

  @IsOptional()
  @IsString()
  language?: string;

  @IsOptional()
  @IsEnum(BookStatus)
  status?: BookStatus;

  @IsOptional()
  @IsString()
  sortBy?: 'createdAt' | 'updatedAt' | 'views' | 'likes' | 'rating';

  @IsOptional()
  @IsString()
  sortOrder?: 'ASC' | 'DESC';

  @IsOptional()
  @IsNumber()
  page?: number;

  @IsOptional()
  @IsNumber()
  pageSize?: number;
}

export class GetChapterContentDto {
  @IsString()
  chapterId: string;

  @IsOptional()
  @IsNumber()
  startPosition?: number;

  @IsOptional()
  @IsNumber()
  endPosition?: number;
}

@Injectable()
export class BookService {
  constructor(
    @InjectRepository(Book)
    private bookRepository: Repository<Book>,
    @InjectRepository(Chapter)
    private chapterRepository: Repository<Chapter>,
    @InjectRepository(BookCategory)
    private categoryRepository: Repository<BookCategory>,
    @InjectRepository(BookTag)
    private tagRepository: Repository<BookTag>,
    @InjectRepository(BookCollection)
    private collectionRepository: Repository<BookCollection>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Rating)
    private ratingRepository: Repository<Rating>,
  ) {}

  async searchBooks(dto: SearchBookDto) {
    const {
      keyword,
      categories,
      tags,
      language,
      status = BookStatus.PUBLISHED,
      sortBy = 'createdAt',
      sortOrder = 'DESC',
      page = 1,
      pageSize = 20,
    } = dto;

    const queryBuilder = this.bookRepository.createQueryBuilder('book')
      .leftJoinAndSelect('book.author', 'author')
      .where('book.status = :status', { status });

    if (keyword) {
      queryBuilder.andWhere(
        '(book.title ILIKE :keyword OR book.description ILIKE :keyword)',
        { keyword: `%${keyword}%` },
      );
    }

    if (categories && categories.length > 0) {
      queryBuilder.andWhere('book.categories::jsonb ?| array[:...categories]', { categories });
    }

    if (tags && tags.length > 0) {
      queryBuilder.andWhere('book.tags::jsonb ?| array[:...tags]', { tags });
    }

    if (language) {
      queryBuilder.andWhere('book.language = :language', { language });
    }

    queryBuilder.orderBy(`book.${sortBy}`, sortOrder);

    const total = await queryBuilder.getCount();
    const books = await queryBuilder
      .skip((page - 1) * pageSize)
      .take(pageSize)
      .getMany();

    // 格式化返回数据
    const formattedBooks = books.map(book => ({
      ...book,
      tags: book.tags ? JSON.parse(book.tags) : [],
      categories: book.categories ? JSON.parse(book.categories) : [],
      author: book.author ? {
        id: book.author.id,
        penName: (book.author as any)?.penName || book.author.username,
        avatar: book.author.avatar,
      } : null,
    }));

    return {
      list: formattedBooks,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async getBookDetail(bookId: string, userId?: string) {
    const book = await this.bookRepository.findOne({
      where: { id: bookId },
      relations: ['author'],
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    // 增加浏览量
    book.totalViews += 1;
    await this.bookRepository.save(book);

    // 获取评分统计
    const ratingStats = await this.ratingRepository
      .createQueryBuilder('rating')
      .where('rating.bookId = :bookId', { bookId })
      .select([
        'COUNT(*) as totalRatings',
        'AVG(rating.score) as avgScore',
      ])
      .getRawOne();

    // 检查用户是否收藏
    let isCollected = false;
    if (userId) {
      const collection = await this.collectionRepository.findOne({
        where: { userId, bookId },
      });
      isCollected = !!collection;
    }

    return {
      ...book,
      tags: book.tags ? JSON.parse(book.tags) : [],
      categories: book.categories ? JSON.parse(book.categories) : [],
      author: book.author ? {
        id: book.author.id,
        penName: (book.author as any)?.penName || book.author.username,
        avatar: book.author.avatar,
        bio: (book.author as any)?.bio,
      } : null,
      ratingStats: {
        totalRatings: parseInt(ratingStats?.totalRatings || '0'),
        avgScore: parseFloat(ratingStats?.avgScore || '0'),
      },
      isCollected,
    };
  }

  async getChapterContent(bookId: string, chapterId: string, userId?: string) {
    const chapter = await this.chapterRepository.findOne({
      where: { id: chapterId, bookId },
    });

    if (!chapter) {
      throw new NotFoundException('章节不存在');
    }

    const book = await this.bookRepository.findOne({
      where: { id: bookId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    // 检查是否需要付费
    let canRead = true;
    let isPurchased = false;

    if (chapter.isVipChapter && !chapter.isFreePreview) {
      if (!userId) {
        canRead = false;
      } else {
        // TODO: 检查用户VIP状态或购买记录
        const user = await this.userRepository.findOne({ where: { id: userId } });
        if (user?.role !== 'vip' && user?.role !== 'admin') {
          canRead = false;
        }
      }
    }

    return {
      id: chapter.id,
      bookId: chapter.bookId,
      chapterNumber: chapter.chapterNumber,
      title: chapter.title,
      content: canRead || chapter.isFreePreview ? chapter.content : null,
      summary: chapter.summary,
      wordCount: chapter.wordCount,
      price: chapter.price,
      isVipChapter: chapter.isVipChapter,
      isFreePreview: chapter.isFreePreview,
      canRead,
      isPurchased,
      publishedAt: chapter.publishedAt,
    };
  }

  async getBookChapters(bookId: string, page: number = 1, pageSize: number = 50) {
    const book = await this.bookRepository.findOne({
      where: { id: bookId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    const [chapters, total] = await this.chapterRepository.findAndCount({
      where: { bookId, status: 'published' },
      order: { chapterNumber: 'ASC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return {
      list: chapters.map(ch => ({
        id: ch.id,
        chapterNumber: ch.chapterNumber,
        title: ch.title,
        summary: ch.summary,
        wordCount: ch.wordCount,
        isVipChapter: ch.isVipChapter,
        isFreePreview: ch.isFreePreview,
        price: ch.price,
        publishedAt: ch.publishedAt,
      })),
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async collectBook(userId: string, bookId: string, note?: string) {
    const book = await this.bookRepository.findOne({
      where: { id: bookId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    const existing = await this.collectionRepository.findOne({
      where: { userId, bookId },
    });

    if (existing) {
      return { message: '已收藏' };
    }

    const collection = this.collectionRepository.create({
      userId,
      bookId,
      note,
    });

    await this.collectionRepository.save(collection);

    // 更新收藏数
    book.totalCollections += 1;
    await this.bookRepository.save(book);

    return { message: '收藏成功' };
  }

  async uncollectBook(userId: string, bookId: string) {
    await this.collectionRepository.delete({ userId, bookId });

    // 更新收藏数
    const book = await this.bookRepository.findOne({ where: { id: bookId } });
    if (book && book.totalCollections > 0) {
      book.totalCollections -= 1;
      await this.bookRepository.save(book);
    }

    return { message: '取消收藏成功' };
  }

  async getMyCollections(userId: string, page: number = 1, pageSize: number = 20) {
    const [collections, total] = await this.collectionRepository.findAndCount({
      where: { userId },
      relations: ['book', 'book.author'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const books = collections.map(c => ({
      id: c.book?.id,
      title: c.book?.title,
      cover: c.book?.cover,
      author: c.book?.author ? {
        id: c.book.author.id,
        penName: (c.book.author as any)?.penName || c.book.author.username,
      } : null,
      note: c.note,
      collectedAt: c.createdAt,
    }));

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

  async getCategories() {
    const categories = await this.categoryRepository.find({
      where: { isActive: true },
      order: { sortOrder: 'ASC' },
    });

    return categories;
  }

  async getTags(limit: number = 50) {
    const tags = await this.tagRepository.find({
      where: { isActive: true },
      order: { usageCount: 'DESC' },
      take: limit,
    });

    return tags;
  }

  async getHotBooks(limit: number = 10) {
    const books = await this.bookRepository.find({
      where: { status: BookStatus.PUBLISHED },
      relations: ['author'],
      order: { totalViews: 'DESC', totalLikes: 'DESC' },
      take: limit,
    });

    return books.map(book => ({
      id: book.id,
      title: book.title,
      cover: book.cover,
      author: book.author ? {
        id: book.author.id,
        penName: (book.author as any)?.penName || book.author.username,
      } : null,
      totalViews: book.totalViews,
      totalLikes: book.totalLikes,
      avgRating: book.avgRating,
    }));
  }

  async getNewBooks(limit: number = 10) {
    const books = await this.bookRepository.find({
      where: { status: BookStatus.PUBLISHED },
      relations: ['author'],
      order: { publishedAt: 'DESC' },
      take: limit,
    });

    return books.map(book => ({
      id: book.id,
      title: book.title,
      cover: book.cover,
      author: book.author ? {
        id: book.author.id,
        penName: (book.author as any)?.penName || book.author.username,
      } : null,
      publishedAt: book.publishedAt,
    }));
  }

  async getRecommendedBooks(userId?: string, limit: number = 10) {
    // TODO: 实现个性化推荐算法
    // 目前返回热门书籍作为推荐
    return this.getHotBooks(limit);
  }

  async rateBook(userId: string, bookId: string, score: number, content?: string) {
    const book = await this.bookRepository.findOne({
      where: { id: bookId },
    });

    if (!book) {
      throw new NotFoundException('书籍不存在');
    }

    // 检查是否已评分
    const existingRating = await this.ratingRepository.findOne({
      where: { userId, bookId },
    });

    if (existingRating) {
      // 更新评分
      existingRating.score = score;
      existingRating.content = content;
      await this.ratingRepository.save(existingRating);
    } else {
      // 创建新评分
      const rating = this.ratingRepository.create({
        userId,
        bookId,
        score,
        content,
      });
      await this.ratingRepository.save(rating);

      // 更新书籍评分统计
      book.totalReviews += 1;
    }

    // 重新计算平均分
    const avgRating = await this.ratingRepository
      .createQueryBuilder('rating')
      .where('rating.bookId = :bookId', { bookId })
      .select('AVG(rating.score)', 'avg')
      .getRawOne();

    book.avgRating = parseFloat(avgRating?.avg || '0');
    await this.bookRepository.save(book);

    return { message: '评分成功', avgRating: book.avgRating };
  }
}
