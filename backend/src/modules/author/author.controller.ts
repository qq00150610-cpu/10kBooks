import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
} from '@nestjs/swagger';
import { AuthorService, ApplyAuthorDto, CreateBookDto, UpdateBookDto, CreateChapterDto, UpdateChapterDto } from './author.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('作者')
@ApiGroup('author')
@Controller({ path: 'author', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AuthorController {
  constructor(private readonly authorService: AuthorService) {}

  @Post('apply')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '申请成为作者' })
  async applyForAuthor(@UserId() userId: string, @Body() dto: ApplyAuthorDto) {
    return this.authorService.applyForAuthor(userId, dto);
  }

  @Get('application')
  @ApiOperation({ summary: '获取作者申请状态' })
  async getAuthorApplication(@UserId() userId: string) {
    return this.authorService.getAuthorApplication(userId);
  }

  @Post('books')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '创建书籍' })
  async createBook(@UserId() userId: string, @Body() dto: CreateBookDto) {
    return this.authorService.createBook(userId, dto);
  }

  @Get('books')
  @ApiOperation({ summary: '获取我的书籍列表' })
  async getMyBooks(
    @UserId() userId: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.authorService.getMyBooks(userId, page, pageSize);
  }

  @Get('books/:bookId')
  @ApiOperation({ summary: '获取书籍详情' })
  async getBook(@UserId() userId: string, @Param('bookId') bookId: string) {
    // 复用作者获取单本书籍逻辑
    const books = await this.authorService.getMyBooks(userId, 1, 100);
    const book = books.list.find(b => b.id === bookId);
    if (!book) throw new Error('书籍不存在');
    return book;
  }

  @Patch('books/:bookId')
  @ApiOperation({ summary: '更新书籍' })
  async updateBook(
    @UserId() userId: string,
    @Param('bookId') bookId: string,
    @Body() dto: UpdateBookDto,
  ) {
    return this.authorService.updateBook(userId, bookId, dto);
  }

  @Delete('books/:bookId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除书籍' })
  async deleteBook(@UserId() userId: string, @Param('bookId') bookId: string) {
    return this.authorService.deleteBook(userId, bookId);
  }

  @Post('books/:bookId/chapters')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '创建章节' })
  async createChapter(
    @UserId() userId: string,
    @Param('bookId') bookId: string,
    @Body() dto: CreateChapterDto,
  ) {
    return this.authorService.createChapter(userId, bookId, dto);
  }

  @Post('books/:bookId/chapters/batch')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '批量创建章节' })
  async batchCreateChapters(
    @UserId() userId: string,
    @Param('bookId') bookId: string,
    @Body('chapters') chapters: CreateChapterDto[],
  ) {
    return this.authorService.batchCreateChapters(userId, bookId, chapters);
  }

  @Get('books/:bookId/chapters')
  @ApiOperation({ summary: '获取书籍章节列表' })
  async getBookChapters(
    @UserId() userId: string,
    @Param('bookId') bookId: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.authorService.getBookChapters(userId, bookId, page, pageSize);
  }

  @Patch('chapters/:chapterId')
  @ApiOperation({ summary: '更新章节' })
  async updateChapter(
    @UserId() userId: string,
    @Param('chapterId') chapterId: string,
    @Body() dto: UpdateChapterDto,
  ) {
    return this.authorService.updateChapter(userId, chapterId, dto);
  }

  @Delete('chapters/:chapterId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除章节' })
  async deleteChapter(@UserId() userId: string, @Param('chapterId') chapterId: string) {
    return this.authorService.deleteChapter(userId, chapterId);
  }

  @Post('chapters/:chapterId/publish')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '发布章节' })
  async publishChapter(@UserId() userId: string, @Param('chapterId') chapterId: string) {
    return this.authorService.publishChapter(userId, chapterId);
  }

  @Get('earnings')
  @ApiOperation({ summary: '获取收益统计' })
  async getEarnings(
    @UserId() userId: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.authorService.getEarnings(userId, page, pageSize);
  }
}
