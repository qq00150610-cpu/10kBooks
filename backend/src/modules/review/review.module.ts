import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReviewController } from './review.controller';
import { ReviewService } from './review.service';
import { ReviewTask, ReviewLog, SensitiveWord, CopyrightCheck, Report } from '../../entities/review.entity';
import { BullModule } from '@nestjs/bull';

@Module({
  imports: [TypeOrmModule.forFeature([ReviewTask, ReviewLog, SensitiveWord, CopyrightCheck, Report]), BullModule.registerQueue({ name: 'review' })],
  controllers: [ReviewController],
  providers: [ReviewService],
  exports: [ReviewService],
})
export class ReviewModule {}
