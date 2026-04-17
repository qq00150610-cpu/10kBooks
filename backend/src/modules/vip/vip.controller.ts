import { Controller, Get, Post, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { VipService } from './vip.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('VIP会员')
@ApiGroup('vip')
@Controller({ path: 'vip', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class VipController {
  constructor(private readonly vipService: VipService) {}

  @Get('packages')
  @ApiOperation({ summary: '获取VIP套餐列表' })
  async getVipPackages() {
    return this.vipService.getVipPackages();
  }

  @Get('status')
  @ApiOperation({ summary: '获取我的VIP状态' })
  async getMyVipStatus(@UserId() userId: string) {
    return this.vipService.getMyVipStatus(userId);
  }

  @Post('subscribe')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '订阅VIP' })
  async subscribe(@UserId() userId: string, @Body('packageId') packageId: string, @Body('paymentData') paymentData?: any) {
    return this.vipService.subscribe(userId, packageId, paymentData);
  }

  @Post('cancel-renew')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '取消自动续费' })
  async cancelAutoRenew(@UserId() userId: string) {
    return this.vipService.cancelAutoRenew(userId);
  }

  @Get('benefits/logs')
  @ApiOperation({ summary: '获取权益使用记录' })
  async getBenefitLogs(@UserId() userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.vipService.getBenefitLogs(userId, page, pageSize);
  }
}
