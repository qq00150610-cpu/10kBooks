import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { User, UserProfile, AuthorApplication } from '../../entities/user.entity';
import { PasswordUtil, CodeUtil } from '../../common/utils';
import { IsOptional, IsString, IsEmail } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  username?: string;

  @IsOptional()
  @IsString()
  avatar?: string;

  @IsOptional()
  @IsString()
  bio?: string;

  @IsOptional()
  @IsString()
  birthday?: string;

  @IsOptional()
  @IsString()
  gender?: 'male' | 'female' | 'other';

  @IsOptional()
  @IsString()
  language?: string;
}

export class RealNameVerificationDto {
  @IsString()
  realName: string;

  @IsString()
  idCardNumber: string;

  @IsString()
  idCardFront: string;

  @IsString()
  idCardBack: string;
}

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(UserProfile)
    private userProfileRepository: Repository<UserProfile>,
    @InjectRepository(AuthorApplication)
    private authorApplicationRepository: Repository<AuthorApplication>,
    private configService: ConfigService,
  ) {}

  async getProfile(userId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    const profile = await this.userProfileRepository.findOne({
      where: { userId },
    });

    const { password, refreshToken, ...userInfo } = user;

    return {
      ...userInfo,
      profile,
    };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    // 更新用户基本信息
    if (dto.username) user.username = dto.username;
    if (dto.avatar) user.avatar = dto.avatar;
    if (dto.birthday) user.birthday = new Date(dto.birthday);
    if (dto.gender) user.gender = dto.gender;
    if (dto.language) user.language = dto.language;

    await this.userRepository.save(user);

    // 更新详细资料
    const profile = await this.userProfileRepository.findOne({
      where: { userId },
    });

    if (profile) {
      if (dto.bio) profile.bio = dto.bio;
      await this.userProfileRepository.save(profile);
    }

    return this.getProfile(userId);
  }

  async realNameVerification(userId: string, dto: RealNameVerificationDto) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    // TODO: 调用实名认证API验证身份证信息
    
    user.realName = dto.realName;
    user.idCardNumber = dto.idCardNumber;
    user.idCardFront = dto.idCardFront;
    user.idCardBack = dto.idCardBack;
    user.isRealNameVerified = true;

    await this.userRepository.save(user);

    return { message: '实名认证成功' };
  }

  async getUserById(userId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    const { password, refreshToken, ...userInfo } = user;
    return userInfo;
  }

  async getUserByUsername(username: string) {
    const user = await this.userRepository.findOne({
      where: { username },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    const { password, refreshToken, ...userInfo } = user;
    return userInfo;
  }

  async searchUsers(keyword: string, page: number = 1, pageSize: number = 20) {
    const skip = (page - 1) * pageSize;

    const [users, total] = await this.userRepository.findAndCount({
      where: [
        { username: this.userRepository.createQueryBuilder().where('username ILIKE :keyword', { keyword: `%${keyword}%` }) as any },
        { email: this.userRepository.createQueryBuilder().where('email ILIKE :keyword', { keyword: `%${keyword}%` }) as any },
      ],
      select: ['id', 'username', 'avatar', 'email', 'role', 'createdAt'],
      skip,
      take: pageSize,
      order: { createdAt: 'DESC' },
    });

    return {
      list: users,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async getUserStats(userId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    return {
      balance: user.balance,
      totalRecharge: user.totalRecharge,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      isRealNameVerified: user.isRealNameVerified,
      isVip: user.role === 'vip' || user.role === 'admin',
      memberSince: user.createdAt,
    };
  }

  async deactivateAccount(userId: string) {
    await this.userRepository.update(userId, {
      isActive: false,
    });

    return { message: '账户已停用' };
  }

  async deleteAccount(userId: string) {
    // 软删除用户
    await this.userRepository.softDelete(userId);
    
    // 删除用户资料
    await this.userProfileRepository.softDelete({ userId });

    return { message: '账户已删除' };
  }

  async getFollowStats(userId: string) {
    // 这里需要引入Follow实体
    return {
      followers: 0,
      following: 0,
    };
  }
}
