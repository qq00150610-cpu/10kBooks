import { SetMetadata } from '@nestjs/common';

// API分组
export const API_GROUP_KEY = 'apiGroup';
export const ApiGroup = (group: string) => SetMetadata(API_GROUP_KEY, group);

// API排序
export const API_ORDER_KEY = 'apiOrder';
export const ApiOrder = (order: number) => SetMetadata(API_ORDER_KEY, order);

// 弃用标记
export const DEPRECATED_KEY = 'isDeprecated';
export const Deprecated = () => SetMetadata(DEPRECATED_KEY, true);
