# ============================================
# 万卷书苑 / 10kBooks - 防火墙配置
# UFW 防火墙规则
# ============================================

# ==========================================
# 基础防火墙配置
# ============================================

# 重置防火墙
ufw --force reset

# 设置默认策略
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed

# ==========================================
# SSH 配置
# ============================================

# 限制 SSH 连接频率，防止暴力破解
ufw limit 22/tcp comment 'SSH 登录'

# 如果需要从特定 IP 连接 SSH
# ufw allow from 192.168.1.100 to any port 22 proto tcp comment '管理员 SSH'

# ==========================================
# Web 服务端口
# ============================================

# HTTP
ufw allow 80/tcp comment 'HTTP'

# HTTPS
ufw allow 443/tcp comment 'HTTPS'

# ==========================================
# 应用端口 (仅内网访问)
# ============================================

# API 服务
ufw allow from 10.0.0.0/8 to any port 3000 proto tcp comment 'API 服务'

# 数据库
ufw allow from 10.0.0.0/8 to any port 5432 proto tcp comment 'PostgreSQL'

# Redis
ufw allow from 10.0.0.0/8 to any port 6379 proto tcp comment 'Redis'

# Elasticsearch
ufw allow from 10.0.0.0/8 to any port 9200 proto tcp comment 'Elasticsearch'

# ==========================================
# 监控端口 (可选，仅内网)
# ============================================

# Prometheus
ufw allow from 10.0.0.0/8 to any port 9090 proto tcp comment 'Prometheus'

# Grafana
ufw allow from 10.0.0.0/8 to any port 3001 proto tcp comment 'Grafana'

# Kibana
ufw allow from 10.0.0.0/8 to any port 5601 proto tcp comment 'Kibana'

# Loki
ufw allow from 10.0.0.0/8 to any port 3100 proto tcp comment 'Loki'

# ==========================================
# 日志配置
# ============================================

ufw logging medium

# ==========================================
# 启用防火墙
# ============================================

ufw --force enable

# ==========================================
# 查看状态
# ============================================

ufw status verbose

# ==========================================
# 常用命令
# ==========================================

# 禁用防火墙: ufw disable
# 查看规则: ufw status numbered
# 删除规则: ufw delete [number]
# 查看日志: tail -f /var/log/ufw.log
