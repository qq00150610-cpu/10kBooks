import { SetMetadata } from '@nestjs/common';

// 公开接口
export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);

// 管理员权限
export const IS_ADMIN_KEY = 'isAdmin';
export const AdminOnly = () => SetMetadata(IS_ADMIN_KEY, true);

// 角色权限
export const ROLES_KEY = 'roles';
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);

// 用户角色枚举
export enum UserRole {
  USER = 'user',
  AUTHOR = 'author',
  VIP = 'vip',
  ADMIN = 'admin',
  SUPER_ADMIN = 'super_admin',
}

// 作者权限守卫
export const IS_AUTHOR_KEY = 'isAuthor';
export const AuthorOnly = () => SetMetadata(IS_AUTHOR_KEY, true);
