import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard, AdminOnly } from '../../common/guards/jwt-auth.guard';
import { UserId } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('后台管理')
@ApiGroup('admin')
@Controller({ path: 'admin', version: '1' })
@UseGuards(JwtAuthGuard, AdminOnly)
@ApiBearerAuth()
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  // 仪表盘
  @Get('dashboard')
  @ApiOperation({ summary: '获取管理后台统计' })
  async getDashboard() {
    return this.adminService.getDashboardStats();
  }

  @Get('dashboard/revenue')
  @ApiOperation({ summary: '获取收入统计' })
  async getRevenueStats(@Query('startDate') startDate?: string, @Query('endDate') endDate?: string) {
    return this.adminService.getRevenueStats(startDate ? new Date(startDate) : undefined, endDate ? new Date(endDate) : undefined);
  }

  // 用户管理
  @Get('users')
  @ApiOperation({ summary: '获取用户列表' })
  async getUsers(@Query('page') page?: number, @Query('pageSize') pageSize?: number, @Query('role') role?: string) {
    return this.adminService.getUsers(page, pageSize, role as any);
  }

  @Patch('users/:userId/role')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '更新用户角色' })
  async updateUserRole(@Param('userId') userId: string, @Body('role') role: string) {
    return this.adminService.updateUserRole(userId, role as any);
  }

  @Patch('users/:userId/toggle')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '启用/禁用用户' })
  async toggleUserStatus(@Param('userId') userId: string) {
    return this.adminService.toggleUserStatus(userId);
  }

  // 作者申请管理
  @Get('author-applications')
  @ApiOperation({ summary: '获取作者申请列表' })
  async getAuthorApplications(@Query('page') page?: number, @Query('pageSize') pageSize?: number, @Query('status') status?: string) {
    return this.adminService.getAuthorApplications(page, pageSize, status);
  }

  @Post('author-applications/:id/review')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '审核作者申请' })
  async reviewAuthorApplication(@UserId() userId: string, @Param('id') id: string, @Body() data: { action: 'approve' | 'reject'; note?: string }) {
    return this.adminService.reviewAuthorApplication(id, data.action, userId, data.note);
  }

  // 书籍管理
  @Get('books')
  @ApiOperation({ summary: '获取书籍列表' })
  async getBooks(@Query('page') page?: number, @Query('pageSize') pageSize?: number, @Query('status') status?: string) {
    return this.adminService.getBooks(page, pageSize, status as any);
  }

  @Patch('books/:bookId/toggle')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '上下架书籍' })
  async toggleBookStatus(@Param('bookId') bookId: string) {
    return this.adminService.toggleBookStatus(bookId);
  }

  // 订单管理
  @Get('orders')
  @ApiOperation({ summary: '获取订单列表' })
  async getOrders(@Query('page') page?: number, @Query('pageSize') pageSize?: number, @Query('status') status?: string) {
    return this.adminService.getOrders(page, pageSize, status);
  }

  // 提现管理
  @Get('withdrawals')
  @ApiOperation({ summary: '获取提现列表' })
  async getWithdrawals(@Query('page') page?: number, @Query('pageSize') pageSize?: number, @Query('status') status?: string) {
    return this.adminService.getWithdrawals(page, pageSize, status);
  }

  @Post('withdrawals/:id/process')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '处理提现申请' })
  async processWithdrawal(@UserId() userId: string, @Param('id') id: string, @Body() data: { action: 'approve' | 'reject'; note?: string }) {
    return this.adminService.processWithdrawal(id, data.action, userId, data.note);
  }

  // 举报管理
  @Get('reports')
  @ApiOperation({ summary: '获取举报列表' })
  async getReports(@Query('page') page?: number, @Query('pageSize') pageSize?: number, @Query('status') status?: string) {
    return this.adminService.getReports(page, pageSize, status);
  }

  @Post('reports/:id/handle')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '处理举报' })
  async handleReport(@UserId() userId: string, @Param('id') id: string, @Body() data: { action: 'resolve' | 'dismiss'; note?: string }) {
    return this.adminService.handleReport(id, data.action, userId, data.note);
  }
}
