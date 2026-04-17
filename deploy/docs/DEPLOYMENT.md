# ============================================
# 万卷书苑 / 10kBooks - 部署文档
# 完整部署指南
# ============================================

## 目录

1. [环境要求](#环境要求)
2. [快速开始](#快速开始)
3. [详细部署流程](#详细部署流程)
4. [环境配置](#环境配置)
5. [验证部署](#验证部署)
6. [常见问题](#常见问题)

---

## 环境要求

### 硬件要求

| 环境 | CPU | 内存 | 磁盘 | 说明 |
|------|-----|------|------|------|
| 开发 | 2核 | 4GB | 20GB | 本地开发 |
| 测试 | 2核 | 4GB | 50GB | 单机部署 |
| 生产 | 4核+ | 8GB+ | 100GB+ | 推荐集群 |

### 软件要求

- **操作系统**: Ubuntu 20.04+ / Debian 11+
- **Docker**: 24.0+
- **Docker Compose**: 2.20+
- **Node.js**: 20 LTS
- **PostgreSQL**: 16
- **Redis**: 7
- **Elasticsearch**: 8.x

---

## 快速开始

### 方式一：自动部署

```bash
# 下载部署脚本
curl -O https://raw.githubusercontent.com/10kbooks/deploy/main/scripts/deploy.sh

# 添加执行权限
chmod +x deploy.sh

# 运行部署 (生产环境)
sudo ./deploy.sh production

# 运行部署 (预发布环境)
sudo ./deploy.sh staging
```

### 方式二：手动部署

```bash
# 1. 克隆项目
git clone https://github.com/10kbooks/backend.git
cd backend

# 2. 复制环境变量
cp deploy/docker/.env.example .env
vim .env  # 编辑配置

# 3. 启动服务
cd deploy
docker-compose -f docker-compose.yml up -d

# 4. 检查服务状态
docker-compose ps
docker-compose logs -f api
```

---

## 详细部署流程

### 步骤 1: 服务器初始化

```bash
# 创建非 root 用户
sudo adduser deploy
sudo usermod -aG docker deploy

# 配置 SSH
sudo su - deploy
mkdir ~/.ssh
chmod 700 ~/.ssh
```

### 步骤 2: 安装 Docker

```bash
# 安装 Docker
curl -fsSL https://get.docker.com | sh

# 配置 Docker 开机自启
sudo systemctl enable docker

# 添加当前用户到 docker 组
sudo usermod -aG docker $USER
```

### 步骤 3: 配置环境变量

创建 `.env` 文件：

```bash
# 数据库
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=10kbooks
POSTGRES_USER=10kbooks

# Redis
REDIS_PASSWORD=your_redis_password

# JWT
JWT_SECRET=your_very_long_jwt_secret_key_min_32_chars

# 对象存储
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
S3_BUCKET=10kbooks-production

# 监控
GRAFANA_ADMIN_PASSWORD=your_grafana_password
```

### 步骤 4: 配置 SSL 证书

使用 Let's Encrypt 免费证书：

```bash
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d www.10kbooks.com -d api.10kbooks.com

# 自动续期测试
sudo certbot renew --dry-run
```

### 步骤 5: 部署应用

```bash
# 进入部署目录
cd /var/www/10kbooks/production

# 拉取镜像
docker-compose pull

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart
```

---

## 环境配置

### 开发环境

```bash
# 启动开发环境
docker-compose -f docker-compose.dev.yml up -d

# 运行数据库迁移
docker-compose exec api npm run migration:run

# 进入容器
docker-compose exec api sh
```

### 预发布环境

```bash
# 部署到预发布
docker-compose -f docker-compose.staging.yml up -d

# 运行迁移
docker-compose -f docker-compose.staging.yml exec api npm run migration:run
```

### 生产环境

```bash
# 拉取最新镜像
docker-compose pull

# 零停机部署
docker-compose up -d --no-deps api

# 运行迁移
docker-compose exec api npm run migration:run

# 重启 nginx
docker-compose restart nginx-proxy
```

---

## 验证部署

### 健康检查

```bash
# API 健康检查
curl https://api.10kbooks.com/health

# Web 健康检查
curl https://www.10kbooks.com/health

# 数据库连接
docker exec 10kbooks-postgres pg_isready -U 10kbooks

# Redis 连接
docker exec 10kbooks-redis redis-cli -a $REDIS_PASSWORD ping
```

### 日志查看

```bash
# API 日志
docker-compose logs -f api

# Nginx 日志
docker-compose logs -f nginx

# 所有服务日志
docker-compose logs -f

# 最近 100 行
docker-compose logs --tail=100 api
```

### 性能监控

- **Grafana**: https://monitor.10kbooks.com:3001
- **Prometheus**: http://localhost:9090
- **Kibana**: http://localhost:5601

---

## 常见问题

### Q1: 启动失败，端口被占用

```bash
# 查看端口占用
sudo netstat -tlnp | grep 80
sudo lsof -i :443

# 停止占用进程
sudo systemctl stop nginx
```

### Q2: 数据库连接失败

```bash
# 检查容器网络
docker network inspect 10kbooks-10kbooks-network

# 检查数据库日志
docker-compose logs postgres

# 进入数据库容器
docker-compose exec postgres psql -U 10kbooks
```

### Q3: 镜像拉取失败

```bash
# 登录 GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 手动拉取
docker pull ghcr.io/10kbooks/backend:latest
docker pull ghcr.io/10kbooks/frontend:latest
```

### Q4: SSL 证书过期

```bash
# 手动续期
sudo certbot renew

# 查看证书过期时间
sudo certbot certificates

# 强制续期
sudo certbot renew --force-renewal
```

### Q5: 内存不足

```bash
# 查看内存使用
free -h

# Docker 清理
docker system prune -a --volumes

# 增加 Swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## 附录

### 服务端口映射

| 服务 | 内部端口 | 外部端口 | 说明 |
|------|----------|----------|------|
| API | 3000 | 3000 | 后端服务 |
| Web | 80 | 80 | 前端服务 |
| PostgreSQL | 5432 | 5432 | 数据库 |
| Redis | 6379 | 6379 | 缓存 |
| Elasticsearch | 9200 | 9200 | 搜索 |
| Prometheus | 9090 | 9090 | 监控 |
| Grafana | 3000 | 3001 | 可视化 |

### 常用命令

```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose down

# 重启特定服务
docker-compose restart api

# 进入容器
docker-compose exec api sh

# 查看资源使用
docker stats

# 查看网络
docker network ls

# 查看卷
docker volume ls
```
