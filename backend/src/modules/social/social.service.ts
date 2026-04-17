import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Follow, UserDynamic, Comment, Booklist, BooklistBook, CommentLike, DynamicLike } from '../../entities/social.entity';
import { User } from '../../entities/user.entity';
import { IsOptional, IsString, IsArray, IsNumber } from 'class-validator';

export class CreateDynamicDto {
  @IsString()
  dynamicType: 'book_update' | 'new_book' | 'review' | 'follow_milestone';

  @IsOptional()
  @IsString()
  targetId?: string;

  @IsOptional()
  @IsString()
  content?: string;

  @IsOptional()
  @IsArray()
  images?: string[];
}

export class CreateCommentDto {
  @IsOptional()
  @IsString()
  bookId?: string;

  @IsOptional()
  @IsString()
  chapterId?: string;

  @IsOptional()
  @IsString()
  parentId?: string;

  @IsOptional()
  @IsString()
  dynamicId?: string;

  @IsString()
  content: string;
}

export class CreateBooklistDto {
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  cover?: string;

  isPublic?: boolean;
}

@Injectable()
export class SocialService {
  constructor(
    @InjectRepository(Follow)
    private followRepository: Repository<Follow>,
    @InjectRepository(UserDynamic)
    private dynamicRepository: Repository<UserDynamic>,
    @InjectRepository(Comment)
    private commentRepository: Repository<Comment>,
    @InjectRepository(Booklist)
    private booklistRepository: Repository<Booklist>,
    @InjectRepository(BooklistBook)
    private booklistBookRepository: Repository<BooklistBook>,
    @InjectRepository(CommentLike)
    private commentLikeRepository: Repository<CommentLike>,
    @InjectRepository(DynamicLike)
    private dynamicLikeRepository: Repository<DynamicLike>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async followUser(followerId: string, followingId: string) {
    if (followerId === followingId) {
      throw new BadRequestException('不能关注自己');
    }

    const targetUser = await this.userRepository.findOne({ where: { id: followingId } });
    if (!targetUser) {
      throw new NotFoundException('用户不存在');
    }

    const existing = await this.followRepository.findOne({
      where: { followerId, followingId },
    });

    if (existing) {
      return { message: '已关注' };
    }

    const follow = this.followRepository.create({ followerId, followingId });
    await this.followRepository.save(follow);

    return { message: '关注成功' };
  }

  async unfollowUser(followerId: string, followingId: string) {
    await this.followRepository.delete({ followerId, followingId });
    return { message: '取消关注成功' };
  }

  async getFollowers(userId: string, page: number = 1, pageSize: number = 20) {
    const skip = (page - 1) * pageSize;

    const [followers, total] = await this.followRepository.findAndCount({
      where: { followingId: userId },
      relations: ['follower'],
      skip,
      take: pageSize,
    });

    const users = followers.map(f => ({
      id: f.follower?.id,
      username: f.follower?.username,
      avatar: f.follower?.avatar,
      followedAt: f.createdAt,
    }));

    return {
      list: users,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async getFollowing(userId: string, page: number = 1, pageSize: number = 20) {
    const skip = (page - 1) * pageSize;

    const [following, total] = await this.followRepository.findAndCount({
      where: { followerId: userId },
      relations: ['following'],
      skip,
      take: pageSize,
    });

    const users = following.map(f => ({
      id: f.following?.id,
      username: f.following?.username,
      avatar: f.following?.avatar,
      followedAt: f.createdAt,
    }));

    return {
      list: users,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async isFollowing(followerId: string, followingId: string) {
    const follow = await this.followRepository.findOne({
      where: { followerId, followingId },
    });
    return { isFollowing: !!follow };
  }

  async createDynamic(userId: string, dto: CreateDynamicDto) {
    const dynamic = this.dynamicRepository.create({
      userId,
      ...dto,
      images: JSON.stringify(dto.images || []),
    });

    await this.dynamicRepository.save(dynamic);

    return dynamic;
  }

  async getUserDynamics(userId: string, page: number = 1, pageSize: number = 20) {
    const skip = (page - 1) * pageSize;

    const [dynamics, total] = await this.dynamicRepository.findAndCount({
      where: { userId, isPublic: true },
      order: { createdAt: 'DESC' },
      skip,
      take: pageSize,
    });

    return {
      list: dynamics.map(d => ({
        ...d,
        images: d.images ? JSON.parse(d.images) : [],
      })),
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async getFeed(userId: string, page: number = 1, pageSize: number = 20) {
    // 获取用户关注的人的动态
    const following = await this.followRepository.find({
      where: { followerId: userId },
      select: ['followingId'],
    });

    const followingIds = following.map(f => f.followingId);

    if (followingIds.length === 0) {
      return { list: [], pagination: { page, pageSize, total: 0, totalPages: 0 } };
    }

    const skip = (page - 1) * pageSize;

    const [dynamics, total] = await this.dynamicRepository.findAndCount({
      where: [
        { userId: followingIds.length === 1 ? followingIds[0] : undefined } as any,
      ],
      order: { createdAt: 'DESC' },
      skip,
      take: pageSize,
    });

    return {
      list: dynamics.map(d => ({
        ...d,
        images: d.images ? JSON.parse(d.images) : [],
      })),
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async likeDynamic(userId: string, dynamicId: string) {
    const existing = await this.dynamicLikeRepository.findOne({
      where: { userId, dynamicId },
    });

    if (existing) {
      return { message: '已点赞' };
    }

    const like = this.dynamicLikeRepository.create({ userId, dynamicId });
    await this.dynamicLikeRepository.save(like);

    // 更新动态点赞数
    await this.dynamicRepository.increment({ id: dynamicId }, 'likes', 1);

    return { message: '点赞成功' };
  }

  async unlikeDynamic(userId: string, dynamicId: string) {
    await this.dynamicLikeRepository.delete({ userId, dynamicId });
    await this.dynamicRepository.decrement({ id: dynamicId }, 'likes', 1);
    return { message: '取消点赞' };
  }

  async createComment(userId: string, dto: CreateCommentDto) {
    const comment = this.commentRepository.create({
      userId,
      ...dto,
    });

    await this.commentRepository.save(comment);

    // 更新关联统计
    if (dto.bookId) {
      // TODO: 更新书籍评论数
    }

    return comment;
  }

  async getComments(targetType: 'book' | 'chapter' | 'dynamic', targetId: string, page: number = 1, pageSize: number = 20) {
    const where: any = { isDeleted: false };
    if (targetType === 'book') where.bookId = targetId;
    if (targetType === 'chapter') where.chapterId = targetId;
    if (targetType === 'dynamic') where.dynamicId = targetId;
    where.parentId = undefined; // 只获取顶级评论

    const skip = (page - 1) * pageSize;

    const [comments, total] = await this.commentRepository.findAndCount({
      where,
      relations: ['user'],
      order: { createdAt: 'DESC' },
      skip,
      take: pageSize,
    });

    // 获取回复
    const commentIds = comments.map(c => c.id);
    const replies = await this.commentRepository.find({
      where: { parentId: In(commentIds), isDeleted: false },
      relations: ['user'],
      order: { createdAt: 'ASC' },
    });

    const commentsWithReplies = comments.map(c => ({
      ...c,
      user: c.user ? { id: c.user.id, username: c.user.username, avatar: c.user.avatar } : null,
      replies: replies.filter(r => r.parentId === c.id).map(r => ({
        ...r,
        user: r.user ? { id: r.user.id, username: r.user.username, avatar: r.user.avatar } : null,
      })),
    }));

    return {
      list: commentsWithReplies,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async deleteComment(userId: string, commentId: string) {
    const comment = await this.commentRepository.findOne({
      where: { id: commentId, userId },
    });

    if (!comment) {
      throw new NotFoundException('评论不存在');
    }

    comment.isDeleted = true;
    comment.deletedAt = new Date();
    await this.commentRepository.save(comment);

    return { message: '评论已删除' };
  }

  async likeComment(userId: string, commentId: string) {
    const existing = await this.commentLikeRepository.findOne({
      where: { userId, commentId },
    });

    if (existing) {
      return { message: '已点赞' };
    }

    const like = this.commentLikeRepository.create({ userId, commentId });
    await this.commentLikeRepository.save(like);
    await this.commentRepository.increment({ id: commentId }, 'likes', 1);

    return { message: '点赞成功' };
  }

  async createBooklist(userId: string, dto: CreateBooklistDto) {
    const booklist = this.booklistRepository.create({
      userId,
      ...dto,
    });

    await this.booklistRepository.save(booklist);

    return booklist;
  }

  async getMyBooklists(userId: string) {
    return this.booklistRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async getPublicBooklists(page: number = 1, pageSize: number = 20) {
    const skip = (page - 1) * pageSize;

    const [booklists, total] = await this.booklistRepository.findAndCount({
      where: { isPublic: true },
      relations: ['user'],
      order: { followers: 'DESC', createdAt: 'DESC' },
      skip,
      take: pageSize,
    });

    return {
      list: booklists.map(bl => ({
        ...bl,
        user: bl.user ? { id: bl.user.id, username: bl.user.username, avatar: bl.user.avatar } : null,
      })),
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async addBookToBooklist(userId: string, booklistId: string, bookId: string, note?: string) {
    const booklist = await this.booklistRepository.findOne({
      where: { id: booklistId, userId },
    });

    if (!booklist) {
      throw new NotFoundException('书单不存在');
    }

    const existing = await this.booklistBookRepository.findOne({
      where: { booklistId, bookId },
    });

    if (existing) {
      return { message: '书籍已在书单中' };
    }

    const maxOrder = await this.booklistBookRepository
      .createQueryBuilder('bb')
      .where('bb.booklistId = :booklistId', { booklistId })
      .select('MAX(bb.sortOrder)', 'max')
      .getRawOne();

    const booklistBook = this.booklistBookRepository.create({
      booklistId,
      bookId,
      note,
      sortOrder: (maxOrder?.max || 0) + 1,
    });

    await this.booklistBookRepository.save(booklistBook);

    // 更新书单书籍数
    await this.booklistRepository.increment({ id: booklistId }, 'books', 1);

    return { message: '添加成功' };
  }

  async removeBookFromBooklist(userId: string, booklistId: string, bookId: string) {
    await this.booklistBookRepository.delete({ booklistId, bookId });
    await this.booklistRepository.decrement({ id: booklistId }, 'books', 1);
    return { message: '移除成功' };
  }

  async getBooklistBooks(booklistId: string, page: number = 1, pageSize: number = 20) {
    const skip = (page - 1) * pageSize;

    const [books, total] = await this.booklistBookRepository.findAndCount({
      where: { booklistId },
      order: { sortOrder: 'ASC' },
      skip,
      take: pageSize,
    });

    return {
      list: books,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }
}
