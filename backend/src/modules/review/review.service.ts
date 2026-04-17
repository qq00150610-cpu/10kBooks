import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { ReviewTask, ReviewLog, SensitiveWord, CopyrightCheck, Report, ReviewType, ReviewStatus } from '../../entities/review.entity';
import { QueueNames } from '../../common/constants';
import { IsOptional, IsString, IsNumber } from 'class-validator';

export class ReviewDto {
  @IsString()
  action: 'approve' | 'reject' | 'need_modify';

  @IsOptional()
  @IsString()
  reason?: string;
}

export class ReportDto {
  @IsOptional()
  @IsString()
  reportedUserId?: string;

  @IsOptional()
  @IsString()
  bookId?: string;

  @IsOptional()
  @IsString()
  commentId?: string;

  @IsString()
  reason: string;

  @IsOptional()
  @IsString()
  description?: string;
}

@Injectable()
export class ReviewService {
  constructor(
    @InjectRepository(ReviewTask)
    private taskRepository: Repository<ReviewTask>,
    @InjectRepository(ReviewLog)
    private logRepository: Repository<ReviewLog>,
    @InjectRepository(SensitiveWord)
    private wordRepository: Repository<SensitiveWord>,
    @InjectRepository(CopyrightCheck)
    private copyrightRepository: Repository<CopyrightCheck>,
    @InjectRepository(Report)
    private reportRepository: Repository<Report>,
    @InjectQueue(QueueNames.REVIEW_AUTO_CHECK)
    private reviewQueue: Queue,
  ) {}

  async createReviewTask(reviewerId: string, type: ReviewType, targetId: string, bookId?: string) {
    const task = this.taskRepository.create({
      reviewerId,
      reviewType: type,
      targetId,
      bookId,
      status: ReviewStatus.PENDING,
    });

    await this.taskRepository.save(task);

    // 添加到自动审核队列
    await this.reviewQueue.add('auto-check', { taskId: task.id });

    return task;
  }

  async autoCheckContent(taskId: string) {
    const task = await this.taskRepository.findOne({ where: { id: taskId } });
    if (!task) throw new NotFoundException('审核任务不存在');

    // 敏感词检测
    const sensitiveResult = await this.checkSensitiveWords(task.targetId);

    // 更新任务
    task.autoCheckResult = JSON.stringify(sensitiveResult);
    task.status = sensitiveResult.hasIssue ? ReviewStatus.NEED_MANUAL : ReviewStatus.AUTO_APPROVED;
    await this.taskRepository.save(task);
  }

  async checkSensitiveWords(content: string) {
    const words = await this.wordRepository.find({ where: { isActive: true } });
    const foundWords: { word: string; level: number; category: string }[] = [];

    for (const word of words) {
      if (content.toLowerCase().includes(word.word.toLowerCase())) {
        foundWords.push({
          word: word.word,
          level: word.level,
          category: word.category,
        });
      }
    }

    return {
      hasIssue: foundWords.length > 0,
      foundWords,
      riskLevel: foundWords.length > 0 ? Math.max(...foundWords.map(w => w.level)) : 0,
    };
  }

  async checkCopyright(bookId: string) {
    const book = await this.copyrightRepository.findOne({ where: { bookId } });
    if (book) return book;

    // TODO: 调用第三方版权检测API
    const result = {
      bookId,
      similarity: Math.random() * 20,
      hasRisk: false,
      riskLevel: 'low',
    };

    const check = this.copyrightRepository.create(result);
    await this.copyrightRepository.save(check);

    return check;
  }

  async getPendingTasks(page: number = 1, pageSize: number = 20) {
    const [tasks, total] = await this.taskRepository.findAndCount({
      where: { status: ReviewStatus.PENDING },
      order: { priority: 'DESC', createdAt: 'ASC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return {
      list: tasks,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async reviewTask(reviewerId: string, taskId: string, dto: ReviewDto) {
    const task = await this.taskRepository.findOne({ where: { id: taskId } });
    if (!task) throw new NotFoundException('审核任务不存在');
    if (task.status !== ReviewStatus.PENDING && task.status !== ReviewStatus.NEED_MANUAL) {
      throw new Error('任务已审核');
    }

    const newStatus = dto.action === 'approve' ? ReviewStatus.APPROVED : ReviewStatus.REJECTED;

    task.status = newStatus;
    task.reviewNote = dto.reason;
    task.reviewedBy = reviewerId;
    task.reviewedAt = new Date();
    task.reviewDuration = (task.reviewedAt.getTime() - task.createdAt.getTime()) / 1000;

    await this.taskRepository.save(task);

    // 记录审核日志
    const log = this.logRepository.create({
      taskId,
      reviewerId,
      action: dto.action,
      reason: dto.reason,
      newStatus,
    });
    await this.logRepository.save(log);

    return task;
  }

  async createReport(reporterId: string, dto: ReportDto) {
    const report = this.reportRepository.create({
      reporterId,
      reportedUserId: dto.reportedUserId,
      bookId: dto.bookId,
      commentId: dto.commentId,
      reason: dto.reason,
      description: dto.description,
    });

    await this.reportRepository.save(report);

    return { message: '举报已提交' };
  }

  async getMyReports(userId: string, page: number = 1, pageSize: number = 20) {
    const [reports, total] = await this.reportRepository.findAndCount({
      where: { reporterId: userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return {
      list: reports,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async getSensitiveWords() {
    return this.wordRepository.find({
      where: { isActive: true },
      order: { level: 'DESC' },
    });
  }

  async addSensitiveWord(word: string, level: number, category?: string, replacement?: string) {
    const entity = this.wordRepository.create({ word, level, category, replacement });
    await this.wordRepository.save(entity);
    return entity;
  }

  async deleteSensitiveWord(id: string) {
    await this.wordRepository.update(id, { isActive: false });
    return { message: '已删除' };
  }
}
