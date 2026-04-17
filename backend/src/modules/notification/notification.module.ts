import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificationController } from './notification.controller';
import { NotificationService } from './notification.service';
import { Notification, NotificationTemplate, PushDevice, EmailQueue } from '../../entities/notification.entity';
import { BullModule } from '@nestjs/bull';

@Module({
  imports: [TypeOrmModule.forFeature([Notification, NotificationTemplate, PushDevice, EmailQueue]), BullModule.registerQueue({ name: 'notification' })],
  controllers: [NotificationController],
  providers: [NotificationService],
  exports: [NotificationService],
})
export class NotificationModule {}
