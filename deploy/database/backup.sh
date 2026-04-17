#!/bin/bash
# ============================================
# 万卷书苑 / 10kBooks - 数据库备份脚本
# 支持 PostgreSQL 和 Elasticsearch
# ============================================

set -euo pipefail

# ==========================================
# 配置
# ==========================================

# 备份目录
BACKUP_DIR="/var/backups/10kbooks"
DATE=$(date +%Y%m%d_%H%M%S)
KEEP_DAYS=30

# PostgreSQL 配置
PG_HOST="localhost"
PG_PORT="5432"
PG_DB="10kbooks"
PG_USER="10kbooks"
PG_PASSWORD=""

# Elasticsearch 配置
ES_HOST="localhost:9200"
ES_USER="elastic"
ES_PASSWORD=""
ES_INDEX="books,user_activities"

# S3 配置 (备份上传)
S3_BUCKET="s3://10kbooks-backups"
S3_REGION="ap-east-1"

# 日志
LOG_FILE="${BACKUP_DIR}/logs/backup_${DATE}.log"

# ==========================================
# 函数
# ==========================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# 创建备份目录
setup_backup_dir() {
    mkdir -p "${BACKUP_DIR}/postgres"
    mkdir -p "${BACKUP_DIR}/elasticsearch"
    mkdir -p "${BACKUP_DIR}/logs"
    mkdir -p "${BACKUP_DIR}/uploads"
}

# PostgreSQL 备份
backup_postgres() {
    log "开始 PostgreSQL 备份..."
    
    export PGPASSWORD="${PG_PASSWORD}"
    
    # 全量备份
    pg_dump -h "${PG_HOST}" \
            -p "${PG_PORT}" \
            -U "${PG_USER}" \
            -d "${PG_DB}" \
            -Fc \
            -f "${BACKUP_DIR}/postgres/full_backup_${DATE}.dump"
    
    # SQL 格式备份 (用于数据恢复)
    pg_dump -h "${PG_HOST}" \
            -p "${PG_PORT}" \
            -U "${PG_USER}" \
            -d "${PG_DB}" \
            -f "${BACKUP_DIR}/postgres/full_backup_${DATE}.sql"
    
    # 压缩
    gzip "${BACKUP_DIR}/postgres/full_backup_${DATE}.sql"
    
    # 清理旧备份
    find "${BACKUP_DIR}/postgres" -name "full_backup_*.dump" -mtime +${KEEP_DAYS} -delete
    find "${BACKUP_DIR}/postgres" -name "full_backup_*.sql.gz" -mtime +${KEEP_DAYS} -delete
    
    log "PostgreSQL 备份完成: full_backup_${DATE}.dump"
}

# Elasticsearch 备份
backup_elasticsearch() {
    log "开始 Elasticsearch 备份..."
    
    # 创建快照仓库 (如果不存在)
    curl -X PUT "http://${ES_HOST}/_snapshot/10kbooks_backup" \
        -H "Content-Type: application/json" \
        -u "${ES_USER}:${ES_PASSWORD}" \
        -d '{
            "type": "fs",
            "settings": {
                "location": "/var/lib/elasticsearch/backups",
                "compress": true
            }
        }' 2>/dev/null || true
    
    # 创建快照
    SNAPSHOT_NAME="snapshot_${DATE}"
    curl -X PUT "http://${ES_HOST}/_snapshot/10kbooks_backup/${SNAPSHOT_NAME}?wait_for_completion=true" \
        -H "Content-Type: application/json" \
        -u "${ES_USER}:${ES_PASSWORD}" \
        -d "{
            \"indices\": \"${ES_INDEX}\",
            \"ignore_unavailable\": true,
            \"include_global_state\": false
        }"
    
    # 导出到本地
    mkdir -p "${BACKUP_DIR}/elasticsearch/${DATE}"
    
    for index in ${ES_INDEX//,/ }; do
        curl -X POST "http://${ES_HOST}/${index}/_search/scroll" \
            -H "Content-Type: application/json" \
            -u "${ES_USER}:${ES_PASSWORD}" \
            -d "{\"scroll\": \"5m\", \"scroll_id\": \"dummy\", \"size\": 10000}" > /dev/null 2>&1 || true
    done
    
    # 清理旧快照
    curl -X GET "http://${ES_HOST}/_snapshot/10kbooks_backup/_all" \
        -u "${ES_USER}:${ES_PASSWORD}" | \
        jq -r '.snapshots[] | select(.start_epoch | tonumber < '$(date -d "${KEEP_DAYS} days ago" +%s)')) | .snapshot' | \
        while read snapshot; do
            curl -X DELETE "http://${ES_HOST}/_snapshot/10kbooks_backup/${snapshot}" \
                -u "${ES_USER}:${ES_PASSWORD}"
        done || true
    
    log "Elasticsearch 备份完成: ${SNAPSHOT_NAME}"
}

# 上传备份到 S3
upload_to_s3() {
    log "上传备份到 S3..."
    
    # PostgreSQL 备份
    aws s3 sync "${BACKUP_DIR}/postgres" "${S3_BUCKET}/postgres/" \
        --region "${S3_REGION}" \
        --delete \
        --storage-class STANDARD_IA
    
    # Elasticsearch 备份
    aws s3 sync "${BACKUP_DIR}/elasticsearch" "${S3_BUCKET}/elasticsearch/" \
        --region "${S3_REGION}" \
        --delete \
        --storage-class STANDARD_IA
    
    log "S3 上传完成"
}

# 清理过期备份
cleanup_old_backups() {
    log "清理过期备份..."
    
    # 本地清理
    find "${BACKUP_DIR}" -type f -mtime +${KEEP_DAYS} -delete
    find "${BACKUP_DIR}" -type d -empty -delete
    
    log "清理完成"
}

# 发送备份通知
send_notification() {
    local status=$1
    local message=$2
    
    # 可以接入 Slack/钉钉/邮件通知
    log "通知: ${status} - ${message}"
}

# ==========================================
# 主流程
# ==========================================

main() {
    log "========== 开始备份任务 =========="
    
    setup_backup_dir
    
    # 执行备份
    if ! backup_postgres; then
        send_notification "FAILED" "PostgreSQL 备份失败"
        error_exit "PostgreSQL 备份失败"
    fi
    
    if ! backup_elasticsearch; then
        send_notification "WARNING" "Elasticsearch 备份失败"
    fi
    
    # 上传到云存储
    upload_to_s3
    
    # 清理旧文件
    cleanup_old_backups
    
    # 计算备份大小
    BACKUP_SIZE=$(du -sh "${BACKUP_DIR}" | cut -f1)
    
    log "========== 备份完成 =========="
    log "备份大小: ${BACKUP_SIZE}"
    log "备份位置: ${BACKUP_DIR}"
    
    send_notification "SUCCESS" "备份完成, 大小: ${BACKUP_SIZE}"
}

# 执行
main
