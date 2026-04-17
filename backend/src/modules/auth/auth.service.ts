import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserProfile } from '../../entities/user.entity';
import { PasswordUtil, CodeUtil } from '../../common/utils';
import { UserRole } from '../../common/constants';

export interface RegisterDto {
  email: string;
  password: string;
  username?: string;
  phone?: string;
  inviteCode?: string;
  language?: string;
}

export interface LoginDto {
  email: string;
  password: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(UserProfile)
    private userProfileRepository: Repository<UserProfile>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(dto: RegisterDto): Promise<{ user: Partial<User>; tokens: AuthTokens }> {
    const existingUser = await this.userRepository.findOne({
      where: [{ email: dto.email }, { phone: dto.phone }],
    });

    if (existingUser) {
      throw new BadRequestException('该邮箱或手机号已注册');
    }

    // 检查邀请码
    let invitedBy: string | null = null;
    if (dto.inviteCode) {
      const inviter = await this.userRepository.findOne({
        where: { inviteCode: dto.inviteCode },
      });
      if (inviter) {
        invitedBy = inviter.id;
      }
    }

    // 创建用户
    const passwordHash = await PasswordUtil.hash(dto.password);
    const user = this.userRepository.create({
      email: dto.email,
      password: passwordHash,
      username: dto.username || dto.email.split('@')[0],
      phone: dto.phone,
      invitedBy,
      inviteCode: CodeUtil.generateInviteCode(),
      language: dto.language || 'zh-CN',
      role: UserRole.USER,
    });

    await this.userRepository.save(user);

    // 创建用户资料
    const profile = this.userProfileRepository.create({
      userId: user.id,
      timezone: 'Asia/Shanghai',
    });
    await this.userProfileRepository.save(profile);

    const tokens = await this.generateTokens(user);

    return {
      user: this.sanitizeUser(user),
      tokens,
    };
  }

  async login(dto: LoginDto): Promise<{ user: Partial<User>; tokens: AuthTokens }> {
    const user = await this.userRepository.findOne({
      where: { email: dto.email },
    });

    if (!user) {
      throw new UnauthorizedException('邮箱或密码错误');
    }

    const isPasswordValid = await PasswordUtil.compare(dto.password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('邮箱或密码错误');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('账户已被禁用');
    }

    // 更新最后登录信息
    await this.userRepository.update(user.id, {
      lastLoginAt: new Date(),
    });

    const tokens = await this.generateTokens(user);

    return {
      user: this.sanitizeUser(user),
      tokens,
    };
  }

  async refreshToken(userId: string, refreshToken: string): Promise<AuthTokens> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user || user.refreshToken !== refreshToken) {
      throw new UnauthorizedException('无效的刷新令牌');
    }

    const tokens = await this.generateTokens(user);
    
    // 更新refreshToken
    user.refreshToken = tokens.refreshToken;
    await this.userRepository.save(user);

    return tokens;
  }

  async logout(userId: string): Promise<void> {
    await this.userRepository.update(userId, {
      refreshToken: null,
    });
  }

  async validateSocialLogin(
    provider: 'google' | 'apple',
    profile: { id: string; email?: string; name?: string; avatar?: string },
  ): Promise<{ user: Partial<User>; tokens: AuthTokens; isNewUser: boolean }> {
    const email = profile.email;
    
    if (!email) {
      throw new BadRequestException('无法获取社交账号邮箱');
    }

    let user = await this.userRepository.findOne({
      where: { email },
    });

    let isNewUser = false;

    if (!user) {
      // 创建新用户
      isNewUser = true;
      user = this.userRepository.create({
        email,
        username: profile.name || email.split('@')[0],
        avatar: profile.avatar,
        password: await PasswordUtil.hash(CodeUtil.generateVerificationCode()),
        inviteCode: CodeUtil.generateInviteCode(),
        isEmailVerified: true,
        role: UserRole.USER,
      });
      await this.userRepository.save(user);

      // 创建用户资料
      const userProfile = this.userProfileRepository.create({
        userId: user.id,
      });
      await this.userProfileRepository.save(userProfile);
    }

    const tokens = await this.generateTokens(user);

    return {
      user: this.sanitizeUser(user),
      tokens,
      isNewUser,
    };
  }

  async getCurrentUser(userId: string): Promise<Partial<User>> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('用户不存在');
    }

    return this.sanitizeUser(user);
  }

  async changePassword(userId: string, oldPassword: string, newPassword: string): Promise<void> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('用户不存在');
    }

    const isPasswordValid = await PasswordUtil.compare(oldPassword, user.password);
    if (!isPasswordValid) {
      throw new BadRequestException('原密码错误');
    }

    const newPasswordHash = await PasswordUtil.hash(newPassword);
    await this.userRepository.update(userId, {
      password: newPasswordHash,
      refreshToken: null, // 强制重新登录
    });
  }

  async resetPassword(email: string, newPassword: string, code: string): Promise<void> {
    // TODO: 验证验证码
    const user = await this.userRepository.findOne({
      where: { email },
    });

    if (!user) {
      throw new BadRequestException('用户不存在');
    }

    const passwordHash = await PasswordUtil.hash(newPassword);
    await this.userRepository.update(user.id, {
      password: passwordHash,
      refreshToken: null,
    });
  }

  private async generateTokens(user: User): Promise<AuthTokens> {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_REFRESH_SECRET'),
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN', '7d'),
    });

    // 保存refreshToken
    user.refreshToken = refreshToken;
    await this.userRepository.save(user);

    return {
      accessToken,
      refreshToken,
      expiresIn: 3600, // 1小时
    };
  }

  private sanitizeUser(user: User): Partial<User> {
    const { password, passwordSalt, refreshToken, ...sanitized } = user;
    return sanitized;
  }
}
