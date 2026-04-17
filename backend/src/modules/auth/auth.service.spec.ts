import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { User, UserProfile } from '../../entities/user.entity';
import { UserRole } from '../../common/constants';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';

describe('AuthService', () => {
  let service: AuthService;

  const mockUserRepository = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    update: jest.fn(),
  };

  const mockUserProfileRepository = {
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn(),
    verify: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn().mockReturnValue('test-secret'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(User), useValue: mockUserRepository },
        { provide: getRepositoryToken(UserProfile), useValue: mockUserProfileRepository },
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    const registerDto = {
      email: 'test@example.com',
      password: 'Password123!',
      username: 'testuser',
    };

    it('should register a new user successfully', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);
      mockUserRepository.create.mockReturnValue({ id: 'uuid', ...registerDto });
      mockUserRepository.save.mockResolvedValue({ id: 'uuid', ...registerDto, role: UserRole.USER });
      mockUserProfileRepository.create.mockReturnValue({ userId: 'uuid' });
      mockUserProfileRepository.save.mockResolvedValue({ userId: 'uuid' });
      mockJwtService.sign.mockReturnValue('mock_token');

      const result = await service.register(registerDto);

      expect(result).toHaveProperty('user');
      expect(result).toHaveProperty('tokens');
      expect(result.user.email).toBe(registerDto.email);
    });

    it('should throw BadRequestException if user already exists', async () => {
      mockUserRepository.findOne.mockResolvedValue({ id: 'existing-user' });

      await expect(service.register(registerDto)).rejects.toThrow(BadRequestException);
    });
  });

  describe('login', () => {
    const loginDto = {
      email: 'test@example.com',
      password: 'Password123!',
    };

    it('should login successfully with correct credentials', async () => {
      const mockUser = {
        id: 'uuid',
        email: loginDto.email,
        password: '$2b$12$hashedpassword',
        isActive: true,
        role: UserRole.USER,
      };

      mockUserRepository.findOne.mockResolvedValue(mockUser);
      mockJwtService.sign.mockReturnValue('mock_token');

      const result = await service.login(loginDto);

      expect(result).toHaveProperty('tokens');
      expect(result.tokens.accessToken).toBe('mock_token');
    });

    it('should throw UnauthorizedException for non-existent user', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);

      await expect(service.login(loginDto)).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('getCurrentUser', () => {
    it('should return user without sensitive fields', async () => {
      const mockUser = {
        id: 'uuid',
        email: 'test@example.com',
        password: 'secret',
        refreshToken: 'token',
        role: UserRole.USER,
      };

      mockUserRepository.findOne.mockResolvedValue(mockUser);

      const result = await service.getCurrentUser('uuid');

      expect(result).not.toHaveProperty('password');
      expect(result).not.toHaveProperty('refreshToken');
      expect(result.email).toBe(mockUser.email);
    });
  });
});
