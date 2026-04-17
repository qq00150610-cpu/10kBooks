import {
  Controller,
  Post,
  Body,
  UseGuards,
  Get,
  Patch,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
} from '@nestjs/swagger';
import { AuthService, RegisterDto, LoginDto } from './auth.service';
import { JwtAuthGuard, Public } from '../../common/guards/jwt-auth.guard';
import { CurrentUser, UserId } from '../../common/decorators/param.decorators';
import { IsEmail, IsString, MinLength, IsOptional } from 'class-validator';
import { ApiGroup } from '../../common/decorators/api.decorators';

class RegisterRequestDto implements RegisterDto {
  @ApiOperation({ summary: '用户注册' })
  @IsEmail({}, { message: '请输入有效的邮箱地址' })
  email: string;

  @IsString()
  @MinLength(8, { message: '密码至少8位' })
  password: string;

  @IsOptional()
  @IsString()
  username?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  inviteCode?: string;

  @IsOptional()
  @IsString()
  language?: string;
}

class LoginRequestDto implements LoginDto {
  @IsEmail({}, { message: '请输入有效的邮箱地址' })
  email: string;

  @IsString()
  password: string;
}

class RefreshTokenDto {
  @IsString()
  refreshToken: string;
}

class ChangePasswordDto {
  @IsString()
  oldPassword: string;

  @IsString()
  @MinLength(8)
  newPassword: string;
}

@ApiTags('认证')
@ApiGroup('auth')
@Controller({ path: 'auth', version: '1' })
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '用户注册' })
  @ApiResponse({ status: 201, description: '注册成功' })
  async register(@Body() dto: RegisterRequestDto) {
    return this.authService.register(dto);
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '用户登录' })
  @ApiResponse({ status: 200, description: '登录成功' })
  async login(@Body() dto: LoginRequestDto) {
    return this.authService.login(dto);
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '刷新令牌' })
  async refreshToken(@Body() dto: RefreshTokenDto, @CurrentUser() user: any) {
    return this.authService.refreshToken(user.sub, dto.refreshToken);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: '退出登录' })
  async logout(@UserId() userId: string) {
    await this.authService.logout(userId);
    return { message: '退出登录成功' };
  }

  @Get('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取当前用户信息' })
  async getCurrentUser(@UserId() userId: string) {
    return this.authService.getCurrentUser(userId);
  }

  @Patch('password')
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '修改密码' })
  async changePassword(
    @UserId() userId: string,
    @Body() dto: ChangePasswordDto,
  ) {
    await this.authService.changePassword(
      userId,
      dto.oldPassword,
      dto.newPassword,
    );
    return { message: '密码修改成功' };
  }

  @Public()
  @Post('social/google')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Google第三方登录' })
  async googleCallback(@Body('accessToken') accessToken: string) {
    // TODO: 实现Google OAuth验证
    return { message: 'Google登录开发中' };
  }
}
