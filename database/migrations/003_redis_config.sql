-- ============================================
-- 万卷书苑 / 10kBooks Redis配置与缓存策略
-- ============================================

-- ============================================
-- 1. Redis配置说明
-- ============================================

-- Redis配置文件参考 (redis.conf)
= EXAMPLE CONFIGURATION =

# 基础配置
bind 127.0.0.1
port 6379
daemonize no
protected-mode yes
requirepass your_redis_password_here

# 内存配置
maxmemory 8gb
maxmemory-policy allkeys-lru

# 持久化配置
save 900 1      # 15分钟内有1次写入
save 300 100    # 5分钟内有100次写入
save 60 10000   # 1分钟内有10000次写入

# AOF配置
appendonly yes
appendfsync everysec
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# 慢查询日志
slowlog-log-slower-than 10000
slowlog-max-len 128

# 客户端
maxclients 10000

-- ============================================
-- 2. Key设计规范
-- ============================================

/*
命名规范: {entity}:{id}:{field}:{extra}
分隔符: 冒号(:)
避免: 过长key、特殊字符

示例:
- user:u123:profile      -> 用户资料
- book:b456:info         -> 书籍信息
- session:token789       -> 登录会话
*/

-- ============================================
-- 3. 数据结构示例
-- ============================================

-- STRING: 简单值
SET user:wallet:u123 '{"coins":500,"points":1200}'
SET user:vip:u123 '{"level":3,"expire_at":"2025-12-31"}'
SET book:rating:b456 '{"avg":4.8,"count":52000}'
TTL user:wallet:u123 300  -- 5分钟

-- HASH: 结构化数据
HSET book:b456:info title "仙武帝尊" author "云起书院" chapters 1568 words 5800000
HGET book:b456:info title
HGETALL book:b456:info

-- LIST: 队列/列表
RPUSH queue:ai_task '{"task_id":"t001","type":"translation"}'
LPOP queue:ai_task
LLEN queue:ai_task

-- SET: 标签/去重
SADD user:u123:reading_tags "fantasy" "cultivation" "xianxia"
SMEMBERS user:u123:reading_tags
SISMEMBER user:u123:reading_tags "fantasy"

-- SORTED SET: 排行榜/有序列表
ZADD books:hot:zh-CN:daily 9500 "b001" 1500 "b002"
ZREVRANGE books:hot:zh-CN:daily 0 9 WITHSCORES
ZINCRBY books:hot:zh-CN:daily 100 "b001"

-- BITMAP: 签到/状态位
SETBIT user:u123:checkin:2024 15 1  -- 2024年1月16日签到
GETBIT user:u123:checkin:2024 15
BITCOUNT user:u123:checkin:2024     -- 连续签到天数

-- HYPERLOGLOG: 统计去重
PFADD books:b456:viewers "user1" "user2" "user3"
PFCOUNT books:b456:viewers

-- GEO: 地理位置(作者签售会等)
GEOADD events:locations 116.4074 39.9042 "beijing_signing"
GEORADIUS events:locations 116.4 39.9 50 km WITHDIST ASC COUNT 10

-- ============================================
-- 4. 业务缓存策略
-- ============================================

/*
缓存策略分层:
L1: 本地缓存(Caffeine/Guava) - 热数据,毫秒级
L2: Redis缓存 - 共享数据,亚毫秒级
L3: 数据库 - 持久化存储,毫秒级

更新策略: Cache-Aside
读取: Cache Miss -> DB -> Cache
写入: DB -> Cache Delete(不是更新)
*/

-- ============================================
-- 5. 具体业务缓存实现
-- ============================================

-- 5.1 用户Session
-- Key: session:{token}
-- Value: JSON用户信息
-- TTL: 30天
-- 用途: 登录状态验证
SET session:abc123def '{"user_id":"u001","username":"reader","vip_level":3}'
EXPIRE session:abc123def 2592000

-- 5.2 用户钱包
-- Key: user:wallet:{user_id}
-- Value: {coins, points}
-- TTL: 5分钟
-- 用途: 余额查询
SET user:wallet:u001 '{"coins":500,"points":1200}'
EXPIRE user:wallet:u001 300

-- 5.3 VIP状态
-- Key: user:vip:{user_id}
-- Value: {level, expire_at}
-- TTL: 1小时
-- 用途: 权限校验
SET user:vip:u001 '{"level":3,"expire_at":"2025-12-31"}'
EXPIRE user:vip:u001 3600

-- 5.4 书籍缓存
-- Key: book:info:{book_id}
-- Value: 书籍基本信息
-- TTL: 1小时
SET book:info:b001 '{"title":"仙武帝尊","author":"云起书院","chapters":1568}'

-- Key: book:rating:{book_id}
-- Value: {avg_rating, count}
-- TTL: 10分钟
SET book:rating:b001 '{"avg":4.8,"count":52000}'
EXPIRE book:rating:b001 600

-- 5.5 热门榜单
-- Key: books:hot:{locale}:{period}
-- Type: Sorted Set
-- Score: 热度分数
-- Value: book_id
-- TTL: 滚动更新
ZADD books:hot:zh-CN:daily 9500000 "b001" 8500000 "b002" 7200000 "b003"
ZADD books:hot:zh-CN:weekly 15000000 "b001" 12000000 "b002"
ZADD books:hot:zh-CN:monthly 50000000 "b001" 38000000 "b002"

-- 热度计算公式(可配置)
-- hot_score = views*0.2 + likes*0.3 + followers*0.4 + ratings*10

-- 5.6 新书上架
-- Key: books:new:{locale}
-- Type: Sorted Set
-- Score: 发布时间戳
ZADD books:new:zh-CN 1705401600 "b010" 1705315200 "b011"

-- 5.7 阅读进度
-- Key: reading:{user_id}:{book_id}
-- Value: {chapter_id, progress, last_read}
-- TTL: 7天
SET reading:u001:b001 '{"chapter_id":"c002","progress":78.5,"last_read":"2024-01-16T10:30:00Z"}'
EXPIRE reading:u001:b001 604800

-- 5.8 书架缓存
-- Key: bookshelf:{user_id}
-- Type: List
-- Value: book_id列表
-- TTL: 10分钟
RPUSH bookshelf:u001 "b001" "b002" "b003"

-- 5.9 通知未读数
-- Key: notification:unread:{user_id}
-- Type: String
-- Value: 数量
SET notification:unread:u001 5

-- 5.10 作者收益缓存
-- Key: author:earnings:{author_id}
-- Value: {total, withdrawable, pending}
-- TTL: 5分钟
SET author:earnings:a001 '{"total":1000000,"withdrawable":500000,"pending":500000}'
EXPIRE author:earnings:a001 300

-- ============================================
-- 6. 限流策略
-- ============================================

-- 6.1 API限流
-- Key: rate:api:{user_id}:{minute}
-- Type: String
-- TTL: 60秒
INCR rate:api:u001:2024011610
EXPIRE rate:api:u001:2024011610 60
-- 检查: GET rate:api:u001:2024011610 > 100 则限流

-- 6.2 章节发布限流
-- Key: rate:publish:{user_id}:{date}
-- Type: String
-- TTL: 86400秒
INCR rate:publish:a001:20240116
-- 检查: GET rate:publish:a001:20240116 > 10 则限流

-- 6.3 验证码限流
-- Key: rate:sms:{phone}:{type}
-- Type: String
-- TTL: 3600秒
INCR rate:sms:13800138000:login
EXPIRE rate:sms:13800138000:login 3600
-- 检查: GET rate:sms:13800138000:login > 5 则限流

-- ============================================
-- 7. 分布式锁
-- ============================================

-- 7.1 订单创建锁
-- Key: lock:order:create:{user_id}
-- Value: request_id
-- TTL: 30秒
SET lock:order:create:u001 "req-123" NX EX 30

-- 7.2 余额扣减锁
-- Key: lock:wallet:deduct:{user_id}
-- Value: request_id
-- TTL: 10秒
SET lock:wallet:deduct:u001 "req-456" NX EX 10

-- 7.3 章节发布锁
-- Key: lock:chapter:publish:{book_id}
-- Value: request_id
-- TTL: 60秒
SET lock:chapter:publish:b001 "req-789" NX EX 60

-- ============================================
-- 8. 排行榜实现
-- ============================================

-- 8.1 日榜
ZADD books:hot:zh-CN:daily 9500 "b001"
-- 更新: 实时增量
ZINCRBY books:hot:zh-CN:daily 100 "b001"
-- 过期: 每日凌晨重置
DEL books:hot:zh-CN:daily

-- 8.2 周榜/月榜
ZUNIONSTORE books:hot:zh-CN:weekly 7 books:hot:zh-CN:daily:d1 books:hot:zh-CN:daily:d2 ...

-- 8.3 作家收入榜
ZADD authors:earnings:monthly 500000 "a001"
ZREVRANK authors:earnings:monthly "a001"  -- 获取排名
ZREVRANGE authors:earnings:monthly 0 9 WITHSCORES  -- TOP10

-- 8.4 用户活跃榜
ZADD users:activity:daily 150 "u001"
ZINCRBY users:activity:daily 50 "u001"

-- ============================================
-- 9. 消息队列
-- ============================================

-- 9.1 AI任务队列
RPUSH queue:ai_task '{"task_id":"t001","type":"translation","priority":1}'
BRPOP queue:ai_task 0  -- 阻塞等待

-- 9.2 通知队列
RPUSH queue:notification '{"user_id":"u001","type":"new_chapter","content":"..."}'

-- 9.3 邮件队列
RPUSH queue:email '{"to":"user@example.com","subject":"新章节更新","body":"..."}'

-- 9.4 日志队列
RPUSH queue:logs '{"level":"info","message":"user login","user_id":"u001"}'

-- ============================================
-- 10. 布隆过滤器
-- ============================================

-- 需要Redis 7.4+ 或 RedisBloom模块

-- 10.1 用户已读书籍
BF.ADD user:read:b001 "u001"
BF.EXISTS user:read:b001 "u001"
BF.MADD user:read:b001 "u001" "u002" "u003"

-- 10.2 黑名单IP
BF.ADD ip:blacklist "192.168.1.1"
BF.EXISTS ip:blacklist "192.168.1.1"

-- 10.3 敏感词
BF.ADD sensitive:words "赌博"
BF.EXISTS sensitive:words "赌博"

-- ============================================
-- 11. 管道与批量操作
-- ============================================

-- 批量获取用户书架信息
PIPELINE
  GET book:info:b001
  GET book:info:b002
  GET book:info:b003
END

-- 批量更新热度
PIPELINE
  ZINCRBY books:hot:zh-CN:daily 100 "b001"
  ZINCRBY books:hot:zh-CN:daily 50 "b002"
  ZINCRBY books:hot:zh-CN:daily 200 "b003"
END

-- 批量更新阅读数
PIPELINE
  HINCRBY book:b001:stats views 1
  HINCRBY book:b002:stats views 1
END

-- ============================================
-- 12. 集群配置(Redis Cluster)
-- ============================================

= REDIS CLUSTER CONFIG =

# 6个节点(3主3从)
# 192.168.1.1:7000 (主)
# 192.168.1.2:7000 (主)
# 192.168.1.3:7000 (主)
# 192.168.1.4:7000 (从)
# 192.168.1.5:7000 (从)
# 192.168.1.6:7000 (从)

# Hash槽分配
# 节点1: 0-5460
# 节点2: 5461-10922
# 节点3: 10923-16383

# Key路由(确保相关数据在同一分片)
# user:* -> 哈希标签 {user}
# book:* -> 哈希标签 {book}

= EXAMPLE: 哈希标签确保同一用户数据在同一节点 =
SET user:{u001}:session "token123"
SET user:{u001}:wallet "500"
-- session和wallet会被路由到同一节点

-- ============================================
-- 13. 监控指标
-- ============================================

= METRICS TO MONITOR =

# 内存
INFO memory | grep used_memory_human
INFO memory | grep mem_fragmentation_ratio

# 命中率
INFO stats | grep keyspace_hits
INFO stats | grep keyspace_misses

# 命令统计
INFO commandstats | grep -E "(cmdstat_get|cmdstat_set|cmdstat_zadd)"

# 慢查询
SLOWLOG GET 10

# 连接数
INFO clients | grep connected_clients

-- ============================================
-- 完成标记
-- ============================================

SELECT 'Redis Configuration v1.0.0 Reference Completed!' AS status;
