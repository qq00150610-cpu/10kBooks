import { Controller, Get, Post, Body, Query, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentService, CreateOrderDto, WithdrawalDto } from './payment.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('支付')
@ApiGroup('payment')
@Controller({ path: 'payment', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  @Post('orders')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '创建订单' })
  async createOrder(@UserId() userId: string, @Body() dto: CreateOrderDto) {
    return this.paymentService.createOrder(userId, dto);
  }

  @Post('orders/:orderId/pay')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '支付订单' })
  async processPayment(@UserId() userId: string, @Param('orderId') orderId: string, @Body() paymentData: any) {
    return this.paymentService.processPayment(userId, orderId, paymentData);
  }

  @Get('orders/:orderId')
  @ApiOperation({ summary: '获取订单详情' })
  async getOrderDetail(@UserId() userId: string, @Param('orderId') orderId: string) {
    return this.paymentService.getOrderDetail(userId, orderId);
  }

  @Get('orders')
  @ApiOperation({ summary: '获取订单列表' })
  async getMyOrders(@UserId() userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number, @Query('status') status?: string) {
    return this.paymentService.getMyOrders(userId, page, pageSize, status as any);
  }

  @Get('balance')
  @ApiOperation({ summary: '获取余额' })
  async getBalance(@UserId() userId: string) {
    return this.paymentService.getBalance(userId);
  }

  @Get('transactions')
  @ApiOperation({ summary: '获取交易记录' })
  async getTransactionHistory(@UserId() userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.paymentService.getTransactionHistory(userId, page, pageSize);
  }

  @Post('withdrawals')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '申请提现' })
  async applyWithdrawal(@UserId() userId: string, @Body() dto: WithdrawalDto) {
    return this.paymentService.applyWithdrawal(userId, dto);
  }

  @Get('withdrawals')
  @ApiOperation({ summary: '获取提现记录' })
  async getWithdrawals(@UserId() userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.paymentService.getWithdrawals(userId, page, pageSize);
  }

  @Get('earnings')
  @ApiOperation({ summary: '获取收益统计' })
  async getEarnings(@UserId() userId: string, @Query('page') page?: number, @Query('pageSize') pageSize?: number) {
    return this.paymentService.getEarnings(userId, page, pageSize);
  }

  @Get('coupons')
  @ApiOperation({ summary: '获取我的优惠券' })
  async getCoupons(@UserId() userId: string) {
    return this.paymentService.getCoupons(userId);
  }

  @Post('coupons/:code/claim')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '领取优惠券' })
  async claimCoupon(@UserId() userId: string, @Param('code') code: string) {
    return this.paymentService.claimCoupon(userId, code);
  }
}
