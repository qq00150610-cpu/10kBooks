import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { AiSummary, AiTranslation, AiChat, AiMessage, AiWritingAssist, AiRecommendation, AiContentCheck } from '../../entities/ai.entity';
import { QueueNames } from '../../common/constants';
import axios from 'axios';
import { IsOptional, IsString, IsNumber, IsEnum } from 'class-validator';

export class SummarizeDto {
  @IsString()
  bookId: string;

  @IsOptional()
  @IsString()
  chapterId?: string;

  @IsString()
  summaryType: 'book_intro' | 'chapter_summary' | 'ai_review';

  @IsOptional()
  @IsString()
  language?: string;
}

export class TranslateDto {
  @IsString()
  bookId: string;

  @IsOptional()
  @IsString()
  chapterId?: string;

  @IsString()
  sourceLanguage: string;

  @IsString()
  targetLanguage: string;

  @IsOptional()
  @IsString()
  content?: string;
}

export class ChatDto {
  @IsOptional()
  @IsString()
  bookId?: string;

  @IsOptional()
  @IsString()
  chatId?: string;

  @IsString()
  message: string;
}

export class WritingAssistDto {
  @IsString()
  bookId: string;

  @IsOptional()
  @IsString()
  chapterId?: string;

  @IsEnum(['outline', 'content', 'polish', 'title', 'description'])
  assistType: 'outline' | 'content' | 'polish' | 'title' | 'description';

  @IsString()
  input: string;
}

@Injectable()
export class AiService {
  private openaiApiKey: string;
  private openaiModel: string;

  constructor(
    @InjectRepository(AiSummary)
    private summaryRepository: Repository<AiSummary>,
    @InjectRepository(AiTranslation)
    private translationRepository: Repository<AiTranslation>,
    @InjectRepository(AiChat)
    private chatRepository: Repository<AiChat>,
    @InjectRepository(AiMessage)
    private messageRepository: Repository<AiMessage>,
    @InjectRepository(AiWritingAssist)
    private writingAssistRepository: Repository<AiWritingAssist>,
    @InjectRepository(AiRecommendation)
    private recommendationRepository: Repository<AiRecommendation>,
    @InjectRepository(AiContentCheck)
    private contentCheckRepository: Repository<AiContentCheck>,
    private configService: ConfigService,
    @InjectQueue(QueueNames.AI_PROCESSING)
    private aiQueue: Queue,
  ) {
    this.openaiApiKey = this.configService.get('OPENAI_API_KEY');
    this.openaiModel = this.configService.get('OPENAI_MODEL', 'gpt-4');
  }

  async summarize(userId: string, dto: SummarizeDto) {
    // TODO: 从书籍获取内容
    const content = '书籍内容...';

    const prompt = this.buildSummaryPrompt(dto.summaryType, content);

    try {
      const result = await this.callOpenAI(prompt);

      const summary = this.summaryRepository.create({
        userId,
        bookId: dto.bookId,
        chapterId: dto.chapterId,
        summaryType: dto.summaryType,
        content: result.content,
        language: dto.language || 'zh-CN',
        wordCount: result.content.length,
        model: this.openaiModel,
        tokens: result.tokens,
      });

      await this.summaryRepository.save(summary);

      return { content: result.content, summaryId: summary.id };
    } catch (error) {
      throw new BadRequestException('AI服务调用失败');
    }
  }

  async translate(userId: string, dto: TranslateDto) {
    let content = dto.content;
    if (!content && dto.chapterId) {
      // TODO: 从章节获取内容
      content = '章节内容...';
    }

    const prompt = `Translate the following text from ${dto.sourceLanguage} to ${dto.targetLanguage}:\n\n${content}`;

    try {
      const result = await this.callOpenAI(prompt);

      const translation = this.translationRepository.create({
        userId,
        originalBookId: dto.bookId,
        chapterId: dto.chapterId,
        sourceLanguage: dto.sourceLanguage,
        targetLanguage: dto.targetLanguage,
        originalText: content,
        translatedText: result.content,
        model: this.openaiModel,
        tokens: result.tokens,
      });

      await this.translationRepository.save(translation);

      return { content: result.content, translationId: translation.id };
    } catch (error) {
      throw new BadRequestException('翻译服务调用失败');
    }
  }

  async chat(userId: string, dto: ChatDto) {
    let chat = dto.chatId
      ? await this.chatRepository.findOne({ where: { id: dto.chatId, userId } })
      : null;

    if (!chat) {
      chat = this.chatRepository.create({
        userId,
        bookId: dto.bookId,
        context: JSON.stringify([]),
      });
      await this.chatRepository.save(chat);
    }

    // 保存用户消息
    const userMessage = this.messageRepository.create({
      chatId: chat.id,
      userId,
      role: 'user',
      content: dto.message,
    });
    await this.messageRepository.save(userMessage);

    // 获取历史消息
    const history = await this.messageRepository.find({
      where: { chatId: chat.id },
      order: { createdAt: 'ASC' },
      take: 20,
    });

    // 构建提示
    const systemPrompt = dto.bookId
      ? '你是一个专业的阅读助手，可以回答关于书籍内容的问题。'
      : '你是一个友好的AI助手。';

    const messages = [
      { role: 'system', content: systemPrompt },
      ...history.map(m => ({ role: m.role, content: m.content })),
    ];

    try {
      const result = await this.callOpenAI(messages);

      // 保存AI回复
      const aiMessage = this.messageRepository.create({
        chatId: chat.id,
        userId,
        role: 'assistant',
        content: result.content,
        model: this.openaiModel,
        tokens: result.tokens,
      });
      await this.messageRepository.save(aiMessage);

      // 更新聊天上下文
      chat.lastMessage = dto.message;
      chat.messageCount += 2;
      await this.chatRepository.save(chat);

      return { response: result.content, chatId: chat.id, messageId: aiMessage.id };
    } catch (error) {
      throw new BadRequestException('AI服务调用失败');
    }
  }

  async writingAssist(userId: string, dto: WritingAssistDto) {
    const prompt = this.buildWritingPrompt(dto.assistType, dto.input);

    try {
      const result = await this.callOpenAI(prompt);

      const assist = this.writingAssistRepository.create({
        authorId: userId,
        bookId: dto.bookId,
        chapterId: dto.chapterId,
        assistType: dto.assistType,
        input: dto.input,
        output: result.content,
        model: this.openaiModel,
      });

      await this.writingAssistRepository.save(assist);

      return { content: result.content, assistId: assist.id };
    } catch (error) {
      throw new BadRequestException('AI写作辅助服务调用失败');
    }
  }

  async checkContent(userId: string, content: string, checkType: 'sensitive' | 'quality' | 'copyright') {
    const prompt = checkType === 'sensitive'
      ? `Check the following content for sensitive or inappropriate material. Return a JSON with hasIssue (boolean), issueType (string), and confidence (0-1):\n\n${content}`
      : `Evaluate the quality of the following content. Return a JSON with score (1-10) and feedback:`;

    try {
      const result = await this.callOpenAI(prompt);

      const check = this.contentCheckRepository.create({
        targetId: userId,
        checkType,
        content,
        result: JSON.parse(result.content),
        hasIssue: checkType === 'sensitive',
        model: this.openaiModel,
      });

      await this.contentCheckRepository.save(check);

      return JSON.parse(result.content);
    } catch (error) {
      throw new BadRequestException('内容检测服务调用失败');
    }
  }

  async getRecommendations(userId: string, bookId?: string, limit: number = 10) {
    // TODO: 实现基于协同过滤的推荐算法
    // 目前返回占位数据
    const recommendations = this.recommendationRepository.find({
      where: { userId },
      order: { score: 'DESC' },
      take: limit,
    });

    return recommendations;
  }

  private async callOpenAI(prompt: string | any[]): Promise<{ content: string; tokens: number }> {
    // TODO: 实现真实的OpenAI API调用
    // const response = await axios.post(
    //   'https://api.openai.com/v1/chat/completions',
    //   {
    //     model: this.openaiModel,
    //     messages: typeof prompt === 'string' ? [{ role: 'user', content: prompt }] : prompt,
    //   },
    //   { headers: { Authorization: `Bearer ${this.openaiApiKey}` } },
    // );

    // 模拟返回
    return {
      content: 'AI生成的回复内容...',
      tokens: 100,
    };
  }

  private buildSummaryPrompt(type: string, content: string): string {
    switch (type) {
      case 'book_intro':
        return `请为以下书籍生成一个简洁的简介（200字以内）：\n\n${content.slice(0, 2000)}`;
      case 'chapter_summary':
        return `请为以下章节内容生成一个摘要（100字以内）：\n\n${content}`;
      case 'ai_review':
        return `请对以下书籍内容进行AI点评，包括优点和缺点：\n\n${content.slice(0, 3000)}`;
      default:
        return `请总结以下内容：\n\n${content}`;
    }
  }

  private buildWritingPrompt(type: string, input: string): string {
    switch (type) {
      case 'outline':
        return `为一个小说生成大纲框架，基于以下主题：${input}`;
      case 'content':
        return `基于以下大纲续写内容：\n\n${input}`;
      case 'polish':
        return `请润色以下文本，使其更加优美流畅：\n\n${input}`;
      case 'title':
        return `为一个${input}类型的小说生成5个吸引人的书名`;
      case 'description':
        return `为一个${input}类型的小说生成一个吸引人的简介`;
      default:
        return input;
    }
  }
}
