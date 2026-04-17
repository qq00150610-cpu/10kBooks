import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { Notification, NotificationTemplate, PushDevice, NotificationType } from '../../entities/notification.entity';
import { QueueNames } from '../../common/constants';
import { IsOptional, IsString, IsNumber } from 'class-validator';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
    @InjectRepository(NotificationTemplate)
    private templateRepository: Repository<NotificationTemplate>,
    @InjectRepository(PushDevice)
    private deviceRepository: Repository<PushDevice>,
    @InjectQueue(QueueNames.NOTIFICATION)
    private notificationQueue: Queue,
  ) {}

  async sendNotification(userId: string, type: NotificationType, title: string, content: string, relatedId?: string, relatedType?: string) {
    const notification = this.notificationRepository.create({
      userId,
      type,
      title,
      content,
      relatedId,
      relatedType,
    });

    await this.notificationRepository.save(notification);

    // 添加到推送队列
    await this.notificationQueue.add('push', { notificationId: notification.id });

    return notification;
  }

  async sendBatchNotification(userIds: string[], type: NotificationType, title: string, content: string) {
    const notifications = userIds.map(userId =>
      this.notificationRepository.create({ userId, type, title, content }),
    );

    await this.notificationRepository.save(notifications);

    return { message: `已发送${notifications.length}条通知` };
  }

  async sendByTemplate(userId: string, templateCode: string, variables: Record<string, string>) {
    const template = await this.templateRepository.findOne({
      where: { code: templateCode, isActive: true },
    });

    if (!template) throw new NotFoundException('通知模板不存在');

    let title = template.titleTemplate;
    let content = template.contentTemplate;

    for (const [key, value] of Object.entries(variables)) {
      title = title.replace(new RegExp(`{{${key}}}`, 'g'), value);
      content = content.replace(new RegExp(`{{${key}}}`, 'g'), value);
    }

    return this.sendNotification(userId, template.type, title, content);
  }

  async getMyNotifications(userId: string, page: number = 1, pageSize: number = 20, type?: NotificationType) {
    const where: any = { userId };
    if (type) where.type = type;

    const [notifications, total] = await this.notificationRepository.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    return {
      list: notifications,
      pagination: { page, pageSize, total, totalPages: Math.ceil(total / pageSize) },
    };
  }

  async getUnreadCount(userId: string) {
    return this.notificationRepository.count({
      where: { userId, status: 'unread' },
    });
  }

  async markAsRead(userId: string, notificationId: string) {
    await this.notificationRepository.update(
      { id: notificationId, userId },
      { status: 'read', readAt: new Date() },
    );
    return { message: '已标记为已读' };
  }

  async markAllAsRead(userId: string) {
    await this.notificationRepository.update(
      { userId, status: 'unread' },
      { status: 'read', readAt: new Date() },
    );
    return { message: '已标记全部为已读' };
  }

  async deleteNotification(userId: string, notificationId: string) {
    await this.notificationRepository.update(
      { id: notificationId, userId },
      { status: 'deleted' },
    );
    return { message: '已删除' };
  }

  async registerPushDevice(userId: string, deviceToken: string, deviceType: string, deviceInfo?: any) {
    const existing = await this.deviceRepository.findOne({ where: { deviceToken } });
    if (existing) {
      existing.userId = userId;
      existing.deviceType = deviceType;
      existing.deviceInfo = JSON.stringify(deviceInfo);
      await this.deviceRepository.save(existing);
    } else {
      const device = this.deviceRepository.create({
        userId,
        deviceToken,
        deviceType,
        deviceInfo: JSON.stringify(deviceInfo),
      });
      await this.deviceRepository.save(device);
    }
    return { message: '设备注册成功' };
  }

  async unregisterPushDevice(deviceToken: string) {
    await this.deviceRepository.update({ deviceToken }, { isActive: false });
    return { message: '设备已注销' };
  }
}
