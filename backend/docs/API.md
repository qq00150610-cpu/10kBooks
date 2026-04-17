# API 文档

## 基础信息

- **Base URL**: `http://localhost:3000/api/v1`
- **认证方式**: JWT Bearer Token
- **Content-Type**: `application/json`

## 认证接口

### POST /auth/register - 用户注册

**请求体:**
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123!",
  "username": "用户名",
  "inviteCode": "可选的邀请码"
}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "用户名",
      "role": "user"
    },
    "tokens": {
      "accessToken": "jwt_token",
      "refreshToken": "refresh_token",
      "expiresIn": 3600
    }
  }
}
```

### POST /auth/login - 用户登录

**请求体:**
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123!"
}
```

## 书籍接口

### GET /books/search - 搜索书籍

**Query参数:**
- `keyword`: 搜索关键词
- `categories`: 分类ID数组 (逗号分隔)
- `tags`: 标签数组 (逗号分隔)
- `language`: 语言
- `sortBy`: 排序字段 (createdAt, views, likes, rating)
- `sortOrder`: 排序方向 (ASC, DESC)
- `page`: 页码
- `pageSize`: 每页数量

**响应:**
```json
{
  "success": true,
  "data": {
    "list": [
      {
        "id": "uuid",
        "title": "书名",
        "cover": "封面URL",
        "description": "简介",
        "author": {
          "id": "uuid",
          "penName": "作者笔名"
        },
        "totalViews": 1000,
        "totalLikes": 100,
        "avgRating": 4.5
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

### GET /books/:id - 获取书籍详情

**响应:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "书名",
    "originalTitle": "原名",
    "description": "详细介绍",
    "cover": "封面URL",
    "status": "published",
    "priceStrategy": "pay_per_chapter",
    "fullBookPrice": 99.00,
    "totalChapters": 100,
    "totalWords": 500000,
    "totalViews": 10000,
    "totalLikes": 500,
    "totalCollections": 200,
    "avgRating": 4.5,
    "tags": ["都市", "重生"],
    "categories": ["小说"],
    "author": {
      "id": "uuid",
      "penName": "作者笔名",
      "bio": "作者简介"
    },
    "isCollected": false
  }
}
```

## 支付接口

### POST /payment/orders - 创建订单

**请求体:**
```json
{
  "orderType": "purchase_chapter",
  "targetId": "章节ID",
  "paymentChannel": "stripe",
  "couponCode": "可选的优惠券码"
}
```

### POST /payment/orders/:orderId/pay - 支付订单

**请求体:**
```json
{
  "paymentMethodId": "stripe_payment_method_id"
}
```

## VIP会员接口

### GET /vip/packages - 获取VIP套餐

**响应:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "level": 1,
      "name": "月卡会员",
      "price": 30.00,
      "duration": 30,
      "features": ["免费阅读VIP书籍", "每月5张优惠券"]
    },
    {
      "id": "uuid",
      "level": 3,
      "name": "年卡会员",
      "price": 298.00,
      "duration": 365,
      "features": ["全部VIP权益", "专属客服", "专属标识"]
    }
  ]
}
```

## AI功能接口

### POST /ai/summarize - AI摘要

**请求体:**
```json
{
  "bookId": "书籍ID",
  "summaryType": "book_intro",
  "language": "zh-CN"
}
```

### POST /ai/chat - AI问答

**请求体:**
```json
{
  "bookId": "书籍ID (可选)",
  "message": "请介绍一下这本书的主要内容"
}
```

### POST /ai/writing-assist - AI写作辅助

**请求体:**
```json
{
  "bookId": "书籍ID",
  "assistType": "outline",
  "input": "都市重生商战题材，主角是一个成功企业家"
}
```

## 错误响应格式

```json
{
  "success": false,
  "error": {
    "statusCode": 400,
    "message": "错误信息",
    "error": "BadRequest",
    "timestamp": "2024-01-01T00:00:00.000Z",
    "path": "/api/v1/books"
  }
}
```

## 状态码说明

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |
