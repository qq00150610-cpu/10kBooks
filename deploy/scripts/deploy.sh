#!/bin/bash
# ============================================
# 万卷书苑 / 10kBooks - 一键部署脚本
# 适用于全新服务器初始化
# ============================================

set -euo pipefail

# ==========================================
# 颜色输出
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# ==========================================
# 配置
# ==========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR="/var/www/10kbooks"
ENVIRONMENT=${1:-production}
VERSION=${2:-latest}

# 服务配置
NGINX_VERSION="1.25"
NODE_VERSION="20"
POSTGRES_VERSION="16"
REDIS_VERSION="7"

# ==========================================
# 前置检查
# ==========================================

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 root 权限运行此脚本"
        exit 1
    fi
}

check_os() {
    if [ ! -f /etc/os-release ]; then
        log_error "无法检测操作系统"
        exit 1
    fi
    
    . /etc/os-release
    if [ "$ID" != "ubuntu" ] && [ "$ID" != "debian" ]; then
        log_warn "此脚本主要针对 Ubuntu/Debian 优化，其他系统可能需要调整"
    fi
}

# ==========================================
# 系统初始化
# ==========================================

update_system() {
    log_step "更新系统软件包..."
    apt update && apt upgrade -y
}

install_dependencies() {
    log_step "安装系统依赖..."
    
    apt install -y \
        curl \
        wget \
        git \
        vim \
        htop \
        net-tools \
        ca-certificates \
        gnupg \
        lsb-release \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        fail2ban \
        ufw \
        logrotate
    
    log_info "系统依赖安装完成"
}

install_docker() {
    log_step "安装 Docker..."
    
    if command -v docker &> /dev/null; then
        log_warn "Docker 已安装，跳过"
        return
    fi
    
    # 添加 Docker GPG 密钥
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # 添加 Docker 仓库
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装 Docker
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # 启动 Docker
    systemctl enable docker
    systemctl start docker
    
    # 配置 Docker 日志轮转
    cat > /etc/docker/daemon.json << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "5"
    },
    "storage-driver": "overlay2"
}
EOF
    
    systemctl restart docker
    
    log_info "Docker 安装完成"
}

install_nginx() {
    log_step "安装 Nginx..."
    
    if command -v nginx &> /dev/null; then
        log_warn "Nginx 已安装，跳过"
        return
    fi
    
    # 添加 Nginx 仓库
    echo "deb http://nginx.org/packages/mainline/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") nginx" | tee /etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/nginx.gpg
    
    apt update
    apt install -y nginx
    
    # 启动 Nginx
    systemctl enable nginx
    systemctl start nginx
    
    log_info "Nginx 安装完成"
}

install_node() {
    log_step "安装 Node.js ${NODE_VERSION}..."
    
    if command -v node &> /dev/null; then
        CURRENT_NODE=$(node -v)
        log_warn "Node.js 已安装 (v${CURRENT_NODE})，跳过"
        return
    fi
    
    # 添加 NodeSource 仓库
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt install -y nodejs
    
    # 安装 PM2
    npm install -g pm2
    
    log_info "Node.js 安装完成"
}

install_postgres() {
    log_step "安装 PostgreSQL ${POSTGRES_VERSION}..."
    
    if command -v psql &> /dev/null; then
        log_warn "PostgreSQL 已安装，跳过"
        return
    fi
    
    # 添加 PostgreSQL 仓库
    echo "deb http://apt.postgresql.org/pub/repos/apt $(. /etc/os-release && echo "$VERSION_CODENAME")-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
    
    apt update
    apt install -y postgresql-${POSTGRES_VERSION}
    
    # 启动 PostgreSQL
    systemctl enable postgresql
    systemctl start postgresql
    
    log_info "PostgreSQL 安装完成"
}

# ==========================================
# 安全配置
# ==========================================

configure_firewall() {
    log_step "配置防火墙..."
    
    # 重置防火墙规则
    ufw --force reset
    
    # 设置默认策略
    ufw default deny incoming
    ufw default allow outgoing
    
    # 允许 SSH
    ufw allow 22/tcp
    
    # 允许 HTTP/HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # 允许监控端口 (内网)
    ufw allow from 10.0.0.0/8 to any port 9090 proto tcp  # Prometheus
    ufw allow from 10.0.0.0/8 to any port 3001 proto tcp  # Grafana
    ufw allow from 10.0.0.0/8 to any port 5601 proto tcp  # Kibana
    
    # 启用防火墙
    echo "y" | ufw enable
    
    log_info "防火墙配置完成"
}

configure_fail2ban() {
    log_step "配置 Fail2ban..."
    
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = admin@10kbooks.com
sender = fail2ban@10kbooks.com

[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 5

[nginx-noscript]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 3

[nginx-badbots]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2
EOF
    
    systemctl enable fail2ban
    systemctl restart fail2ban
    
    log_info "Fail2ban 配置完成"
}

# ==========================================
# 应用部署
# ==========================================

create_user() {
    log_step "创建部署用户..."
    
    if id "deploy" &>/dev/null; then
        log_warn "用户 deploy 已存在，跳过"
        return
    fi
    
    useradd -m -s /bin/bash -G docker,www-data deploy
    
    # 配置 sudo 权限
    echo "deploy ALL=(ALL) NOPASSWD: /usr/bin/docker" >> /etc/sudoers
    
    log_info "部署用户创建完成"
}

setup_directories() {
    log_step "创建部署目录..."
    
    mkdir -p "${DEPLOY_DIR}"/{production,staging}
    mkdir -p "${DEPLOY_DIR}/backups"/{postgres,elasticsearch,uploads}
    mkdir -p "${DEPLOY_DIR}/logs"/{nginx,api}
    mkdir -p "${DEPLOY_DIR}/ssl"
    mkdir -p "${DEPLOY_DIR}/uploads"
    
    chown -R deploy:www-data "${DEPLOY_DIR}"
    chmod -R 755 "${DEPLOY_DIR}"
    
    log_info "部署目录创建完成"
}

deploy_application() {
    log_step "部署应用..."
    
    cd "${DEPLOY_DIR}/${ENVIRONMENT}"
    
    # 拉取最新代码或指定版本
    if [ "$VERSION" == "latest" ]; then
        docker-compose pull
    else
        # 拉取指定版本
        docker-compose pull api web
        docker tag ghcr.io/10kbooks/backend:latest ghcr.io/10kbooks/backend:${VERSION}
        docker tag ghcr.io/10kbooks/frontend:latest ghcr.io/10kbooks/frontend:${VERSION}
    fi
    
    # 启动服务
    docker-compose up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 30
    
    # 运行数据库迁移
    docker-compose exec -T api npm run migration:run
    
    log_info "应用部署完成"
}

# ==========================================
# SSL 证书配置
# ==========================================

setup_ssl() {
    log_step "配置 SSL 证书..."
    
    if [ ! -d "/etc/letsencrypt/live/www.10kbooks.com" ]; then
        # 安装 Certbot
        apt install -y certbot python3-certbot-nginx
        
        # 获取证书
        certbot --nginx -d www.10kbooks.com -d 10kbooks.com -d api.10kbooks.com --non-interactive --agree-tos -m admin@10kbooks.com
        
        # 设置自动续期
        echo "0 0 * * * certbot renew --quiet" | crontab -
    fi
    
    # 复制证书到部署目录
    cp /etc/letsencrypt/live/www.10kbooks.com/fullchain.pem "${DEPLOY_DIR}/ssl/10kbooks.com.pem"
    cp /etc/letsencrypt/live/www.10kbooks.com/privkey.pem "${DEPLOY_DIR}/ssl/10kbooks.com.key"
    cp /etc/letsencrypt/live/www.10kbooks.com/chain.pem "${DEPLOY_DIR}/ssl/ca-chain.pem"
    
    chown deploy:www-data "${DEPLOY_DIR}/ssl"/*.pem "${DEPLOY_DIR}/ssl"/*.key
    chmod 600 "${DEPLOY_DIR}/ssl"/*.key
    
    log_info "SSL 证书配置完成"
}

# ==========================================
# 监控配置
# ==========================================

setup_monitoring() {
    log_step "配置监控系统..."
    
    # 创建监控数据卷
    docker volume create prometheus_data || true
    docker volume create grafana_data || true
    docker volume create loki_data || true
    
    # 启动监控栈
    cd "${DEPLOY_DIR}/${ENVIRONMENT}"
    docker-compose up -d prometheus grafana loki
    
    log_info "监控系统配置完成"
}

# ==========================================
# 健康检查
# ==========================================

health_check() {
    log_step "执行健康检查..."
    
    # API 健康检查
    if curl -sf http://localhost:3000/health > /dev/null; then
        log_info "✅ API 服务正常"
    else
        log_error "❌ API 服务异常"
    fi
    
    # Nginx 健康检查
    if curl -sf http://localhost/health > /dev/null; then
        log_info "✅ Nginx 服务正常"
    else
        log_error "❌ Nginx 服务异常"
    fi
    
    # 数据库连接检查
    if docker exec 10kbooks-postgres pg_isready -U 10kbooks > /dev/null 2>&1; then
        log_info "✅ PostgreSQL 服务正常"
    else
        log_error "❌ PostgreSQL 服务异常"
    fi
}

# ==========================================
# 清理
# ==========================================

cleanup() {
    log_step "清理临时文件..."
    
    apt autoremove -y
    apt autoclean -y
    
    log_info "清理完成"
}

# ==========================================
# 主流程
# ==========================================

main() {
    echo ""
    echo "=========================================="
    echo "  万卷书苑 / 10kBooks 一键部署脚本"
    echo "=========================================="
    echo ""
    echo "部署环境: ${ENVIRONMENT}"
    echo "部署版本: ${VERSION}"
    echo ""
    
    check_root
    check_os
    
    log_info "开始部署流程..."
    
    # 系统初始化
    update_system
    install_dependencies
    install_docker
    install_nginx
    install_node
    install_postgres
    
    # 安全配置
    configure_firewall
    configure_fail2ban
    
    # 应用部署
    create_user
    setup_directories
    deploy_application
    
    # SSL 和监控
    setup_ssl
    setup_monitoring
    
    # 最终检查
    health_check
    cleanup
    
    echo ""
    echo "=========================================="
    log_info "部署完成!"
    echo "=========================================="
    echo ""
    echo "访问地址:"
    echo "  Web: https://www.10kbooks.com"
    echo "  API: https://api.10kbooks.com"
    echo "  监控: http://localhost:3001"
    echo ""
}

main "$@"
