# 万卷书苑 / 10kBooks 数据库架构文档

> 版本: v1.0.0  
> 数据库: PostgreSQL 15 + Redis 7  
> 最后更新: 2024-01

---

## 目录

1. [架构概览](#1-架构概览)
2. [核心数据表](#2-核心数据表)
3. [多语言存储方案](#3-多语言存储方案)
4. [索引策略](#4-索引策略)
5. [Redis缓存设计](#5-redis缓存设计)
6. [触发器与自动化](#6-触发器与自动化)
7. [安全性设计](#7-安全性设计)
8. [性能优化建议](#8-性能优化建议)

---

## 1. 架构概览

### 1.1 设计原则

- **UUID主键**: 所有主表使用UUID作为主键，支持分布式场景
- **软删除**: 核心数据表支持软删除 (`deleted_at`)
- **时间戳追踪**: 所有表包含 `created_at`、`updated_at`
- **乐观锁**: 涉及金额的表使用版本号控制并发
- **多语言支持**: 使用JSONB存储多语言内容
- **触发器自动化**: 关键统计数据通过触发器自动维护

### 1.2 核心模块

```
┌─────────────────────────────────────────────────────────────────┐
│                        万卷书苑 / 10kBooks                        │
├─────────────────────────────────────────────────────────────────┤
│  用户系统    │ users │ user_settings │ user_wallets │ user_sessions │
│  作者系统    │ authors │ author_applications │ author_settlements  │
│  书籍系统    │ books │ chapters │ categories │ tags │ bookshelves    │
│  阅读功能    │ reading_progress │ bookmarks │ reading_notes          │
│  社交系统    │ user_follows │ book_activities │ comments │ likes    │
│  订单支付    │ orders │ purchases │ vip_subscriptions │ withdrawals │
│  通知系统    │ notifications │ notification_templates │ push_devices │
│  审核系统    │ audit_tasks │ sensitive_words │ audit_logs           │
│  AI系统      │ ai_models │ ai_usage_logs │ ai_tasks               │
│  系统支撑    │ system_configs │ operation_logs │ book_recommendations│
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 ER关系图

```
users ──┬── author_applications ── authors ── books ── chapters
        │                                              │
        ├── user_settings                        translations
        ├── user_wallets                          │
        │     └── wallet_transactions            book_pricing
        ├── user_follows ───────────────────────────┤
        ├── bookshelves ────────────────────────┐   │
        │                                    bookshelves
        ├── reading_progress ──────────────────┤
        │                                    ratings
        ├── bookmarks ──────────────────────────┤
        │                                    likes
        ├── reading_notes ─────────────────────┤
        │                                    comments
        ├── likes ───────────────────────────────┤
        ├── comments ────────────────────────────┤
        ├── ratings ─────────────────────────────┤
        ├── book_activities ─────────────────────┤
        │                                    reports
        ├── orders ──┬─ purchases ────────────────┤
        │           ├─ vip_subscriptions
        │           └─ withdrawals
        │
        ├── notifications
        ├── push_devices
        └── ai_usage_logs
              └── ai_tasks
```

---

## 2. 核心数据表

### 2.1 用户表 (users)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| uuid | VARCHAR(64) | API用唯一标识 |
| username | VARCHAR(50) | 用户名(唯一) |
| email | VARCHAR(255) | 邮箱 |
| phone | VARCHAR(20) | 手机号 |
| password_hash | VARCHAR(255) | 密码哈希 |
| display_name | VARCHAR(100) | 显示名称 |
| avatar_url | VARCHAR(500) | 头像URL |
| locale | VARCHAR(10) | 偏好语言(默认zh-CN) |
| vip_level | SMALLINT | VIP等级(0-4) |
| vip_expire_at | TIMESTAMPTZ | VIP到期时间 |
| status | SMALLINT | 状态(1正常2禁言3封禁4注销) |
| **统计字段** | | |
| followers_count | BIGINT | 粉丝数 |
| following_count | BIGINT | 关注数 |
| books_count | BIGINT | 收藏/阅读书籍数 |

**索引**:
- `idx_users_locale` - 按语言查询
- `idx_users_status` - 状态筛选
- `idx_users_vip_level` - VIP用户查询
- `idx_users_auth` - 第三方登录

### 2.2 作者表 (authors)

| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | UUID | 关联用户(唯一) |
| pen_name | VARCHAR(100) | 笔名 |
| is_verified | BOOLEAN | 是否认证作者 |
| author_level | SMALLINT | 作者等级(1-5) |
| **收益相关** | | |
| total_earnings | BIGINT | 累计收益(分) |
| withdrawable_amount | BIGINT | 可提现金额(分) |
| pending_amount | BIGINT | 待结算金额(分) |
| **统计字段** | | |
| books_count | INTEGER | 作品数 |
| total_words | BIGINT | 累计字数 |
| total_views | BIGINT | 累计阅读量 |
| subscribers_count | BIGINT | 关注人数 |

### 2.3 书籍表 (books)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| book_uuid | VARCHAR(64) | API用唯一标识 |
| author_id | UUID | 作者ID |
| title | VARCHAR(200) | 原语言标题 |
| title_i18n | JSONB | 多语言标题 |
| cover_url | VARCHAR(500) | 封面图 |
| description | TEXT | 简介 |
| description_i18n | JSONB | 多语言简介 |
| category_id | UUID | 分类ID |
| tags | UUID[] | 标签数组 |
| original_locale | VARCHAR(10) | 原始语言 |
| translation_status | SMALLINT | 翻译状态 |
| genre | VARCHAR(30) | 题材分类 |
| word_count | INTEGER | 总字数 |
| chapter_count | INTEGER | 章节数 |
| status | SMALLINT | 状态(1创作中2已完结3连载4停更) |
| is_paywalled | BOOLEAN | 是否付费 |
| **统计字段** | | |
| views_count | BIGINT | 总阅读量 |
| likes_count | BIGINT | 总点赞数 |
| avg_rating | DECIMAL(3,2) | 平均评分 |
| ratings_count | BIGINT | 评分次数 |

### 2.4 章节表 (chapters)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| chapter_uuid | VARCHAR(64) | API用唯一标识 |
| book_id | UUID | 所属书籍 |
| chapter_number | INTEGER | 章节号 |
| title | VARCHAR(200) | 章节标题 |
| title_i18n | JSONB | 多语言标题 |
| content | TEXT | 正文内容 |
| content_length | INTEGER | 内容长度 |
| word_count | INTEGER | 章节字数 |
| status | SMALLINT | 状态(1草稿2待审核3已发布4锁定) |
| is_paywalled | BOOLEAN | 是否付费 |
| is_vip_chapter | BOOLEAN | VIP专属章节 |
| published_at | TIMESTAMPTZ | 发布时间 |
| scheduled_publish_at | TIMESTAMPTZ | 定时发布 |

### 2.5 订单表 (orders)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| order_no | VARCHAR(64) | 订单号(唯一) |
| user_id | UUID | 用户ID |
| order_type | VARCHAR(20) | 订单类型 |
| total_amount | INTEGER | 订单总额(分) |
| paid_amount | INTEGER | 实付金额(分) |
| payment_method | VARCHAR(30) | 支付方式 |
| payment_status | VARCHAR(20) | 支付状态 |
| payment_txn_id | VARCHAR(100) | 第三方交易号 |
| refund_status | VARCHAR(20) | 退款状态 |

**订单类型**: `recharge`(充值) | `purchase`(购买) | `vip`(会员) | `gift`(礼物)

**支付方式**: `alipay` | `wechat` | `apple_iap` | `google_billing` | `coins`

### 2.6 通知表 (notifications)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| user_id | UUID | 接收用户 |
| type | VARCHAR(30) | 通知类型 |
| title | VARCHAR(200) | 标题 |
| content | TEXT | 内容 |
| action_type | VARCHAR(30) | 跳转类型 |
| action_id | UUID | 跳转目标ID |
| is_read | BOOLEAN | 是否已读 |
| aggregation_key | VARCHAR(100) | 聚合Key |

**通知类型**: `system`(系统) | `new_chapter`(新章节) | `comment`(评论) | `like`(点赞) | `follow`(关注) | `vip`(会员) | `earnings`(收益)

---

## 3. 多语言存储方案

### 3.1 书籍多语言版本

**方案**: `book_translations` 表 + 主表JSONB字段

```sql
-- 主表存储原语言内容 + JSONB存储翻译
INSERT INTO books (title, title_i18n, description, description_i18n) VALUES
('仙武帝尊', 
 '{"en": "Martial God Emperor", "ja": "仙武帝尊"}',
 '一代仙帝重生都市...',
 '{"en": "A supreme immortal lord is reborn...", "ja": "最上の仙帝が..."}');

-- 独立翻译表存储完整翻译版本
INSERT INTO book_translations (book_id, locale, title, description) VALUES
('book_id', 'en', 'Martial God Emperor', 'A supreme immortal lord is reborn...');
```

**优势**:
- 原语言查询无需JSONB解析
- 翻译版本独立存储，支持更新
- 支持按语言分库(未来扩展)

### 3.2 章节多语言

```sql
-- 章节独立翻译表
CREATE TABLE chapter_translations (
    chapter_id  UUID NOT NULL,
    locale      VARCHAR(10) NOT NULL,
    title       VARCHAR(200),
    content     TEXT,
    PRIMARY KEY (chapter_id, locale)
);
```

### 3.3 动态/评论多语言

**方案**: 主表存储用户输入语言 + content_i18n存储翻译

```sql
comments (
    content         TEXT NOT NULL,           -- 原始内容
    content_i18n   JSONB,                     -- AI翻译 {"en": "...", "ja": "..."}
    locale         VARCHAR(10) DEFAULT 'zh-CN'  -- 原始语言
)
```

### 3.4 系统文案多语言

**方案**: 模板表 + 前端国际化

```sql
notification_templates (
    template_code   VARCHAR(50),
    title_i18n      JSONB,    -- {"zh-CN": "标题", "en": "Title"}
    content_i18n    JSONB     -- {"zh-CN": "内容{{var}}", "en": "Content {{var}}"}
)
```

### 3.5 分类/标签多语言

```sql
categories (
    name_i18n   JSONB NOT NULL  -- {"zh-CN": "玄幻", "en": "Fantasy", "ja": "ファンタジー"}
)
```

---

## 4. 索引策略

### 4.1 搜索优化

**全文搜索** (pg_trgm扩展):
```sql
-- 模糊搜索索引
CREATE INDEX idx_books_search ON books USING gin(title gin_trgm_ops);

-- 查询示例
SELECT * FROM books WHERE title % '仙侠';  -- 相似度搜索
```

**分词搜索** (可选PostgreSQL中文分词):
```sql
-- 使用zhparser扩展
CREATE EXTENSION zhparser;
CREATE TEXT SEARCH CONFIGURATION chinese_zhparser;

-- 全文搜索
SELECT * FROM books WHERE to_tsvector('chinese', title) @@ to_tsquery('chinese', '仙侠 & 重生');
```

### 4.2 热门书籍排序

```sql
-- 综合热度指数 (可考虑收藏、阅读、评分等因素)
CREATE INDEX idx_books_hot ON books(
    (followers_count * 3 + likes_count * 2 + views_count),
    ratings_count
) WHERE deleted_at IS NULL;

-- 分类热门
CREATE INDEX idx_books_category_hot ON books(
    category_id,
    (followers_count * 3 + likes_count * 2 + views_count) DESC
) WHERE deleted_at IS NULL;
```

### 4.3 用户推荐算法支持

```sql
-- 用户-书籍交互矩阵支持
CREATE TABLE user_book_interactions (
    user_id         UUID,
    book_id         UUID,
    interaction_type SMALLINT,  -- 1收藏 2阅读 3购买 4点赞 5评分
    weight          DECIMAL(4,2),
    created_at      TIMESTAMPTZ,
    PRIMARY KEY (user_id, book_id, interaction_type)
);

-- 协同过滤索引
CREATE INDEX idx_interactions_book ON user_book_interactions(book_id, interaction_type);
CREATE INDEX idx_interactions_user ON user_book_interactions(user_id, created_at DESC);

-- 书籍推荐记录
CREATE TABLE book_recommendations (
    user_id     UUID,
    book_id     UUID,
    rec_type    VARCHAR(30),    -- personalized, similar, popular
    rec_source  VARCHAR(30),    -- als, item_cf, content, rule
    score       DECIMAL(10,6),
    exposed_at  TIMESTAMPTZ,
    clicked_at   TIMESTAMPTZ,
    converted_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, book_id, rec_type)
);

-- 高效查询用户推荐
CREATE INDEX idx_recommendations_user_score 
ON book_recommendations(user_id, score DESC) 
WHERE exposed_at IS NOT NULL;
```

### 4.4 分片策略 (可选)

**按语言分片**:
```sql
-- 分片键: original_locale
-- 分片1: zh-CN, zh-TW, zh-HK
-- 分片2: en-US, en-GB, en
-- 分片3: ja, ko, 其他
```

**按时间分片**:
```sql
-- 日志表按月分区
CREATE TABLE notifications_partitioned (...) PARTITION BY RANGE (created_at);
CREATE TABLE notifications_2024_01 PARTITION OF notifications_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

---

## 5. Redis缓存设计

### 5.1 缓存键设计

| 类型 | 键格式 | TTL | 说明 |
|------|--------|-----|------|
| 用户Session | `session:{token}` | 30天 | 用户登录状态 |
| 用户Token | `token:{user_id}` | - | 刷新Token |
| 用户钱包 | `wallet:{user_id}` | 5分钟 | 积分/金币余额 |
| VIP状态 | `vip:{user_id}` | 1小时 | VIP等级和到期时间 |
| 书籍评分 | `book:rating:{book_id}` | 10分钟 | 平均分和评分人数 |
| 热门书籍 | `books:hot:{locale}:{period}` | 5分钟 | 有序集合 |
| 新书上架 | `books:new:{locale}` | 5分钟 | 有序集合 |
| 阅读进度 | `reading:{user_id}:{book_id}` | 7天 | 章节和进度 |
| 书架缓存 | `bookshelf:{user_id}` | 10分钟 | 用户书架 |
| 限流 | `rate:{user_id}:{action}` | 1分钟 | API限流计数 |
| 分布式锁 | `lock:{resource}:{id}` | 30秒 | 悲观锁 |
| 队列 | `queue:ai_task` | - | AI任务队列 |
| 布隆过滤器 | `bf:viewed:{book_id}` | 30天 | 已读用户 |

### 5.2 缓存策略

**Cache-Aside Pattern**:
```python
# 读取
def get_book(book_id):
    cache_key = f"book:{book_id}"
    book = redis.get(cache_key)
    if book is None:
        book = db.query("SELECT * FROM books WHERE id = ?", book_id)
        redis.setex(cache_key, 3600, book)  # 1小时
    return book

# 更新
def update_book(book_id, data):
    db.update("UPDATE books SET ... WHERE id = ?", book_id)
    redis.delete(f"book:{book_id}")  # 删除缓存
```

### 5.3 排行榜实现

```sql
-- Redis Sorted Set 实现热门榜单
ZADD books:hot:zh-CN:weekly 9500 "book_001"  -- 周榜
ZADD books:hot:zh-CN:monthly 9800 "book_001"  -- 月榜
ZADD books:hot:zh-CN:all 15000 "book_001"     -- 总榜

-- 查询TOP10
ZREVRANGE books:hot:zh-CN:weekly 0 9 WITHSCORES

-- 更新热度
ZINCRBY books:hot:zh-CN:daily 100 "book_001"
```

### 5.4 订阅发布

```bash
# 新章节发布通知
PUBLISH channel:book:book_001:new_chapter '{"chapter_id":"c001","title":"第100章"}'

# 实时消息推送
PUBLISH channel:user:user_001:notifications '{"type":"new_chapter","content":"..."}'
```

---

## 6. 触发器与自动化

### 6.1 自动统计更新

```sql
-- 章节字数汇总到书籍
CREATE OR REPLACE FUNCTION update_book_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE books SET 
            chapter_count = chapter_count + 1,
            word_count = word_count + NEW.word_count
        WHERE id = NEW.book_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE books SET 
            chapter_count = chapter_count - 1,
            word_count = word_count - OLD.word_count
        WHERE id = OLD.book_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chapter_stats_trigger
AFTER INSERT OR DELETE ON chapters
FOR EACH ROW EXECUTE FUNCTION update_book_stats();
```

### 6.2 粉丝数自动维护

```sql
-- 用户关注时自动更新粉丝数
CREATE OR REPLACE FUNCTION update_follower_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET followers_count = followers_count + 1 
        WHERE id = NEW.following_id;
        UPDATE users SET following_count = following_count + 1 
        WHERE id = NEW.follower_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

### 6.3 评分自动计算

```sql
-- 书籍评分自动更新
CREATE OR REPLACE FUNCTION update_book_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE books SET 
        avg_rating = (SELECT AVG(rating) FROM ratings WHERE book_id = NEW.book_id),
        ratings_count = (SELECT COUNT(*) FROM ratings WHERE book_id = NEW.book_id)
    WHERE id = NEW.book_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

---

## 7. 安全性设计

### 7.1 敏感数据加密

```sql
-- 身份证号加密存储
ALTER TABLE author_applications 
ALTER COLUMN id_card SET DATA TYPE BYTEA 
USING pgp_sym_encrypt(id_card::text, 'encryption_key', 'aes256');

-- 解密查询
SELECT pgp_sym_decrypt(id_card::bytea, 'encryption_key') 
FROM author_applications;
```

### 7.2 权限控制

```sql
-- 创建只读角色
CREATE ROLE report_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO report_reader;

-- 创建应用角色
CREATE ROLE app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
```

### 7.3 审计日志

```sql
-- 操作日志表
CREATE TABLE operation_logs (
    user_id     UUID,
    action      VARCHAR(50),
    target_type VARCHAR(30),
    target_id   UUID,
    before_data JSONB,
    after_data  JSONB,
    ip_address  INET,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 7.4 防注入

- 所有输入使用参数化查询
- 敏感词实时检测
- API限流保护

---

## 8. 性能优化建议

### 8.1 表结构优化

- 使用 `PARTITION` 分割大表
- 使用 `INHERITS` 实现表继承(冷热数据分离)
- 合理使用 `JSONB` 而非创建过多关联表

### 8.2 索引优化

- 避免在高频更新列上建索引
- 使用 `INCLUDE` 索引减少回表
- 定期 `REINDEX` 重建索引

### 8.3 查询优化

```sql
-- 预聚合统计表
CREATE TABLE book_daily_stats (
    book_id         UUID,
    stat_date       DATE,
    views           BIGINT DEFAULT 0,
    likes           BIGINT DEFAULT 0,
    new_followers   BIGINT DEFAULT 0,
    chapters_added  INTEGER DEFAULT 0,
    PRIMARY KEY (book_id, stat_date)
);

-- 物化视图(定期刷新)
CREATE MATERIALIZED VIEW book_stats_mv AS
SELECT 
    author_id,
    COUNT(*) as books,
    SUM(word_count) as total_words,
    SUM(views_count) as total_views
FROM books
GROUP BY author_id;

CREATE UNIQUE INDEX ON book_stats_mv(author_id);
```

### 8.4 连接池配置

```yaml
# PostgreSQL连接池建议
max_connections: 200
shared_buffers: 8GB
effective_cache_size: 24GB
work_mem: 256MB
maintenance_work_mem: 2GB
```

---

## 附录

### A. 文件结构

```
10kBooks项目/database/
├── migrations/
│   └── 001_initial_schema.sql    # 完整建表脚本
├── seeds/
│   └── 001_seed_data.sql         # 种子数据
└── schema.md                      # 本文档
```

### B. 部署说明

```bash
# 1. 创建数据库
createdb 10kbooks -E UTF8

# 2. 执行迁移
psql -d 10kbooks -f migrations/001_initial_schema.sql

# 3. 导入种子数据(可选)
psql -d 10kbooks -f seeds/001_seed_data.sql

# 4. 配置Redis
redis-server --requirepass your_redis_password
```

### C. 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0.0 | 2024-01 | 初始版本 |

---

*文档生成时间: 2024-01*  
*如有疑问请联系数据库团队*
