import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UserRole } from '../../common/constants';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: AuthService;

  const mockAuthService = {
    register: jest.fn(),
    login: jest.fn(),
    refreshToken: jest.fn(),
    logout: jest.fn(),
    getCurrentUser: jest.fn(),
    changePassword: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        { provide: AuthService, useValue: mockAuthService },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    authService = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should register a new user', async () => {
      const registerDto = {
        email: 'test@example.com',
        password: 'Password123!',
        username: 'testuser',
      };

      const expectedResult = {
        user: {
          id: 'uuid',
          email: 'test@example.com',
          username: 'testuser',
          role: UserRole.USER,
        },
        tokens: {
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          expiresIn: 3600,
        },
      };

      mockAuthService.register.mockResolvedValue(expectedResult);

      const result = await controller.register(registerDto);

      expect(authService.register).toHaveBeenCalledWith(registerDto);
      expect(result).toEqual(expectedResult);
    });
  });

  describe('login', () => {
    it('should login user with valid credentials', async () => {
      const loginDto = {
        email: 'test@example.com',
        password: 'Password123!',
      };

      const expectedResult = {
        user: {
          id: 'uuid',
          email: 'test@example.com',
          role: UserRole.USER,
        },
        tokens: {
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          expiresIn: 3600,
        },
      };

      mockAuthService.login.mockResolvedValue(expectedResult);

      const result = await controller.login(loginDto);

      expect(authService.login).toHaveBeenCalledWith(loginDto);
      expect(result).toEqual(expectedResult);
    });
  });

  describe('logout', () => {
    it('should logout user', async () => {
      const userId = 'user-uuid';
      mockAuthService.logout.mockResolvedValue({ message: '退出登录成功' });

      const result = await controller.logout(userId);

      expect(authService.logout).toHaveBeenCalledWith(userId);
      expect(result).toEqual({ message: '退出登录成功' });
    });
  });

  describe('getCurrentUser', () => {
    it('should return current user info', async () => {
      const userId = 'user-uuid';
      const expectedResult = {
        id: 'user-uuid',
        email: 'test@example.com',
        username: 'testuser',
        role: UserRole.USER,
      };

      mockAuthService.getCurrentUser.mockResolvedValue(expectedResult);

      const result = await controller.getCurrentUser(userId);

      expect(authService.getCurrentUser).toHaveBeenCalledWith(userId);
      expect(result).toEqual(expectedResult);
    });
  });
});
