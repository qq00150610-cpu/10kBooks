import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bull';
import { NotificationProcessor, PaymentProcessor, AiProcessor, ReviewProcessor } from './processors';

@Module({
  imports: [
    BullModule.registerQueue(
      { name: 'notification' },
      { name: 'payment' },
      { name: 'ai' },
      { name: 'review' },
    ),
  ],
  providers: [NotificationProcessor, PaymentProcessor, AiProcessor, ReviewProcessor],
  exports: [BullModule],
})
export class QueueModule {}
