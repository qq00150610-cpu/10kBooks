import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReviewService, ReviewDto, ReportDto } from './review.service';
import { JwtAuthGuard, AdminOnly } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('审核')
@ApiGroup('review')
@Controller({ path: 'review', version: '1' })
export class ReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @Get('tasks/pending')
  @UseGuards(JwtAuthGuard, AdminOnly)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取待审核任务' })
  async getPendingTasks(@Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.reviewService.getPendingTasks(page, pageSize);
  }

  @Patch('tasks/:taskId')
  @UseGuards(JwtAuthGuard, AdminOnly)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: '审核任务' })
  async reviewTask(@UserId() userId: string, @Param('taskId') taskId: string, @Body() dto: ReviewDto) {
    return this.reviewService.reviewTask(userId, taskId, dto);
  }

  @Post('reports')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiBearerAuth()
  @ApiOperation({ summary: '提交举报' })
  async createReport(@UserId() userId: string, @Body() dto: ReportDto) {
    return this.reviewService.createReport(userId, dto);
  }

  @Get('reports/me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取我的举报记录' })
  async getMyReports(@UserId() userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.reviewService.getMyReports(userId, page, pageSize);
  }

  @Get('sensitive-words')
  @UseGuards(JwtAuthGuard, AdminOnly)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取敏感词列表' })
  async getSensitiveWords() {
    return this.reviewService.getSensitiveWords();
  }

  @Post('sensitive-words')
  @UseGuards(JwtAuthGuard, AdminOnly)
  @HttpCode(HttpStatus.CREATED)
  @ApiBearerAuth()
  @ApiOperation({ summary: '添加敏感词' })
  async addSensitiveWord(@Body() data: { word: string; level: number; category?: string; replacement?: string }) {
    return this.reviewService.addSensitiveWord(data.word, data.level, data.category, data.replacement);
  }

  @Delete('sensitive-words/:id')
  @UseGuards(JwtAuthGuard, AdminOnly)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: '删除敏感词' })
  async deleteSensitiveWord(@Param('id') id: string) {
    return this.reviewService.deleteSensitiveWord(id);
  }
}
