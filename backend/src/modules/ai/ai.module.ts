import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { AiSummary, AiTranslation, AiChat, AiMessage, AiWritingAssist, AiRecommendation, AiContentCheck } from '../../entities/ai.entity';
import { BullModule } from '@nestjs/bull';

@Module({
  imports: [TypeOrmModule.forFeature([AiSummary, AiTranslation, AiChat, AiMessage, AiWritingAssist, AiRecommendation, AiContentCheck]), BullModule.registerQueue({ name: 'ai' })],
  controllers: [AiController],
  providers: [AiService],
  exports: [AiService],
})
export class AiModule {}
