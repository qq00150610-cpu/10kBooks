# 万卷书苑 API 文档

## 📡 接口基础信息

- **Base URL**: `https://api.10kbooks.com/api/v1`
- **数据格式**: JSON
- **编码**: UTF-8
- **认证方式**: Bearer Token

## 🔐 认证

### 登录

```
POST /auth/login
```

**请求参数:**

```json
{
  "account": "user@example.com",
  "password": "password123"
}
```

**响应:**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 604800
  }
}
```

### 注册

```
POST /auth/register
```

**请求参数:**

```json
{
  "nickname": "用户名",
  "email": "user@example.com",
  "password": "password123",
  "invite_code": "ABC123" // 可选
}
```

## 📚 首页接口

### 获取轮播图

```
GET /home/banners
```

**响应:**

```json
{
  "code": 200,
  "data": [
    {
      "id": "1",
      "title": "暑期特惠",
      "image": "https://example.com/banner1.jpg",
      "link": null,
      "book_id": "book123",
      "type": "book",
      "sort": 1
    }
  ]
}
```

### 获取热门书籍

```
GET /home/hot-books?limit=10
```

### 获取新书

```
GET /home/new-books?limit=20
```

### 获取推荐书籍

```
GET /home/recommend-books?limit=10
```

## 🏪 书城接口

### 获取分类

```
GET /categories
```

**响应:**

```json
{
  "code": 200,
  "data": [
    {
      "id": "1",
      "name": "玄幻",
      "icon": "fantasy",
      "book_count": 1234,
      "sort": 1
    }
  ]
}
```

### 分类书籍列表

```
GET /books/category?category_id=1&page=1&limit=20&sort=hot
```

### 搜索书籍

```
GET /books/search?q=关键词&page=1&limit=20
```

### 书籍详情

```
GET /books?id=book123
```

**响应:**

```json
{
  "code": 200,
  "data": {
    "id": "book123",
    "title": "书名",
    "author": "作者",
    "cover": "https://example.com/cover.jpg",
    "description": "书籍简介",
    "tags": ["玄幻", "修仙"],
    "word_count": 1000000,
    "chapter_count": 500,
    "status": "ongoing",
    "is_vip": true,
    "rating": 4.5,
    "view_count": 100000,
    "subscribe_count": 5000,
    "comment_count": 200,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T00:00:00Z",
    "category_id": "1",
    "category_name": "玄幻"
  }
}
```

### 章节列表

```
GET /books/chapters?book_id=book123
```

### 章节内容

```
GET /chapters/content?id=chapter123
```

## 📖 书架接口

### 我的书架

```
GET /bookshelf
```

### 添加到书架

```
POST /bookshelf
```

**请求参数:**

```json
{
  "book_id": "book123"
}
```

### 阅读进度

```
GET /progress?book_id=book123
```

### 更新阅读进度

```
POST /progress
```

**请求参数:**

```json
{
  "book_id": "book123",
  "chapter_id": "chapter123",
  "position": 500
}
```

## 👤 用户接口

### 用户信息

```
GET /user
```

### 更新用户信息

```
PUT /user
```

**请求参数:**

```json
{
  "nickname": "新昵称",
  "bio": "个人简介",
  "avatar": "头像URL"
}
```

## 💰 VIP 接口

### VIP 信息

```
GET /vip/info
```

### VIP 产品列表

```
GET /vip/products
```

### 创建订单

```
POST /orders
```

**请求参数:**

```json
{
  "product_id": "vip_monthly",
  "payment_method": "alipay"
}
```

## ✍️ 作者接口

### 作者书籍列表

```
GET /author/books
```

### 作者统计数据

```
GET /author/stats
```

### 作者收益

```
GET /author/earnings
```

### 创建书籍

```
POST /author/books
```

**请求参数:**

```json
{
  "title": "书名",
  "description": "简介",
  "category_id": "1",
  "tags": ["玄幻"],
  "is_vip": true
}
```

### 发布章节

```
POST /author/chapters
```

**请求参数:**

```json
{
  "book_id": "book123",
  "title": "第一章",
  "content": "章节内容...",
  "is_vip": false
}
```

## 👥 社交接口

### 动态列表

```
GET /feed?page=1&limit=20
```

### 用户动态

```
GET /users/posts?user_id=user123&page=1&limit=20
```

### 发布动态

```
POST /posts
```

**请求参数:**

```json
{
  "content": "动态内容",
  "images": ["url1", "url2"],
  "book_id": "book123" // 可选
}
```

### 点赞

```
POST /posts/like
```

**请求参数:**

```json
{
  "post_id": "post123"
}
```

### 评论列表

```
GET /comments?target_id=post123&page=1&limit=20
```

### 发布评论

```
POST /comments
```

**请求参数:**

```json
{
  "target_type": "post",
  "target_id": "post123",
  "content": "评论内容",
  "reply_to_id": "comment123" // 可选，回复评论
}
```

### 关注/取消关注

```
POST /users/follow
DELETE /users/unfollow
```

## 📖 书签与笔记

### 书签列表

```
GET /bookmarks?book_id=book123
```

### 添加书签

```
POST /bookmarks
```

**请求参数:**

```json
{
  "book_id": "book123",
  "chapter_id": "chapter123",
  "position": 500,
  "note": "书签备注" // 可选
}
```

### 笔记列表

```
GET /notes?book_id=book123
```

### 添加笔记

```
POST /notes
```

**请求参数:**

```json
{
  "book_id": "book123",
  "chapter_id": "chapter123",
  "content": "笔记内容"
}
```

## ❌ 错误码

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未登录或 Token 过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

## 📝 错误响应格式

```json
{
  "code": 401,
  "message": "登录已过期，请重新登录",
  "data": null
}
```
