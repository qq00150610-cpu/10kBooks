import { Controller, Get, Post, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AiService, SummarizeDto, TranslateDto, ChatDto, WritingAssistDto } from './ai.service';
import { JwtAuthGuard, AuthorOnly } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('AI功能')
@ApiGroup('ai')
@Controller({ path: 'ai', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('summarize')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'AI内容摘要' })
  async summarize(@UserId() userId: string, @Body() dto: SummarizeDto) {
    return this.aiService.summarize(userId, dto);
  }

  @Post('translate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'AI多语言翻译' })
  async translate(@UserId() userId: string, @Body() dto: TranslateDto) {
    return this.aiService.translate(userId, dto);
  }

  @Post('chat')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'AI智能问答' })
  async chat(@UserId() userId: string, @Body() dto: ChatDto) {
    return this.aiService.chat(userId, dto);
  }

  @Get('chats')
  @ApiOperation({ summary: '获取对话历史' })
  async getChats(@UserId() userId: string) {
    // TODO: 实现获取对话历史
    return [];
  }

  @Post('writing-assist')
  @UseGuards(AuthorOnly)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'AI写作辅助' })
  async writingAssist(@UserId() userId: string, @Body() dto: WritingAssistDto) {
    return this.aiService.writingAssist(userId, dto);
  }

  @Post('check-content')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'AI内容检测' })
  async checkContent(@UserId() userId: string, @Body() data: { content: string; checkType: 'sensitive' | 'quality' | 'copyright' }) {
    return this.aiService.checkContent(userId, data.content, data.checkType);
  }

  @Get('recommendations')
  @ApiOperation({ summary: '获取推荐书籍' })
  async getRecommendations(@UserId() userId: string, @Query('bookId') bookId?: string, @Query('limit') limit?: number) {
    return this.aiService.getRecommendations(userId, bookId, limit);
  }
}
