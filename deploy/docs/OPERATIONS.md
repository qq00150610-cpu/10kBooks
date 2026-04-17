# ============================================
# 万卷书苑 / 10kBooks - 运维手册
# 日常运维操作指南
# ============================================

## 目录

1. [日常巡检](#日常巡检)
2. [日志管理](#日志管理)
3. [备份恢复](#备份恢复)
4. [性能优化](#性能优化)
5. [安全维护](#安全维护)
6. [故障处理](#故障处理)
7. [应急响应](#应急响应)

---

## 日常巡检

### 自动化巡检脚本

```bash
#!/bin/bash
# deploy/scripts/daily-check.sh

echo "=========================================="
echo "  万卷书苑 / 10kBooks 每日巡检"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# 1. 服务状态检查
echo "[1/7] 检查服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. 资源使用检查
echo ""
echo "[2/7] 检查资源使用..."
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# 3. 磁盘空间检查
echo ""
echo "[3/7] 检查磁盘空间..."
df -h | grep -E "(Filesystem|/dev/)"

# 4. 数据库连接检查
echo ""
echo "[4/7] 检查数据库连接..."
docker exec 10kbooks-postgres psql -U 10kbooks -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null || echo "数据库连接失败"

# 5. Redis 检查
echo ""
echo "[5/7] 检查 Redis..."
docker exec 10kbooks-redis redis-cli -a $REDIS_PASSWORD INFO clients 2>/dev/null | grep connected_clients || echo "Redis 连接失败"

# 6. 错误日志检查
echo ""
echo "[6/7] 检查最近错误..."
docker-compose logs --tail=20 api 2>&1 | grep -i error || echo "无错误日志"

# 7. 证书有效期检查
echo ""
echo "[7/7] 检查 SSL 证书..."
certbot certificates 2>/dev/null | grep -E "Expiry|domains" || echo "无法获取证书信息"

echo ""
echo "=========================================="
echo "  巡检完成"
echo "=========================================="
```

### 巡检项目清单

| 检查项 | 频率 | 阈值 | 处理方式 |
|--------|------|------|----------|
| 服务状态 | 每小时 | 任何服务 Down | 立即告警 |
| CPU 使用率 | 每 5 分钟 | > 80% | 关注 |
| 内存使用率 | 每 5 分钟 | > 85% | 关注 |
| 磁盘使用率 | 每小时 | > 80% | 清理或扩容 |
| API 响应时间 | 每分钟 | > 2s | 检查 |
| 错误率 | 每分钟 | > 5% | 立即告警 |
| 证书有效期 | 每天 | < 30 天 | 续期 |

### Cron 定时任务

```bash
# 每天凌晨 3 点执行巡检
0 3 * * * /var/www/10kbooks/deploy/scripts/daily-check.sh >> /var/www/10kbooks/logs/daily-check.log 2>&1

# 每小时备份数据库
0 * * * * /var/www/10kbooks/deploy/scripts/backup.sh >> /var/www/10kbooks/logs/backup.log 2>&1

# 每天凌晨 4 点更新 SSL 证书
0 4 * * * certbot renew --quiet >> /var/log/letsencrypt/renew.log 2>&1
```

---

## 日志管理

### 日志配置

```yaml
# docker-compose.yml 中的日志配置
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "10"
        labels: "service,environment"
        env: "NODE_ENV"
```

### 日志收集

```bash
# 查看实时日志
docker-compose logs -f api

# 查看最近 100 行
docker-compose logs --tail=100 api

# 查看特定时间范围
docker-compose logs --since "2024-01-01T00:00:00" api

# 搜索错误
docker-compose logs api | grep ERROR

# 导出日志
docker-compose logs api > api-$(date +%Y%m%d).log
```

### 日志分析

```bash
# 统计错误类型
docker-compose logs api | grep ERROR | awk '{print $NF}' | sort | uniq -c | sort -rn

# 统计 API 调用量
docker-compose logs api | grep "GET /api" | wc -l

# 分析响应时间
docker-compose logs api | grep -oP 'rt=\d+' | sed 's/rt=//' | awk '{sum+=$1; count++} END {print "平均响应时间:", sum/count "ms"}'

# Nginx 日志分析
tail -f /var/log/nginx/access.log | goaccess -o report.html --log-format=JSON
```

---

## 备份恢复

### 备份策略

| 类型 | 频率 | 保留时间 | 存储位置 |
|------|------|----------|----------|
| 数据库全量 | 每天 | 30 天 | 本地 + S3 |
| 数据库增量 | 每小时 | 7 天 | 本地 |
| 文件上传 | 每周 | 30 天 | S3 |
| 配置文件 | 每次变更 | 90 天 | Git |

### 备份脚本

```bash
#!/bin/bash
# deploy/scripts/backup.sh

BACKUP_DIR="/var/backups/10kbooks"
DATE=$(date +%Y%m%d_%H%M%S)

# 数据库备份
docker exec 10kbooks-postgres pg_dump -U 10kbooks 10kbooks | gzip > ${BACKUP_DIR}/db_${DATE}.sql.gz

# 上传到 S3
aws s3 cp ${BACKUP_DIR}/db_${DATE}.sql.gz s3://10kbooks-backups/

# 清理本地旧备份 (保留 7 天)
find ${BACKUP_DIR} -name "*.sql.gz" -mtime +7 -delete

# 清理 S3 旧备份 (保留 30 天)
aws s3 ls s3://10kbooks-backups/ | while read line; do
  filename=$(echo $line | awk '{print $4}')
  filedate=$(echo $line | awk '{print $1}')
  if [[ $(date -d "$filedate" +%s) -lt $(date -d "30 days ago" +%s) ]]; then
    aws s3 rm s3://10kbooks-backups/$filename
  fi
done
```

### 恢复操作

```bash
# 1. 恢复数据库
gunzip < backup_file.sql.gz | docker exec -i 10kbooks-postgres psql -U 10kbooks

# 2. 或使用全量恢复
docker exec 10kbooks-postgres pg_restore -U 10kbooks -d 10kbooks -c backup_file.dump

# 3. 验证恢复
docker exec 10kbooks-postgres psql -U 10kbooks -c "SELECT count(*) FROM users;"
```

---

## 性能优化

### PostgreSQL 优化

```sql
-- 查看慢查询
SELECT query, calls, mean_time, total_time 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- 查看连接数
SELECT count(*) FROM pg_stat_activity;

-- 查看缓存命中率
SELECT 
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit) as heap_hit,
  round(100 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2) as cache_hit_ratio
FROM pg_statio_user_tables;

-- 重建索引
REINDEX INDEX CONCURRENTLY idx_users_email;

-- 更新统计信息
ANALYZE;
```

### Redis 优化

```bash
# 查看内存使用
redis-cli -a $REDIS_PASSWORD INFO memory

# 查看键统计
redis-cli -a $REDIS_PASSWORD INFO keyspace

# 查看客户端连接
redis-cli -a $REDIS_PASSWORD CLIENT LIST

# 内存碎片整理
redis-cli -a $REDIS_PASSWORD MEMORY PURGE

# 找出大键
redis-cli -a $REDIS_PASSWORD --bigkeys
```

### Nginx 优化

```nginx
# 工作进程优化
worker_processes auto;
worker_connections 4096;
multi_accept on;

# 缓冲优化
client_body_buffer_size 16k;
proxy_buffer_size 128k;
proxy_buffers 4 256k;

# 保持连接
keepalive_timeout 65;
keepalive_requests 10000;

# Gzip 压缩
gzip on;
gzip_vary on;
gzip_comp_level 6;
gzip_min_length 1024;
```

---

## 安全维护

### 安全检查清单

- [ ] 定期更新系统软件包
- [ ] 检查 SSL 证书有效期 (> 30 天)
- [ ] 审查用户权限
- [ ] 检查防火墙规则
- [ ] 审查访问日志
- [ ] 更新 Docker 镜像
- [ ] 检查 Fail2ban 封禁列表
- [ ] 审计 API 密钥和 Token

### 安全更新流程

```bash
# 1. 创建快照/备份
docker-compose exec postgres pg_dump > backup_$(date +%Y%m%d).sql

# 2. 测试环境更新
apt update && apt upgrade -y
docker-compose pull
docker-compose up -d

# 3. 健康检查
curl -f https://api.10kbooks.com/health

# 4. 生产环境更新
# (重复步骤 2-3)
```

---

## 故障处理

### 服务无响应

```bash
# 1. 检查服务状态
docker-compose ps

# 2. 查看日志
docker-compose logs -f api

# 3. 检查资源
docker stats

# 4. 重启服务
docker-compose restart api

# 5. 如仍无法恢复，查看系统日志
journalctl -u docker -n 100
```

### 数据库连接失败

```bash
# 1. 检查数据库状态
docker exec 10kbooks-postgres pg_isready

# 2. 检查网络连接
docker network inspect 10kbooks-10kbooks-network

# 3. 检查连接数
docker exec 10kbooks-postgres psql -U 10kbooks -c "SELECT count(*) FROM pg_stat_activity;"

# 4. 重启数据库
docker-compose restart postgres
```

### 磁盘空间不足

```bash
# 1. 找出大文件
du -sh /var/lib/docker/* | sort -rh | head -10

# 2. 清理 Docker
docker system prune -a --volumes

# 3. 清理日志
find /var/log -name "*.log" -mtime +7 -exec truncate -s 0 {} \;

# 4. 清理临时文件
rm -rf /tmp/*
```

---

## 应急响应

### 紧急回滚

```bash
# 查看可用版本
git tag -l

# 回滚到上一个版本
./deploy/scripts/rollback.sh previous

# 回滚到指定版本
./deploy/scripts/rollback.sh v1.2.3
```

### 服务降级

```bash
# 关闭非核心功能
docker-compose exec api npm run feature:disable recommendation

# 开启维护模式
docker-compose exec api npm run maintenance:enable

# 限流
docker-compose exec api npm run ratelimit:set -- --limit=100
```

### 联系方式

| 角色 | 联系方式 | 响应时间 |
|------|----------|----------|
| 值班工程师 | oncall@10kbooks.com | 5 分钟 |
| 技术负责人 | tech-lead@10kbooks.com | 30 分钟 |
| 紧急电话 | +86-xxx-xxxx-xxxx | 即时 |

---

## 附录

### 常用命令速查

```bash
# 服务管理
docker-compose up -d           # 启动
docker-compose down             # 停止
docker-compose restart          # 重启
docker-compose logs -f          # 查看日志

# 数据库
docker exec -it postgres psql -U 10kbooks
pg_dump -U 10kbooks 10kbooks > backup.sql

# Redis
redis-cli -a $REDIS_PASSWORD
FLUSHDB                          # 慎用！

# Nginx
nginx -t                          # 测试配置
systemctl reload nginx
tail -f /var/log/nginx/access.log

# Docker
docker stats                       # 资源使用
docker system df                   # 磁盘使用
docker network ls                  # 网络列表
```
