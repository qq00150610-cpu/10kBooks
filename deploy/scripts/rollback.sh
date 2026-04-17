# ============================================
# 万卷书苑 / 10kBooks - 回滚脚本
# 紧急回滚部署
# ============================================

#!/bin/bash
# ============================================
# 紧急回滚脚本
# 使用方法: ./rollback.sh [version] [environment]
# 示例: ./rollback.sh v1.2.3 production
# ============================================

set -euo pipefail

# ==========================================
# 配置
# ==========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="/var/backups/10kbooks/deployments"
ENVIRONMENT=${2:-production}

# SSH 配置
if [ "$ENVIRONMENT" == "production" ]; then
    SSH_HOST="$PROD_HOST"
    SSH_USER="$PROD_USER"
    APP_DIR="/var/www/10kbooks/production"
else
    SSH_HOST="$STAGING_HOST"
    SSH_USER="$STAGING_USER"
    APP_DIR="/var/www/10kbooks/staging"
fi

# ==========================================
# 颜色输出
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ==========================================
# 函数
# ==========================================

show_usage() {
    echo "用法: $0 [version] [environment]"
    echo ""
    echo "参数:"
    echo "  version      要回滚到的版本 (例如: v1.2.3)"
    echo "  environment 部署环境 (staging 或 production, 默认: production)"
    echo ""
    echo "示例:"
    echo "  $0 v1.2.3 production"
    echo "  $0 previous staging"
    echo ""
    echo "不带参数运行将列出可用版本"
}

list_versions() {
    log_info "可用的部署版本:"
    ls -la "${BACKUP_DIR}" | grep -E "^d" | awk '{print $NF}' | sort -V
}

rollback_version() {
    local version=$1
    
    log_warn "开始回滚到版本: $version"
    
    # 确认操作
    read -p "确认回滚? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        log_info "回滚已取消"
        exit 0
    fi
    
    # 创建当前版本备份
    log_info "创建当前版本备份..."
    ssh -o StrictHostKeyChecking=no "${SSH_USER}@${SSH_HOST}" << 'EOF'
        cd /var/www/10kbooks/production
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        docker-compose pull
        docker-compose ps --format json > /tmp/current_deployment_${TIMESTAMP}.json
        cp -r uploads /tmp/uploads_backup_${TIMESTAMP}
        echo "当前部署已备份"
    EOF
    
    # 执行回滚
    log_info "执行回滚..."
    ssh -o StrictHostKeyChecking=no "${SSH_USER}@${SSH_HOST}" << 'EOF'
        cd /var/www/10kbooks/production
        
        # 拉取指定版本镜像
        VERSION=$1
        docker pull ghcr.io/10kbooks/backend:${VERSION}
        docker pull ghcr.io/10kbooks/frontend:${VERSION}
        
        # 更新 docker-compose 使用指定版本
        sed -i "s|image: ghcr.io/10kbooks/backend.*|image: ghcr.io/10kbooks/backend:${VERSION}|" docker-compose.yml
        sed -i "s|image: ghcr.io/10kbooks/frontend.*|image: ghcr.io/10kbooks/frontend:${VERSION}|" docker-compose.yml
        
        # 重启服务
        docker-compose up -d --no-deps
        
        # 等待服务启动
        sleep 30
        
        # 检查健康状态
        if curl -f http://localhost:3000/health; then
            echo "API 服务健康检查通过"
        else
            echo "警告: API 服务健康检查失败"
        fi
    EOF
    
    # 健康检查
    log_info "执行健康检查..."
    sleep 10
    
    if curl -sf "https://api.10kbooks.com/health" > /dev/null; then
        log_info "✅ 回滚成功"
    else
        log_error "❌ 回滚后健康检查失败，请立即检查!"
    fi
}

rollback_previous() {
    log_warn "回滚到上一个版本..."
    
    ssh -o StrictHostKeyChecking=no "${SSH_USER}@${SSH_HOST}" << 'EOF'
        cd /var/www/10kbooks/production
        
        # 获取上一个版本标签
        PREV_TAG=$(git describe --tags --abbrev=0 HEAD^)
        
        echo "将回滚到版本: ${PREV_TAG}"
        
        # 执行回滚
        docker-compose pull
        docker-compose up -d --no-deps
        
        sleep 30
        
        echo "回滚完成"
    EOF
}

# ==========================================
# 主流程
# ==========================================

main() {
    VERSION=${1:-}
    
    if [ -z "$VERSION" ]; then
        show_usage
        echo ""
        list_versions
        exit 0
    fi
    
    if [ "$VERSION" == "previous" ]; then
        rollback_previous
    else
        rollback_version "$VERSION"
    fi
}

main "$@"
