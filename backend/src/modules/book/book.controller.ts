import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Query,
  Body,
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
import { BookService, SearchBookDto } from './book.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { Public } from '../../common/decorators/auth.decorators';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('书籍')
@ApiGroup('book')
@Controller({ path: 'books', version: '1' })
export class BookController {
  constructor(private readonly bookService: BookService) {}

  @Get('search')
  @ApiOperation({ summary: '搜索书籍' })
  @ApiResponse({ status: 200, description: '搜索结果' })
  async searchBooks(@Query() dto: SearchBookDto) {
    return this.bookService.searchBooks(dto);
  }

  @Get('hot')
  @ApiOperation({ summary: '获取热门书籍' })
  async getHotBooks(@Query('limit') limit?: number) {
    return this.bookService.getHotBooks(limit);
  }

  @Get('new')
  @ApiOperation({ summary: '获取最新书籍' })
  async getNewBooks(@Query('limit') limit?: number) {
    return this.bookService.getNewBooks(limit);
  }

  @Get('recommended')
  @ApiOperation({ summary: '获取推荐书籍' })
  async getRecommendedBooks(
    @UserId() userId?: string,
    @Query('limit') limit?: number,
  ) {
    return this.bookService.getRecommendedBooks(userId, limit);
  }

  @Get('categories')
  @ApiOperation({ summary: '获取书籍分类' })
  async getCategories() {
    return this.bookService.getCategories();
  }

  @Get('tags')
  @ApiOperation({ summary: '获取热门标签' })
  async getTags(@Query('limit') limit?: number) {
    return this.bookService.getTags(limit);
  }

  @Get(':id')
  @ApiOperation({ summary: '获取书籍详情' })
  async getBookDetail(
    @Param('id') id: string,
    @UserId() userId?: string,
  ) {
    return this.bookService.getBookDetail(id, userId);
  }

  @Get(':bookId/chapters')
  @ApiOperation({ summary: '获取书籍章节列表' })
  async getBookChapters(
    @Param('bookId') bookId: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.bookService.getBookChapters(bookId, page, pageSize);
  }

  @Get(':bookId/chapters/:chapterId')
  @ApiOperation({ summary: '获取章节内容' })
  async getChapterContent(
    @Param('bookId') bookId: string,
    @Param('chapterId') chapterId: string,
    @UserId() userId?: string,
  ) {
    return this.bookService.getChapterContent(bookId, chapterId, userId);
  }

  @Post(':bookId/collect')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: '收藏书籍' })
  async collectBook(
    @Param('bookId') bookId: string,
    @UserId() userId: string,
    @Body('note') note?: string,
  ) {
    return this.bookService.collectBook(userId, bookId, note);
  }

  @Delete(':bookId/collect')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: '取消收藏' })
  async uncollectBook(@Param('bookId') bookId: string, @UserId() userId: string) {
    return this.bookService.uncollectBook(userId, bookId);
  }

  @Get('me/collections')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取我的收藏' })
  async getMyCollections(
    @UserId() userId: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.bookService.getMyCollections(userId, page, pageSize);
  }

  @Post(':bookId/rate')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: '评分书籍' })
  async rateBook(
    @Param('bookId') bookId: string,
    @UserId() userId: string,
    @Body('score') score: number,
    @Body('content') content?: string,
  ) {
    return this.bookService.rateBook(userId, bookId, score, content);
  }
}
