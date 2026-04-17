# API 接口文档

## 文档信息

| 项目 | 内容 |
|------|------|
| 版本 | v1.0.0 |
| API 版本 | v1 |
| 更新日期 | 2024-01-15 |
| 基础 URL | `https://api.10kbooks.com/v1` |

---

## 1. 接口规范

### 1.1 基本约定

| 项目 | 规范 |
|------|------|
| **通信协议** | HTTPS |
| **数据格式** | JSON |
| **字符编码** | UTF-8 |
| **请求方法** | GET (查询)、POST (创建)、PUT (更新)、DELETE (删除) |
| **时间格式** | ISO 8601 (yyyy-MM-ddTHH:mm:ssZ) |

### 1.2 请求格式

#### 请求头 (Request Headers)

| 头信息 | 必填 | 说明 |
|--------|------|------|
| `Content-Type` | 是 | application/json; charset=utf-8 |
| `Authorization` | 是 | Bearer {access_token} |
| `Accept-Language` | 否 | zh-CN, en-US, ja-JP 等 |
| `X-Request-ID` | 否 | 请求唯一标识，用于追踪 |
| `X-Time-Zone` | 否 | 时区，如 Asia/Shanghai |

#### 请求体 (Request Body)

```json
{
  "title": "书籍标题",
  "author": "作者名称",
  "category": "fiction",
  "tags": ["都市", "爱情"],
  "description": "书籍简介"
}
```

### 1.3 响应格式

#### 成功响应

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": "10001",
    "title": "书籍标题",
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "requestId": "req_abc123"
}
```

#### 分页响应

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "list": [...],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

#### 错误响应

```json
{
  "code": 10001,
  "message": "用户未登录",
  "error": {
    "field": "authorization",
    "detail": "请先登录后再进行操作"
  },
  "requestId": "req_abc123"
}
```

---

## 2. 认证方式

### 2.1 认证流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           认证流程                                       │
└─────────────────────────────────────────────────────────────────────────┘

  ┌─────────┐                    ┌─────────┐                    ┌─────────┐
  │  客户端  │                    │  API    │                    │  认证   │
  │         │                    │ Gateway │                    │ Server  │
  └────┬────┘                    └────┬────┘                    └────┬────┘
       │                              │                              │
       │  1. 登录请求                  │                              │
       │─────────────────────────────▶│                              │
       │                              │  2. 验证账号密码               │
       │─────────────────────────────▶│─────────────────────────────▶│
       │                              │                              │
       │                              │  3. 生成 Access Token         │
       │                              │    + Refresh Token            │
       │◀─────────────────────────────│◀─────────────────────────────│
       │◀─────────────────────────────│                              │
       │                              │                              │
       │  4. 携带 Access Token 访问 API │                              │
       │─────────────────────────────▶│                              │
       │                              │  5. 验证 Token                │
       │                              │─────────────────────────────▶│
       │                              │                              │
       │  6. 返回数据                  │                              │
       │◀─────────────────────────────│                              │
```

### 2.2 认证类型

#### 2.2.1 密码登录

**请求**

```
POST /v1/auth/login
```

```json
{
  "countryCode": "+86",
  "phone": "13800138000",
  "password": "xxxxxx"
}
```

**响应**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 7200,
    "tokenType": "Bearer"
  }
}
```

#### 2.2.2 验证码登录

**请求**

```
POST /v1/auth/login/sms
```

```json
{
  "countryCode": "+86",
  "phone": "13800138000",
  "code": "123456"
}
```

#### 2.2.3 第三方登录

**请求**

```
POST /v1/auth/oauth/{provider}
```

| provider | 说明 |
|----------|------|
| google | Google 账号 |
| apple | Apple ID |
| facebook | Facebook |
| twitter | Twitter |

```json
{
  "openId": "google_open_id",
  "accessToken": "google_access_token",
  "nickname": "用户名",
  "avatar": "https://..."
}
```

#### 2.2.4 Token 刷新

**请求**

```
POST /v1/auth/refresh
```

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**响应**

```json
{
  "code": 0,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 7200
  }
}
```

---

## 3. 用户模块接口

### 3.1 用户信息

#### 获取当前用户信息

```
GET /v1/user/me
```

**响应**

```json
{
  "code": 0,
  "data": {
    "id": "u_12345",
    "nickname": "书虫小王",
    "avatar": "https://cdn.10kbooks.com/avatar/12345.jpg",
    "email": "user@example.com",
    "phone": "+86 138****8000",
    "gender": "male",
    "birthday": "1995-06-15",
    "country": "CN",
    "language": "zh-CN",
    "role": "user",
    "vip": {
      "level": 2,
      "expireTime": "2025-01-15T00:00:00Z"
    },
    "stats": {
      "following": 50,
      "followers": 120,
      "books": 3,
      "reading": 5
    },
    "createdAt": "2023-01-15T10:30:00Z"
  }
}
```

#### 更新用户信息

```
PUT /v1/user/me
```

**请求**

```json
{
  "nickname": "新昵称",
  "avatar": "https://cdn.10kbooks.com/avatar/new.jpg",
  "gender": "female",
  "birthday": "1996-08-20",
  "country": "CN",
  "language": "zh-CN",
  "bio": "热爱阅读，专注创作"
}
```

### 3.2 用户关系

#### 关注用户

```
POST /v1/user/{userId}/follow
```

**响应**

```json
{
  "code": 0,
  "message": "关注成功"
}
```

#### 取消关注

```
DELETE /v1/user/{userId}/follow
```

#### 获取用户关注列表

```
GET /v1/user/{userId}/following
```

**参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| page | int | 页码，默认 1 |
| pageSize | int | 每页数量，默认 20 |

#### 获取用户粉丝列表

```
GET /v1/user/{userId}/followers
```

---

## 4. 书籍模块接口

### 4.1 书籍浏览

#### 获取书籍详情

```
GET /v1/books/{bookId}
```

**响应**

```json
{
  "code": 0,
  "data": {
    "id": "b_10001",
    "title": "星际穿越：宇宙的奥秘",
    "cover": "https://cdn.10kbooks.com/cover/b_10001.jpg",
    "author": {
      "id": "a_12345",
      "nickname": "科幻作家",
      "avatar": "https://cdn.10kbooks.com/avatar/a_12345.jpg",
      "verified": true
    },
    "category": {
      "id": "cat_001",
      "name": "科幻"
    },
    "tags": ["星际", "宇宙", "冒险"],
    "description": "一段跨越时空的星际旅程...",
    "status": "published",
    "chapters": 120,
    "words": 580000,
    "views": 1250000,
    "recommendations": 45000,
    "reviews": 3200,
    "rating": 4.8,
    "isPaid": true,
    "price": 9.99,
    "currency": "USD",
    "vipRead": true,
    "publishTime": "2023-06-15T00:00:00Z",
    "lastUpdate": "2024-01-10T08:30:00Z"
  }
}
```

#### 获取书籍章节列表

```
GET /v1/books/{bookId}/chapters
```

**响应**

```json
{
  "code": 0,
  "data": {
    "bookId": "b_10001",
    "chapters": [
      {
        "id": "c_10001",
        "number": 1,
        "title": "第一章：星际启程",
        "isVip": false,
        "words": 3500,
        "updatedAt": "2023-06-15T00:00:00Z"
      },
      {
        "id": "c_10002",
        "number": 2,
        "title": "第二章：虫洞之谜",
        "isVip": true,
        "words": 4200,
        "updatedAt": "2023-06-20T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 50,
      "total": 120
    }
  }
}
```

#### 获取章节内容

```
GET /v1/books/{bookId}/chapters/{chapterId}
```

**响应**

```json
{
  "code": 0,
  "data": {
    "id": "c_10002",
    "bookId": "b_10001",
    "number": 2,
    "title": "第二章：虫洞之谜",
    "content": "...",
    "words": 4200,
    "isVip": true,
    "isPurchased": false,
    "prevChapter": {
      "id": "c_10001",
      "title": "第一章：星际启程"
    },
    "nextChapter": {
      "id": "c_10003",
      "title": "第三章：五维空间"
    }
  }
}
```

### 4.2 书籍搜索

#### 搜索书籍

```
GET /v1/books/search
```

**参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| q | string | 搜索关键词 |
| category | string | 分类 ID |
| tags | string[] | 标签 |
| sort | string | 排序：relevance, views, rating, newest |
| price | string | 价格过滤：all, free, paid, vip |
| page | int | 页码 |
| pageSize | int | 每页数量 |

**响应**

```json
{
  "code": 0,
  "data": {
    "list": [
      {
        "id": "b_10001",
        "title": "星际穿越：宇宙的奥秘",
        "cover": "https://...",
        "author": {...},
        "rating": 4.8,
        "views": 1250000
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 150
    }
  }
}
```

### 4.3 书籍推荐

#### 获取首页推荐

```
GET /v1/books/recommend
```

**参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | 推荐类型：homepage, personalized, similar |
| limit | int | 返回数量 |

**响应**

```json
{
  "code": 0,
  "data": {
    "banners": [
      {
        "id": "banner_001",
        "title": "新年特惠",
        "image": "https://...",
        "link": "/books/b_10001"
      }
    ],
    "sections": [
      {
        "type": "editor_choice",
        "title": "编辑精选",
        "books": [...]
      },
      {
        "type": "hot",
        "title": "热门推荐",
        "books": [...]
      },
      {
        "type": "newest",
        "title": "新书速递",
        "books": [...]
      }
    ]
  }
}
```

---

## 5. 阅读模块接口

### 5.1 阅读进度

#### 获取阅读进度

```
GET /v1/reading/progress/{bookId}
```

**响应**

```json
{
  "code": 0,
  "data": {
    "bookId": "b_10001",
    "chapterId": "c_10005",
    "position": 1520,
    "percent": 45.5,
    "lastReadAt": "2024-01-15T10:30:00Z"
  }
}
```

#### 更新阅读进度

```
POST /v1/reading/progress
```

**请求**

```json
{
  "bookId": "b_10001",
  "chapterId": "c_10005",
  "position": 1520,
  "percent": 45.5
}
```

### 5.2 书架管理

#### 获取用户书架

```
GET /v1/shelf
```

**响应**

```json
{
  "code": 0,
  "data": {
    "reading": [
      {
        "bookId": "b_10001",
        "progress": 45.5,
        "lastChapter": "c_10005",
        "lastReadAt": "2024-01-15T10:30:00Z"
      }
    ],
    "favorites": [...],
    "histories": [...]
  }
}
```

#### 添加到书架

```
POST /v1/shelf
```

```json
{
  "bookId": "b_10001"
}
```

#### 从书架移除

```
DELETE /v1/shelf/{bookId}
```

---

## 6. 创作模块接口

### 6.1 作者入驻

#### 申请成为作者

```
POST /v1/author/apply
```

```json
{
  "penName": "笔名",
  "bio": "作者简介",
  "idCard": "身份证号",
  "idCardFront": "https://...",
  "idCardBack": "https://...",
  "bankName": "开户银行",
  "bankAccount": "银行账号"
}
```

### 6.2 作品管理

#### 创建作品

```
POST /v1/author/books
```

```json
{
  "title": "作品标题",
  "category": "cat_001",
  "tags": ["都市", "爱情"],
  "cover": "https://...",
  "description": "作品简介",
  "isPaid": true,
  "price": 9.99,
  "currency": "CNY"
}
```

#### 发布章节

```
POST /v1/author/books/{bookId}/chapters
```

```json
{
  "title": "章节标题",
  "content": "章节内容...",
  "isVip": false,
  "draft": false
}
```

### 6.3 数据统计

#### 获取作品数据

```
GET /v1/author/stats/{bookId}
```

**响应**

```json
{
  "code": 0,
  "data": {
    "overview": {
      "views": 1250000,
      "recommendations": 45000,
      "reviews": 3200,
      "subscribers": 8500
    },
    "income": {
      "total": 12500.00,
      "currency": "CNY",
      "breakdown": {
        "subscription": 8000.00,
        "direct": 4500.00
      }
    },
    "trends": [
      {
        "date": "2024-01-01",
        "views": 5000,
        "subscribers": 120
      }
    ]
  }
}
```

---

## 7. 社交模块接口

### 7.1 评论

#### 获取书籍评论

```
GET /v1/books/{bookId}/reviews
```

**参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| sort | string | 排序：newest, hottest, rating |
| page | int | 页码 |
| pageSize | int | 每页数量 |

#### 发表评论

```
POST /v1/books/{bookId}/reviews
```

```json
{
  "rating": 5,
  "content": "这本书太好看了！",
  "spoiler": false
}
```

### 7.2 动态

#### 发布动态

```
POST /v1/feed
```

```json
{
  "type": "post",
  "content": "正在阅读《星际穿越》，强烈推荐！",
  "images": ["https://..."],
  "bookId": "b_10001",
  "visibility": "public"
}
```

### 7.3 消息

#### 获取消息列表

```
GET /v1/messages
```

**参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | 消息类型：system, comment, like, follow |
| page | int | 页码 |
| pageSize | int | 每页数量 |

#### 发送私信

```
POST /v1/messages
```

```json
{
  "toUserId": "u_12345",
  "content": "私信内容"
}
```

---

## 8. 支付模块接口

### 8.1 充值

#### 创建充值订单

```
POST /v1/wallet/recharge
```

```json
{
  "amount": 100.00,
  "currency": "CNY",
  "method": "alipay"
}
```

**响应**

```json
{
  "code": 0,
  "data": {
    "orderId": "o_123456",
    "amount": 100.00,
    "currency": "CNY",
    "payUrl": "https://pay.alipay.com/...",
    "expireTime": "2024-01-15T11:30:00Z"
  }
}
```

### 8.2 购买

#### 购买书籍

```
POST /v1/orders/books
```

```json
{
  "bookId": "b_10001"
}
```

#### 购买章节

```
POST /v1/orders/chapters
```

```json
{
  "chapterId": "c_10002"
}
```

### 8.3 订阅

#### 开通 VIP

```
POST /v1/vip/subscribe
```

```json
{
  "planId": "vip_yearly",
  "method": "alipay"
}
```

---

## 9. 错误码定义

### 9.1 系统错误码

| 错误码 | 说明 | HTTP 状态码 |
|--------|------|-------------|
| 0 | 成功 | 200 |
| 10001 | 系统内部错误 | 500 |
| 10002 | 服务不可用 | 503 |
| 10003 | 接口不存在 | 404 |
| 10004 | 请求超时 | 504 |

### 9.2 认证错误码

| 错误码 | 说明 | HTTP 状态码 |
|--------|------|-------------|
| 20001 | 未登录 | 401 |
| 20002 | Token 过期 | 401 |
| 20003 | Token 无效 | 401 |
| 20004 | 账号被禁用 | 403 |
| 20005 | 权限不足 | 403 |

### 9.3 参数错误码

| 错误码 | 说明 | HTTP 状态码 |
|--------|------|-------------|
| 30001 | 参数不能为空 | 400 |
| 30002 | 参数格式错误 | 400 |
| 30003 | 参数超出范围 | 400 |
| 30004 | 不支持的参数 | 400 |

### 9.4 业务错误码

| 错误码 | 说明 | HTTP 状态码 |
|--------|------|-------------|
| 40001 | 资源不存在 | 404 |
| 40002 | 资源已存在 | 409 |
| 40003 | 操作被禁止 | 403 |
| 40004 | 余额不足 | 402 |
| 40005 | 已购买 | 400 |
| 40006 | VIP 已过期 | 402 |
| 40007 | 内容审核中 | 400 |
| 40008 | 内容违规 | 403 |

---

## 10. 示例代码

### 10.1 Java (Spring Boot)

```java
@RestController
@RequestMapping("/v1/books")
public class BookController {

    @Autowired
    private BookService bookService;

    @Autowired
    private AuthService authService;

    /**
     * 获取书籍详情
     */
    @GetMapping("/{bookId}")
    public ApiResponse<BookVO> getBookDetail(@PathVariable String bookId) {
        BookVO book = bookService.getBookById(bookId);
        return ApiResponse.success(book);
    }

    /**
     * 搜索书籍
     */
    @GetMapping("/search")
    public ApiResponse<PageResult<BookVO>> searchBooks(
            @RequestParam String q,
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "relevance") String sort,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        
        PageResult<BookVO> result = bookService.searchBooks(
            q, category, sort, page, pageSize);
        return ApiResponse.success(result);
    }

    /**
     * 获取用户书架
     */
    @GetMapping("/shelf")
    public ApiResponse<ShelfVO> getUserShelf(HttpServletRequest request) {
        String userId = authService.getCurrentUserId(request);
        ShelfVO shelf = bookService.getUserShelf(userId);
        return ApiResponse.success(shelf);
    }
}
```

### 10.2 JavaScript (Node.js)

```javascript
// API 服务封装
import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'https://api.10kbooks.com/v1',
  timeout: 10000,
});

// 请求拦截器
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// 响应拦截器
apiClient.interceptors.response.use(
  (response) => response.data,
  async (error) => {
    if (error.response?.status === 401) {
      // Token 过期，尝试刷新
      await refreshToken();
      // 重试原请求
      return apiClient.request(error.config);
    }
    return Promise.reject(error);
  }
);

// 书籍服务
export const bookService = {
  // 获取书籍详情
  async getBookDetail(bookId) {
    return apiClient.get(`/books/${bookId}`);
  },

  // 搜索书籍
  async searchBooks(params) {
    return apiClient.get('/books/search', { params });
  },

  // 获取章节内容
  async getChapter(bookId, chapterId) {
    return apiClient.get(`/books/${bookId}/chapters/${chapterId}`);
  }
};

// 使用示例
async function fetchBook() {
  try {
    const result = await bookService.getBookDetail('b_10001');
    console.log(result.data);
  } catch (error) {
    console.error('获取书籍失败:', error.message);
  }
}
```

### 10.3 Python (FastAPI)

```python
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, List

router = APIRouter(prefix="/v1/books", tags=["books"])

class BookResponse(BaseModel):
    id: str
    title: str
    author: dict
    rating: float
    
class ApiResponse(BaseModel):
    code: int = 0
    message: str = "success"
    data: Optional[dict] = None

@router.get("/{book_id}", response_model=ApiResponse)
async def get_book_detail(book_id: str):
    """获取书籍详情"""
    book = await book_service.get_book_by_id(book_id)
    return ApiResponse(data=book)

@router.get("/search", response_model=ApiResponse)
async def search_books(
    q: str,
    category: Optional[str] = None,
    sort: str = "relevance",
    page: int = 1,
    page_size: int = 20
):
    """搜索书籍"""
    result = await book_service.search_books(
        q, category, sort, page, page_size
    )
    return ApiResponse(data=result)

# 使用示例
# uvicorn main:app --reload
```

---

## 附录

### A. API 版本策略

| 策略 | 说明 |
|------|------|
| 版本格式 | URL 路径：`/v1/`, `/v2/` |
| 兼容周期 | 每个版本至少维护 18 个月 |
| 废弃通知 | 提前 6 个月发布废弃公告 |

### B. 限流策略

| 等级 | QPS 限制 | 说明 |
|------|---------|------|
| 普通用户 | 60 | 默认限制 |
| VIP 用户 | 300 | 付费会员 |
| 开发者 | 1000 | API 开发者 |

### C. 联系方式

- 技术支持：api@10kbooks.com
- API 文档：https://docs.10kbooks.com
