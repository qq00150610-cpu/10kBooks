// 响应状态码
export enum ResponseCode {
  SUCCESS = 1000,
  // 客户端错误 1xxx
  BAD_REQUEST = 1001,
  UNAUTHORIZED = 1002,
  FORBIDDEN = 1003,
  NOT_FOUND = 1004,
  METHOD_NOT_ALLOWED = 1005,
  CONFLICT = 1006,
  VALIDATION_ERROR = 1007,
  RATE_LIMIT_EXCEEDED = 1008,
  
  // 服务器错误 5xxx
  INTERNAL_ERROR = 5001,
  SERVICE_UNAVAILABLE = 5002,
  DATABASE_ERROR = 5003,
  CACHE_ERROR = 5004,
  
  // 业务错误 2xxx
  USER_NOT_FOUND = 2001,
  USER_ALREADY_EXISTS = 2002,
  INVALID_CREDENTIALS = 2003,
  TOKEN_EXPIRED = 2004,
  TOKEN_INVALID = 2005,
  
  BOOK_NOT_FOUND = 2101,
  CHAPTER_NOT_FOUND = 2102,
  BOOK_NOT_PUBLISHED = 2103,
  CHAPTER_NOT_PURCHASED = 2104,
  
  PAYMENT_FAILED = 2201,
  INSUFFICIENT_BALANCE = 2202,
  WITHDRAWAL_PENDING = 2203,
  
  VIP_EXPIRED = 2301,
  VIP_ALREADY_ACTIVE = 2302,
  
  AUTHOR_APPLICATION_PENDING = 2401,
  AUTHOR_APPLICATION_REJECTED = 2402,
  
  REVIEW_PENDING = 2501,
  REVIEW_REJECTED = 2502,
  
  REPORT_ALREADY_EXISTS = 2601,
}

// 缓存键前缀
export const CacheKeys = {
  USER_PREFIX: 'user:',
  BOOK_PREFIX: 'book:',
  CHAPTER_PREFIX: 'chapter:',
  SEARCH_PREFIX: 'search:',
  HOT_BOOKS: 'books:hot',
  NEW_BOOKS: 'books:new',
  RECOMMEND_BOOKS: 'books:recommend:',
  USER_FOLLOWERS: 'user:followers:',
  USER_FOLLOWING: 'user:following:',
  VIP_CONFIG: 'vip:config',
  SITE_CONFIG: 'site:config',
} as const;

// 队列名称
export const QueueNames = {
  EMAIL: 'email',
  NOTIFICATION: 'notification',
  AI_PROCESSING: 'ai-processing',
  PDF_PARSING: 'pdf-parsing',
  ELASTICSEARCH_SYNC: 'elasticsearch-sync',
  PAYMENT_PROCESSING: 'payment-processing',
  REVIEW_AUTO_CHECK: 'review-auto-check',
} as const;

// 订单类型
export enum OrderType {
  RECHARGE = 'recharge',        // 充值
  PURCHASE_CHAPTER = 'purchase_chapter',  // 购买章节
  PURCHASE_BOOK = 'purchase_book',        // 购买整书
  VIP_SUBSCRIBE = 'vip_subscribe',        // VIP订阅
  VIP_RENEW = 'vip_renew',                // VIP续费
  AUTHOR_WITHDRAW = 'author_withdraw',    // 作者提现
  PLATFORM_REWARD = 'platform_reward',    // 平台奖励
}

// 支付渠道
export enum PaymentChannel {
  STRIPE = 'stripe',
  PAYPAL = 'paypal',
  ALIPAY = 'alipay',
  WECHAT = 'wechat',
  BALANCE = 'balance',
}

// VIP等级
export enum VipLevel {
  NONE = 0,
  MONTHLY = 1,     // 月卡
  QUARTERLY = 2,   // 季卡
  YEARLY = 3,      // 年卡
  LIFETIME = 4,   // 终身会员
}

// 书籍价格策略
export enum PriceStrategy {
  FREE = 'free',           // 完全免费
  PAY_PER_CHAPTER = 'pay_per_chapter',  // 按章节付费
  PAY_FULL_BOOK = 'pay_full_book',      // 整本付费
  VIP_ONLY = 'vip_only',                 // 仅VIP可读
}

// 书籍状态
export enum BookStatus {
  DRAFT = 'draft',         // 草稿
  PENDING_REVIEW = 'pending_review',  // 待审核
  PUBLISHED = 'published',  // 已发布
  OFFLINE = 'offline',     // 已下架
  DELETED = 'deleted',     // 已删除
}

// 审核状态
export enum ReviewStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  AUTO_APPROVED = 'auto_approved',
}

// 通知类型
export enum NotificationType {
  SYSTEM = 'system',
  BOOK_UPDATE = 'book_update',
  COMMENT_REPLY = 'comment_reply',
  FOLLOW = 'follow',
  VIP_EXPIRE = 'vip_expire',
  PAYMENT = 'payment',
  REVIEW_RESULT = 'review_result',
  REVIEW_REMINDER = 'review_reminder',
}

// 文件上传类型
export enum FileType {
  AVATAR = 'avatar',
  BOOK_COVER = 'book_cover',
  PDF_BOOK = 'pdf_book',
  AUDIO = 'audio',
  IMAGE = 'image',
}
