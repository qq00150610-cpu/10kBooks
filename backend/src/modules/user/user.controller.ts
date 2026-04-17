import {
  Controller,
  Get,
  Patch,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiQuery,
} from '@nestjs/swagger';
import { UserService, UpdateProfileDto, RealNameVerificationDto } from './user.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UserId, CurrentUser } from '../../common/decorators/param.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('用户')
@ApiGroup('user')
@Controller({ path: 'users', version: '1' })
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('me')
  @ApiOperation({ summary: '获取当前用户信息' })
  async getMyProfile(@UserId() userId: string) {
    return this.userService.getProfile(userId);
  }

  @Patch('me')
  @ApiOperation({ summary: '更新个人资料' })
  async updateProfile(
    @UserId() userId: string,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.userService.updateProfile(userId, dto);
  }

  @Post('me/real-name')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '实名认证' })
  async realNameVerification(
    @UserId() userId: string,
    @Body() dto: RealNameVerificationDto,
  ) {
    return this.userService.realNameVerification(userId, dto);
  }

  @Get('me/stats')
  @ApiOperation({ summary: '获取用户统计信息' })
  async getMyStats(@UserId() userId: string) {
    return this.userService.getUserStats(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: '获取用户信息' })
  @ApiResponse({ status: 200, description: '用户信息' })
  async getUserById(@Param('id') id: string) {
    return this.userService.getUserById(id);
  }

  @Get('username/:username')
  @ApiOperation({ summary: '通过用户名获取用户信息' })
  async getUserByUsername(@Param('username') username: string) {
    return this.userService.getUserByUsername(username);
  }

  @Get()
  @ApiOperation({ summary: '搜索用户' })
  @ApiQuery({ name: 'keyword', required: true })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'pageSize', required: false })
  async searchUsers(
    @Query('keyword') keyword: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
  ) {
    return this.userService.searchUsers(keyword, page, pageSize);
  }

  @Post('me/deactivate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '停用账户' })
  async deactivateAccount(@UserId() userId: string) {
    return this.userService.deactivateAccount(userId);
  }

  @Post('me/delete')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除账户' })
  async deleteAccount(@UserId() userId: string) {
    return this.userService.deleteAccount(userId);
  }
}
