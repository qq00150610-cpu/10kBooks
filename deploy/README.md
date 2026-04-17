# ============================================
# 万卷书苑 / 10kBooks - 目录索引
# ============================================

```
10kBooks项目/deploy/
├── docker/                          # Docker 容器配置
│   ├── Dockerfile.backend            # 后端服务镜像
│   ├── Dockerfile.frontend          # 前端服务镜像
│   ├── docker-compose.yml           # 生产环境编排
│   ├── docker-compose.dev.yml       # 开发环境编排
│   ├── docker-compose.staging.yml   # 预发布环境编排
│   └── .env.example                 # 环境变量示例
│
├── nginx/                           # Nginx 反向代理配置
│   ├── nginx.conf                   # 主配置文件
│   ├── frontend.conf                # 前端服务配置
│   └── conf.d/                     # 子配置
│       ├── web.conf                # Web 站点配置
│       ├── api.conf                # API 服务配置
│       └── cdn.conf                # CDN 回源配置
│
├── pm2/                            # PM2 进程管理
│   ├── ecosystem.config.js         # PM2 配置文件
│   └── .env.production             # 生产环境变量
│
├── ci/                             # CI/CD 配置
│   └── github-actions.yml          # GitHub Actions 工作流
│
├── monitoring/                     # 监控配置
│   ├── prometheus/
│   │   ├── prometheus.yml          # Prometheus 采集配置
│   │   └── rules/
│   │       └── alerts.yml         # 告警规则
│   ├── loki/
│   │   └── loki.yml               # Loki 日志收集配置
│   └── grafana/
│       └── provisioning/
│           └── dashboards/
│               └── dashboard.yml   # Grafana 仪表板配置
│
├── database/                       # 数据库配置
│   ├── postgres.conf              # PostgreSQL 主从配置
│   ├── redis.conf                 # Redis 集群配置
│   ├── elasticsearch.yml          # Elasticsearch 配置
│   └── backup.sh                  # 数据库备份脚本
│
├── security/                       # 安全配置
│   ├── firewall.sh                # 防火墙规则
│   └── rate-limit.yml             # API 限流配置
│
├── cdn/                           # CDN 配置
│   └── cdn-config.md              # CDN 配置指南
│
├── scripts/                       # 运维脚本
│   ├── deploy.sh                  # 一键部署脚本
│   ├── rollback.sh                # 紧急回滚脚本
│   └── daily-check.sh             # 每日巡检脚本
│
└── docs/                          # 文档
    ├── DEPLOYMENT.md              # 部署文档
    ├── OPERATIONS.md              # 运维手册
    └── CLOUD_SERVICES.md          # 云服务配置指南
```

## 快速开始

### 1. 开发环境

```bash
cd 10kBooks项目/deploy
cp docker/.env.example .env
docker-compose -f docker-compose.dev.yml up -d
```

### 2. 生产部署

```bash
# 一键部署
sudo ./scripts/deploy.sh production
```

### 3. 查看服务状态

```bash
docker-compose ps
docker-compose logs -f api
```

## 主要配置文件说明

| 配置文件 | 用途 |
|----------|------|
| docker-compose.yml | 生产环境完整服务栈 |
| nginx.conf | 反向代理、SSL、负载均衡 |
| ecosystem.config.js | Node.js 进程管理 |
| github-actions.yml | 自动构建和部署 |
| prometheus.yml | 指标采集和告警 |
| postgres.conf | 数据库性能优化 |
| backup.sh | 自动备份策略 |

## 环境变量说明

创建 `.env` 文件时需要配置以下关键变量：

- `DATABASE_URL` - PostgreSQL 连接字符串
- `REDIS_URL` - Redis 连接字符串
- `JWT_SECRET` - JWT 密钥 (至少32字符)
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` - AWS 凭证
- `OSS_ENDPOINT` / `OSS_BUCKET` - 阿里云 OSS 配置
- `GRAFANA_ADMIN_PASSWORD` - Grafana 管理员密码

## 联系方式

如有问题，请联系运维团队：ops@10kbooks.com
