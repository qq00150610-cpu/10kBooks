import {
  Controller, Get, Post, Delete, Patch, Param, Query, Body, UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SocialService, CreateDynamicDto, CreateCommentDto, CreateBooklistDto } from './social.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('社交')
@ApiGroup('social')
@Controller({ path: 'social', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SocialController {
  constructor(private readonly socialService: SocialService) {}

  @Post('follow/:userId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '关注用户' })
  async followUser(@UserId() userId: string, @Param('userId') targetUserId: string) {
    return this.socialService.followUser(userId, targetUserId);
  }

  @Delete('follow/:userId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '取消关注' })
  async unfollowUser(@UserId() userId: string, @Param('userId') targetUserId: string) {
    return this.socialService.unfollowUser(userId, targetUserId);
  }

  @Get('followers/:userId')
  @ApiOperation({ summary: '获取粉丝列表' })
  async getFollowers(@Param('userId') userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.socialService.getFollowers(userId, page, pageSize);
  }

  @Get('following/:userId')
  @ApiOperation({ summary: '获取关注列表' })
  async getFollowing(@Param('userId') userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.socialService.getFollowing(userId, page, pageSize);
  }

  @Get('is-following/:userId')
  @ApiOperation({ summary: '检查是否关注' })
  async isFollowing(@UserId() userId: string, @Param('userId') targetUserId: string) {
    return this.socialService.isFollowing(userId, targetUserId);
  }

  @Post('dynamics')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '发布动态' })
  async createDynamic(@UserId() userId: string, @Body() dto: CreateDynamicDto) {
    return this.socialService.createDynamic(userId, dto);
  }

  @Get('dynamics/me')
  @ApiOperation({ summary: '获取我的动态' })
  async getMyDynamics(@UserId() userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.socialService.getUserDynamics(userId, page, pageSize);
  }

  @Get('dynamics/user/:userId')
  @ApiOperation({ summary: '获取用户动态' })
  async getUserDynamics(@Param('userId') userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.socialService.getUserDynamics(userId, page, pageSize);
  }

  @Get('feed')
  @ApiOperation({ summary: '获取动态Feed' })
  async getFeed(@UserId() userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.socialService.getFeed(userId, page, pageSize);
  }

  @Post('dynamics/:dynamicId/like')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '点赞动态' })
  async likeDynamic(@UserId() userId: string, @Param('dynamicId') dynamicId: string) {
    return this.socialService.likeDynamic(userId, dynamicId);
  }

  @Delete('dynamics/:dynamicId/like')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '取消点赞' })
  async unlikeDynamic(@UserId() userId: string, @Param('dynamicId') dynamicId: string) {
    return this.socialService.unlikeDynamic(userId, dynamicId);
  }

  @Post('comments')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '发表评论' })
  async createComment(@UserId() userId: string, @Body() dto: CreateCommentDto) {
    return this.socialService.createComment(userId, dto);
  }

  @Get('comments')
  @ApiOperation({ summary: '获取评论列表' })
  async getComments(
    @Query('type') type: 'book' | 'chapter' | 'dynamic',
    @Query('targetId') targetId: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.socialService.getComments(type, targetId, page, pageSize);
  }

  @Delete('comments/:commentId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除评论' })
  async deleteComment(@UserId() userId: string, @Param('commentId') commentId: string) {
    return this.socialService.deleteComment(userId, commentId);
  }

  @Post('comments/:commentId/like')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '点赞评论' })
  async likeComment(@UserId() userId: string, @Param('commentId') commentId: string) {
    return this.socialService.likeComment(userId, commentId);
  }

  @Post('booklists')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '创建书单' })
  async createBooklist(@UserId() userId: string, @Body() dto: CreateBooklistDto) {
    return this.socialService.createBooklist(userId, dto);
  }

  @Get('booklists/me')
  @ApiOperation({ summary: '获取我的书单' })
  async getMyBooklists(@UserId() userId: string) {
    return this.socialService.getMyBooklists(userId);
  }

  @Get('booklists/public')
  @ApiOperation({ summary: '获取公开书单' })
  async getPublicBooklists(@Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.socialService.getPublicBooklists(page, pageSize);
  }

  @Get('booklists/:id')
  @ApiOperation({ summary: '获取书单详情' })
  async getBooklistDetail(@Param('id') id: string) {
    return this.socialService.getBooklistBooks(id);
  }

  @Post('booklists/:id/books')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '添加书籍到书单' })
  async addBookToBooklist(@UserId() userId: string, @Param('id') id: string, @Body('bookId') bookId: string, @Body('note') note?: string) {
    return this.socialService.addBookToBooklist(userId, id, bookId, note);
  }

  @Delete('booklists/:id/books/:bookId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '从书单移除书籍' })
  async removeBookFromBooklist(@UserId() userId: string, @Param('id') id: string, @Param('bookId') bookId: string) {
    return this.socialService.removeBookFromBooklist(userId, id, bookId);
  }
}
