# 万卷书苑 / 10kBooks

多语言在线阅读平台的完整 Next.js 14 前端应用。

## 技术栈

- **框架**: Next.js 14 (App Router)
- **语言**: TypeScript
- **样式**: Tailwind CSS
- **状态管理**: Zustand
- **国际化**: next-intl
- **图标**: lucide-react
- **动画**: framer-motion

## 项目结构

```
web/
├── app/                    # Next.js App Router
│   └── [locale]/          # 国际化路由
│       ├── 书籍/          # 书籍相关页面
│       │   ├── 书籍详情/
│       │   ├── 阅读器/
│       │   ├── 搜索/
│       │   └── 分类/
│       ├── 用户/          # 用户相关页面
│       │   ├── 登录/
│       │   ├── 注册/
│       │   ├── 个人中心/
│       │   ├── 我的书架/
│       │   ├── 阅读历史/
│       │   ├── VIP会员/
│       │   └── 充值记录/
│       ├── 作者/          # 作者相关页面
│       │   ├── 作者主页/
│       │   ├── 书籍管理/
│       │   ├── 章节编辑器/
│       │   ├── 数据统计/
│       │   └── 收益提现/
│       └── 社交/          # 社交相关页面
│           ├── 书友圈/
│           ├── 个人主页/
│           ├── 书单/
│           └── 动态流/
├── components/            # 组件
│   ├── ui/               # 基础UI组件
│   │   ├── Button/
│   │   ├── Input/
│   │   ├── Card/
│   │   ├── Modal/
│   │   ├── Dropdown/
│   │   ├── Loading/
│   │   ├── Avatar/
│   │   ├── Pagination/
│   │   ├── Tabs/
│   │   ├── Badge/
│   │   └── Toast/
│   ├── layout/           # 布局组件
│   │   ├── Header/
│   │   └── Footer/
│   ├── common/           # 通用业务组件
│   │   ├── BookCard/
│   │   ├── SearchBar/
│   │   ├── Rating/
│   │   ├── CommentSection/
│   │   ├── LanguageSwitcher/
│   │   └── PaymentModal/
│   ├── reader/           # 阅读器组件
│   │   ├── ReaderViewer/
│   │   ├── ReaderToolbar/
│   │   └── ChapterList/
│   └── editor/           # 编辑器组件
│       ├── RichEditor/
│       ├── MarkdownEditor/
│       └── ChapterEditor/
├── lib/                  # 工具库
│   ├── store/           # Zustand 状态管理
│   ├── utils/           # 工具函数
│   ├── types/           # TypeScript 类型定义
│   ├── constants/       # 常量配置
│   └── i18n/           # 国际化配置
├── messages/            # 国际化消息文件
│   ├── zh.json
│   └── en.json
├── styles/             # 全局样式
└── public/             # 静态资源
```

## 功能特性

### 公共页面
- ✅ 首页（推荐、热门、新书、排行榜）
- ✅ 书籍详情页
- ✅ 阅读器页面（多主题、字体调节、翻页）
- ✅ 搜索页面
- ✅ 分类浏览页

### 用户中心
- ✅ 登录/注册页（多方式登录）
- ✅ 个人中心
- ✅ 我的书架
- ✅ 阅读历史
- ✅ 笔记书签
- ✅ VIP会员页
- ✅ 充值/消费记录

### 作者中心
- ✅ 作者主页/仪表盘
- ✅ 书籍管理
- ✅ 章节编辑器（富文本/Markdown）
- ✅ 数据统计
- ✅ 收益提现

### 社交功能
- ✅ 书友圈
- ✅ 个人主页
- ✅ 书单页
- ✅ 动态流

### 组件特性
- ✅ 多主题阅读器（白天/护眼/夜间/深黑）
- ✅ 字体/字号调节
- ✅ 翻页动画
- ✅ 自动保存
- ✅ 富文本编辑器
- ✅ Markdown编辑器
- ✅ AI写作助手（UI）
- ✅ 多语言切换（中/英）

## 快速开始

### 环境要求
- Node.js 18+
- npm / yarn / pnpm

### 安装依赖

```bash
cd 10kBooks项目/web
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:3000

### 生产构建

```bash
npm run build
npm run start
```

## 环境变量

创建 `.env.local` 文件：

```env
# Next.js
NEXT_PUBLIC_API_URL=http://localhost:3000/api

# 可选：配置第三方服务
NEXT_PUBLIC_SENTRY_DSN=
```

## 路由说明

- `/` - 首页
- `/zh` - 中文首页（默认）
- `/en` - 英文首页
- `/book/[id]` - 书籍详情
- `/read/[bookId]/[chapterId]` - 阅读器
- `/search` - 搜索页
- `/category` - 全部分类
- `/category/[id]` - 分类详情
- `/login` - 登录
- `/register` - 注册
- `/profile` - 个人中心
- `/bookshelf` - 我的书架
- `/vip` - VIP会员
- `/recharge` - 充值记录
- `/author` - 作者中心
- `/author/chapter-editor/[bookId]/[chapterId]` - 章节编辑器
- `/community` - 书友圈

## 国际化

支持语言：
- 中文 (zh) - 默认
- English (en)

翻译文件位于 `messages/` 目录。

## 状态管理

使用 Zustand 进行状态管理：
- `useAuthStore` - 认证状态
- `useReaderStore` - 阅读器设置
- `useBookshelfStore` - 书架管理
- `useSearchStore` - 搜索历史
- `useUIStore` - UI状态

## 部署指南

### Vercel 部署

1. Fork 本项目到 GitHub
2. 在 Vercel 中导入项目
3. 配置环境变量
4. 点击部署

### Docker 部署

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 3000
CMD ["node", "server.js"]
```

## 开发指南

### 添加新页面

1. 在 `app/[locale]/` 下创建文件夹
2. 创建 `page.tsx` 文件
3. 添加路由链接

### 添加新组件

1. 在 `components/` 下创建组件文件夹
2. 创建 `index.tsx` 文件
3. 在需要的地方导入使用

### 添加国际化文本

在 `messages/zh.json` 和 `messages/en.json` 中添加翻译。

## 许可证

MIT License

## 联系方式

- 官方网站: https://10kbooks.com
- 邮箱: support@10kbooks.com
