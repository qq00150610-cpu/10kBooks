import {
  Controller,
  Get,
  Post,
  Patch,
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
} from '@nestjs/swagger';
import { ReaderService, UpdateProgressDto, CreateBookmarkDto, CreateNoteDto } from './reader.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('阅读器')
@ApiGroup('reader')
@Controller({ path: 'reader', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ReaderController {
  constructor(private readonly readerService: ReaderService) {}

  @Get('progress/:bookId')
  @ApiOperation({ summary: '获取阅读进度' })
  async getProgress(@UserId() userId: string, @Param('bookId') bookId: string) {
    return this.readerService.getReadingProgress(userId, bookId);
  }

  @Post('progress')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '更新阅读进度' })
  async updateProgress(@UserId() userId: string, @Body() dto: UpdateProgressDto) {
    return this.readerService.updateReadingProgress(userId, dto);
  }

  @Get('bookmarks')
  @ApiOperation({ summary: '获取书签列表' })
  async getBookmarks(@UserId() userId: string, @Query('bookId') bookId?: string) {
    return this.readerService.getBookmarks(userId, bookId);
  }

  @Post('bookmarks')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '创建书签' })
  async createBookmark(@UserId() userId: string, @Body() dto: CreateBookmarkDto) {
    return this.readerService.createBookmark(userId, dto);
  }

  @Patch('bookmarks/:id')
  @ApiOperation({ summary: '更新书签' })
  async updateBookmark(
    @UserId() userId: string,
    @Param('id') id: string,
    @Body() dto: Partial<CreateBookmarkDto>,
  ) {
    return this.readerService.updateBookmark(userId, id, dto);
  }

  @Delete('bookmarks/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除书签' })
  async deleteBookmark(@UserId() userId: string, @Param('id') id: string) {
    return this.readerService.deleteBookmark(userId, id);
  }

  @Get('notes')
  @ApiOperation({ summary: '获取笔记列表' })
  async getNotes(@UserId() userId: string, @Query('bookId') bookId?: string) {
    return this.readerService.getNotes(userId, bookId);
  }

  @Post('notes')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '创建笔记' })
  async createNote(@UserId() userId: string, @Body() dto: CreateNoteDto) {
    return this.readerService.createNote(userId, dto);
  }

  @Patch('notes/:id')
  @ApiOperation({ summary: '更新笔记' })
  async updateNote(
    @UserId() userId: string,
    @Param('id') id: string,
    @Body() dto: Partial<CreateNoteDto>,
  ) {
    return this.readerService.updateNote(userId, id, dto);
  }

  @Delete('notes/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除笔记' })
  async deleteNote(@UserId() userId: string, @Param('id') id: string) {
    return this.readerService.deleteNote(userId, id);
  }

  @Post('notes/:id/share')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '分享笔记' })
  async shareNote(@UserId() userId: string, @Param('id') id: string) {
    return this.readerService.shareNote(userId, id);
  }

  @Get('history')
  @ApiOperation({ summary: '获取阅读历史' })
  async getReadingHistory(
    @UserId() userId: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.readerService.getReadingHistory(userId, page, pageSize);
  }

  @Get('stats')
  @ApiOperation({ summary: '获取阅读统计' })
  async getReadingStats(@UserId() userId: string) {
    return this.readerService.getReadingStats(userId);
  }

  @Post('session/start')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '开始阅读会话' })
  async startSession(
    @UserId() userId: string,
    @Body('bookId') bookId: string,
    @Body('chapterId') chapterId?: string,
  ) {
    return this.readerService.startReadingSession(userId, bookId, chapterId);
  }

  @Post('session/:id/end')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '结束阅读会话' })
  async endSession(@UserId() userId: string, @Param('id') id: string) {
    return this.readerService.endReadingSession(userId, id);
  }

  @Get('offline/:bookId')
  @ApiOperation({ summary: '获取离线章节' })
  async getOfflineChapters(@UserId() userId: string, @Param('bookId') bookId: string) {
    return this.readerService.getOfflineChapters(userId, bookId);
  }

  @Post('offline')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '缓存章节' })
  async cacheChapter(
    @UserId() userId: string,
    @Body('bookId') bookId: string,
    @Body('chapterId') chapterId: string,
    @Body('content') content: string,
  ) {
    return this.readerService.cacheChapter(userId, bookId, chapterId, content);
  }

  @Delete('offline')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '清除离线缓存' })
  async clearOfflineCache(@UserId() userId: string, @Query('bookId') bookId?: string) {
    return this.readerService.clearOfflineCache(userId, bookId);
  }
}
