# 万卷书苑 / 10kBooks 数据库项目

> 多语言在线阅读与创作平台数据库架构

## 📁 项目结构

```
10kBooks项目/database/
├── migrations/
│   ├── 001_initial_schema.sql    # 核心数据库架构(10+核心表)
│   ├── 002_index_optimization.sql # 索引优化脚本
│   └── 003_redis_config.sql        # Redis配置参考
├── seeds/
│   └── 001_seed_data.sql          # 测试种子数据
├── schema.md                       # 完整架构文档
└── README.md                       # 本文件
```

## 🚀 快速开始

### 1. 创建数据库

```bash
# 登录PostgreSQL
psql -U postgres

# 创建数据库
CREATE DATABASE 10kbooks ENCODING 'UTF8' LC_COLLATE 'zh_CN.UTF-8' LC_CTYPE 'zh_CN.UTF-8';

# 退出
\q
```

### 2. 执行迁移

```bash
# 方式一: 完整迁移(推荐)
psql -d 10kbooks -U postgres -f migrations/001_initial_schema.sql

# 方式二: 分步执行
psql -d 10kbooks -U postgres -f migrations/001_initial_schema.sql
psql -d 10kbooks -U postgres -f migrations/002_index_optimization.sql
psql -d 10kbooks -U postgres -f migrations/003_redis_config.sql
```

### 3. 导入种子数据(可选)

```bash
psql -d 10kbooks -U postgres -f seeds/001_seed_data.sql
```

### 4. 验证安装

```sql
-- 连接数据库
psql -d 10kbooks

-- 检查表
\dt

-- 检查数据
SELECT 'Users:' AS info, COUNT(*) FROM users
UNION ALL SELECT 'Authors:', COUNT(*) FROM authors
UNION ALL SELECT 'Books:', COUNT(*) FROM books
UNION ALL SELECT 'Chapters:', COUNT(*) FROM chapters;
```

## 📊 核心模块

| 模块 | 表数量 | 说明 |
|------|--------|------|
| 用户系统 | 4 | users, user_settings, user_wallets, user_sessions |
| 作者系统 | 3 | authors, author_applications, author_settlements |
| 书籍系统 | 6 | books, chapters, categories, tags, book_translations, book_pricing |
| 阅读功能 | 4 | bookshelves, reading_progress, bookmarks, reading_notes |
| 社交系统 | 5 | user_follows, book_activities, comments, ratings, likes |
| 订单支付 | 6 | orders, purchases, vip_subscriptions, recharge_packages, withdrawals, invitations |
| 通知系统 | 3 | notifications, notification_templates, push_devices |
| 审核系统 | 3 | audit_tasks, sensitive_words, audit_logs |
| AI系统 | 3 | ai_models, ai_usage_logs, ai_tasks |
| 系统支撑 | 2 | system_configs, operation_logs |

**总计: 10个核心模块, 38+数据表**

## 🔧 技术特性

### 数据库特性
- ✅ UUID主键 - 分布式友好
- ✅ 软删除 - 数据可恢复
- ✅ JSONB多语言 - 灵活存储
- ✅ 触发器 - 自动统计
- ✅ 分区表支持 - 海量数据
- ✅ 全文搜索 - pg_trgm扩展

### 缓存特性
- ✅ Redis 7 完整配置
- ✅ 排行榜实现
- ✅ 分布式锁
- ✅ 消息队列
- ✅ 布隆过滤器

## 📖 文档索引

| 文档 | 内容 |
|------|------|
| [schema.md](schema.md) | 完整架构说明,包含ER图、字段说明、优化建议 |
| [migrations/001_initial_schema.sql](migrations/001_initial_schema.sql) | 核心建表语句,可直接执行 |
| [migrations/002_index_optimization.sql](migrations/002_index_optimization.sql) | 索引优化脚本,生产环境使用 |
| [migrations/003_redis_config.sql](migrations/003_redis_config.sql) | Redis配置与缓存策略参考 |
| [seeds/001_seed_data.sql](seeds/001_seed_data.sql) | 测试数据,可按需导入 |

## 🔐 默认账户

种子数据包含以下测试账户:

| 用户名 | 密码 | 角色 |
|--------|------|------|
| reader_demo | demo123 | 普通用户 |
| vip_reader | demo123 | VIP用户 |
| author_demo | demo123 | 作者 |
| admin | demo123 | 管理员 |

> ⚠️ 生产环境请务必修改默认密码!

## 📋 开发规范

### 命名规范
- 表名: 小写字母 + 下划线 (snake_case)
- 字段名: 小写字母 + 下划线
- 索引名: idx_表名_字段
- 触发器: trigger_表名_动作

### 字段规范
- 主键: UUID, 默认值 `uuid_generate_v4()`
- 时间戳: `TIMESTAMPTZ DEFAULT NOW()`
- 软删除: `deleted_at TIMESTAMPTZ`
- 金额: 整数(分), 非DECIMAL
- 多语言: JSONB

### 索引规范
- 常用查询字段建立索引
- 避免过多索引影响写入
- 定期检查并清理无用索引
- 生产环境使用 `CONCURRENTLY`

## 🔄 数据迁移

### 新增字段
```sql
ALTER TABLE books ADD COLUMN translation_count INTEGER DEFAULT 0;
```

### 新增表
```sql
-- 1. 编写迁移脚本
-- 2. 测试环境验证
-- 3. 生产环境执行(使用事务)
BEGIN;
-- ALTER/CREATE 语句
INSERT INTO migration_history (version, name) VALUES ('v1.1', 'add_translation_count');
COMMIT;
```

### 数据回滚
```sql
-- 创建回滚脚本
ALTER TABLE books DROP COLUMN IF EXISTS translation_count;
```

## 📈 性能监控

```sql
-- 查看慢查询
SELECT * FROM pg_stat_statements 
ORDER BY mean_exec_time DESC LIMIT 10;

-- 查看索引使用
SELECT * FROM pg_stat_user_indexes 
WHERE idx_scan = 0;

-- 查看表大小
SELECT relname, pg_size_pretty(pg_total_relation_size(relid))
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- 查看膨胀率
SELECT tablename, indexname, idx_scan, pg_size_pretty(pg_relation_size(indexrelid))
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;
```

## 🆘 常见问题

### Q: 如何重置数据库?
```bash
# 方式一: 删除重建
dropdb 10kbooks
createdb 10kbooks
psql -d 10kbooks -f migrations/001_initial_schema.sql
psql -d 10kbooks -f seeds/001_seed_data.sql

# 方式二: 执行清理脚本
psql -d 10kbooks -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
psql -d 10kbooks -f migrations/001_initial_schema.sql
```

### Q: 触发器不生效?
```sql
-- 检查触发器状态
SELECT trigger_name, event_manipulation, action_timing, event_object_schema
FROM information_schema.triggers
WHERE event_object_table = 'chapters';

-- 重新创建触发器
DROP TRIGGER IF EXISTS chapter_stats_trigger ON chapters;
CREATE TRIGGER chapter_stats_trigger
AFTER INSERT OR DELETE ON chapters
FOR EACH ROW EXECUTE FUNCTION update_book_stats();
```

### Q: Redis连接失败?
```bash
# 检查Redis状态
redis-cli ping

# 如果需要密码
redis-cli -a your_password ping

# 查看Redis日志
tail -f /var/log/redis/redis-server.log
```

## 📞 支持

- 文档版本: v1.0.0
- 最后更新: 2024-01
- 技术支持: 请提交Issue

---

**Happy Coding! 📚**
