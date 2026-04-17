-- ============================================
-- 万卷书苑 / 10kBooks 索引优化脚本
-- 用于生产环境性能调优
-- ============================================

-- ============================================
-- 1. 部分索引(Partial Index)
-- 适用于筛选条件固定的查询
-- ============================================

-- 活跃书籍索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_books_active 
ON books (published_at DESC, avg_rating DESC) 
WHERE deleted_at IS NULL AND status = 3 AND visibility = 1;

-- VIP用户索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_vip_active 
ON users (vip_expire_at) 
WHERE vip_level > 0 AND vip_expire_at > NOW();

-- 未读通知索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_unread 
ON notifications (created_at DESC) 
WHERE is_read = FALSE;

-- 待处理审核索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_pending 
ON audit_tasks (priority, created_at) 
WHERE status IN (1, 2);

-- ============================================
-- 2. 表达式索引(Expression Index)
-- 适用于函数/计算查询
-- ============================================

-- 按日期查询订单
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_date 
ON orders (DATE(created_at)) 
WHERE payment_status = 'paid';

-- 按用户名模糊搜索(区分大小写)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_username_lower 
ON users (lower(username));

-- 按标题搜索(忽略大小写)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_books_title_lower 
ON books (lower(title)) 
WHERE deleted_at IS NULL;

-- 计算年龄
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_age 
ON users (EXTRACT(YEAR FROM AGE(birthday))) 
WHERE birthday IS NOT NULL;

-- ============================================
-- 3. 覆盖索引(Include Index)
-- 减少回表查询,适合高频读取场景
-- ============================================

-- 书籍列表覆盖索引(常用字段)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_books_list_cover 
ON books (category_id, published_at DESC) 
INCLUDE (id, title, cover_url, author_id, avg_rating, word_count, chapter_count, status)
WHERE deleted_at IS NULL;

-- 用户列表覆盖索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_list_cover 
ON users (created_at DESC) 
INCLUDE (id, username, display_name, avatar_url, vip_level, followers_count)
WHERE status = 1;

-- 章节列表覆盖索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chapters_list_cover 
ON chapters (book_id, chapter_number) 
INCLUDE (id, title, word_count, is_paywalled, published_at)
WHERE status = 3;

-- 书架列表覆盖索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_bookshelf_list_cover 
ON bookshelves (user_id, updated_at DESC) 
INCLUDE (id, book_id, status, reading_progress)
WHERE status != 4;

-- ============================================
-- 4. 复合索引顺序优化
-- 根据等值=、范围BETWEEN/IN/>/<、排序ORDER BY优化顺序
-- ============================================

-- 书籍搜索: 分类+状态+评分
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_books_search_v1 
ON books (category_id, status, avg_rating DESC) 
WHERE deleted_at IS NULL;

-- 章节搜索: 书籍+状态+发布
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_chapters_search_v1 
ON chapters (book_id, status, published_at DESC);

-- 评论搜索: 目标+状态+时间
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comments_search_v1 
ON comments (target_type, target_id, created_at DESC) 
WHERE status = 1;

-- ============================================
-- 5. JSONB索引
-- 适用于多语言/元数据查询
-- ============================================

-- 多语言标题搜索
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_books_title_i18n_en 
ON books USING gin ((title_i18n -> 'en')) 
WHERE title_i18n ? 'en';

-- 多语言标题搜索(中文)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_books_title_i18n_zh 
ON books USING gin ((title_i18n -> 'zh-CN')) 
WHERE title_i18n ? 'zh-CN';

-- 通知模板多语言
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_templates_content_zh 
ON notification_templates USING gin ((content_i18n -> 'zh-CN')) 
WHERE content_i18n ? 'zh-CN';

-- 系统配置按类型查询
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_configs_type 
ON system_configs USING gin ((config_value));

-- AI日志元数据查询
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ai_usage_meta 
ON ai_usage_logs USING gin (request_data) 
WHERE user_id IS NOT NULL;

-- ============================================
-- 6. 全文搜索索引
-- 使用pg_trgm实现模糊搜索
-- ============================================

-- 安装扩展(需要超级用户)
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 书籍标题模糊搜索
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_books_title_trgm 
ON books USING gin (title gin_trgm_ops) 
WHERE deleted_at IS NULL;

-- 作者笔名模糊搜索
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_authors_penname_trgm 
ON authors USING gin (pen_name gin_trgm_ops);

-- 用户名模糊搜索
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_username_trgm 
ON users USING gin (username gin_trgm_ops) 
WHERE status = 1;

-- 分类名称模糊搜索
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_categories_name_trgm 
ON categories USING gin ((name_i18n ->> 'zh-CN') gin_trgm_ops);

-- ============================================
-- 7. 向量相似度索引(可选)
-- 适用于AI推荐/语义搜索
-- ============================================

-- 需要安装pgvector扩展
-- CREATE EXTENSION IF NOT EXISTS vector;

-- 书籍特征向量
-- ALTER TABLE books ADD COLUMN embedding vector(1536);

-- CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_books_embedding 
-- ON books USING ivfflat (embedding vector_cosine_ops)
-- WITH (lists = 100);

-- ============================================
-- 8. 分区表索引
-- 适用于历史数据分离
-- ============================================

-- 订单表月度分区
-- CREATE TABLE orders_partitioned (
--     LIKE orders INCLUDING ALL
-- ) PARTITION BY RANGE (created_at);

-- CREATE TABLE orders_2024_01 PARTITION OF orders_partitioned
--     FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- CREATE TABLE orders_2024_02 PARTITION OF orders_partitioned
--     FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- 分区表索引
-- CREATE INDEX ON orders_2024_01 (user_id, created_at DESC);
-- CREATE INDEX ON orders_2024_02 (user_id, created_at DESC);

-- ============================================
-- 9. 索引维护
-- ============================================

-- 检查索引使用情况
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read AS index_scans,
    idx_tup_fetch AS index_hits,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_tup_read ASC;

-- 查找未使用的索引
SELECT 
    schemaname || '.' || tablename AS table,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0 
  AND indexrelid NOT IN (SELECT conindid FROM pg_constraint WHERE contype IN ('p', 'u'))
ORDER BY pg_relation_size(indexrelid) DESC;

-- 重建臃肿索引
REINDEX INDEX CONCURRENTLY idx_books_title_trgm;

-- 收集统计信息
ANALYZE VERBOSE;

-- ============================================
-- 10. 索引删除(清理无用索引)
-- ============================================

-- 删除未使用的索引(谨慎操作)
-- DROP INDEX CONCURRENTLY IF NOT EXISTS idx_unused_index_name;

-- ============================================
-- 完成标记
-- ============================================

SELECT 'Index Optimization Script v1.0.0 Completed!' AS status;
