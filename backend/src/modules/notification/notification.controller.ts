import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationService } from './notification.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('通知')
@ApiGroup('notification')
@Controller({ path: 'notifications', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Get()
  @ApiOperation({ summary: '获取通知列表' })
  async getMyNotifications(
    @UserId() userId: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
    @Query('type') type?: string,
  ) {
    return this.notificationService.getMyNotifications(userId, page, pageSize, type as any);
  }

  @Get('unread-count')
  @ApiOperation({ summary: '获取未读数量' })
  async getUnreadCount(@UserId() userId: string) {
    return this.notificationService.getUnreadCount(userId);
  }

  @Patch(':id/read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '标记为已读' })
  async markAsRead(@UserId() userId: string, @Param('id') id: string) {
    return this.notificationService.markAsRead(userId, id);
  }

  @Patch('read-all')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '全部标记为已读' })
  async markAllAsRead(@UserId() userId: string) {
    return this.notificationService.markAllAsRead(userId);
  }

  @Patch(':id/delete')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除通知' })
  async deleteNotification(@UserId() userId: string, @Param('id') id: string) {
    return this.notificationService.deleteNotification(userId, id);
  }

  @Post('devices/register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '注册推送设备' })
  async registerDevice(@UserId() userId: string, @Body() data: { deviceToken: string; deviceType: string; deviceInfo?: any }) {
    return this.notificationService.registerPushDevice(userId, data.deviceToken, data.deviceType, data.deviceInfo);
  }

  @Post('devices/unregister')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '注销推送设备' })
  async unregisterDevice(@Body('deviceToken') deviceToken: string) {
    return this.notificationService.unregisterPushDevice(deviceToken);
  }
}
