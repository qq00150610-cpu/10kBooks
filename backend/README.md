# 万卷书苑 / 10kBooks Backend

多语言在线阅读平台后端服务

## 技术栈

- **框架**: NestJS 10.x + TypeScript 5.x
- **数据库**: PostgreSQL 15 + TypeORM
- **缓存**: Redis 7.x
- **队列**: Bull (Redis-backed)
- **认证**: JWT + Passport
- **文档**: Swagger/OpenAPI 3.0
- **测试**: Jest

## 项目结构

```
backend/
├── src/
│   ├── modules/                 # 功能模块
│   │   ├── auth/               # 认证模块
│   │   ├── user/               # 用户模块
│   │   ├── author/             # 作者模块
│   │   ├── book/               # 书籍模块
│   │   ├── reader/             # 阅读器模块
│   │   ├── social/             # 社交模块
│   │   ├── payment/            # 支付模块
│   │   ├── vip/                # VIP会员模块
│   │   ├── review/             # 审核模块
│   │   ├── notification/       # 通知模块
│   │   ├── ai/                 # AI功能模块
│   │   ├── i18n/               # 多语言模块
│   │   └── admin/              # 后台管理模块
│   ├── entities/               # 数据库实体
│   ├── common/                 # 公共代码
│   │   ├── decorators/         # 装饰器
│   │   ├── guards/             # 守卫
│   │   ├── interceptors/       # 拦截器
│   │   ├── filters/            # 过滤器
│   │   ├── middleware/         # 中间件
│   │   ├── constants/          # 常量
│   │   └── utils/              # 工具函数
│   └── config/                 # 配置文件
├── config/                     # Docker等配置文件
├── docs/                       # 文档
└── scripts/                    # 脚本
```

## 快速开始

### 环境要求

- Node.js 18+
- PostgreSQL 15+
- Redis 7+
- npm 或 yarn

### 安装依赖

```bash
cd backend
npm install
```

### 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，配置数据库和Redis连接信息
```

### 启动开发服务器

```bash
npm run start:dev
```

服务将在 http://localhost:3000 启动

API文档: http://localhost:3000/docs

### 构建生产版本

```bash
npm run build
npm run start:prod
```

## Docker 部署

### 构建镜像

```bash
docker build -t 10kbooks-backend .
```

### 使用 Docker Compose 启动

```bash
docker-compose up -d
```

## 主要API接口

### 认证 (Auth)
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/refresh` - 刷新令牌
- `POST /api/v1/auth/logout` - 退出登录

### 用户 (User)
- `GET /api/v1/users/me` - 获取当前用户信息
- `PATCH /api/v1/users/me` - 更新个人资料
- `POST /api/v1/users/me/real-name` - 实名认证

### 书籍 (Book)
- `GET /api/v1/books/search` - 搜索书籍
- `GET /api/v1/books/:id` - 获取书籍详情
- `GET /api/v1/books/:bookId/chapters` - 获取章节列表
- `GET /api/v1/books/:bookId/chapters/:chapterId` - 获取章节内容

### 作者 (Author)
- `POST /api/v1/author/apply` - 申请成为作者
- `POST /api/v1/author/books` - 创建书籍
- `POST /api/v1/author/books/:bookId/chapters` - 创建章节

### 阅读器 (Reader)
- `POST /api/v1/reader/progress` - 更新阅读进度
- `GET /api/v1/reader/bookmarks` - 获取书签
- `GET /api/v1/reader/history` - 获取阅读历史

### 支付 (Payment)
- `POST /api/v1/payment/orders` - 创建订单
- `GET /api/v1/payment/balance` - 获取余额
- `POST /api/v1/payment/withdrawals` - 申请提现

### VIP会员 (VIP)
- `GET /api/v1/vip/packages` - 获取VIP套餐
- `POST /api/v1/vip/subscribe` - 订阅VIP

### AI功能 (AI)
- `POST /api/v1/ai/summarize` - AI摘要
- `POST /api/v1/ai/translate` - AI翻译
- `POST /api/v1/ai/chat` - AI问答
- `POST /api/v1/ai/writing-assist` - AI写作辅助

## 认证说明

API使用JWT Bearer Token认证:

```
Authorization: Bearer <your_jwt_token>
```

## 数据库迁移

```bash
# 生成迁移
npm run migration:generate -- src/migrations/MigrationName

# 运行迁移
npm run migration:run

# 回滚迁移
npm run migration:revert
```

## 测试

```bash
# 运行单元测试
npm run test

# 运行覆盖率测试
npm run test:cov

# 运行E2E测试
npm run test:e2e
```

## 环境变量说明

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| PORT | 服务端口 | 3000 |
| NODE_ENV | 运行环境 | development |
| DB_HOST | 数据库地址 | localhost |
| DB_PORT | 数据库端口 | 5432 |
| DB_USERNAME | 数据库用户名 | postgres |
| DB_PASSWORD | 数据库密码 | postgres |
| DB_DATABASE | 数据库名 | 10kbooks |
| REDIS_HOST | Redis地址 | localhost |
| REDIS_PORT | Redis端口 | 6379 |
| JWT_SECRET | JWT密钥 | - |
| JWT_EXPIRES_IN | Token过期时间 | 1h |
| STRIPE_SECRET_KEY | Stripe密钥 | - |
| OPENAI_API_KEY | OpenAI密钥 | - |

## 许可证

MIT License
