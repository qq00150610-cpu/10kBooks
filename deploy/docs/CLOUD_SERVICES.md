# ============================================
# 万卷书苑 / 10kBooks - 云服务配置指南
# AWS / 阿里云 / 云存储配置
# ============================================

## 目录

1. [AWS S3 配置](#aws-s3-配置)
2. [阿里云 OSS 配置](#阿里云-oss-配置)
3. [云数据库配置](#云数据库配置)
4. [CDN 加速配置](#cdn-加速配置)

---

## AWS S3 配置

### 创建 S3 存储桶

```bash
# 创建存储桶
aws s3 mb s3://10kbooks-production --region ap-east-1

# 启用版本控制
aws s3api put-bucket-versioning \
  --bucket 10kbooks-production \
  --versioning-configuration Status=Enabled

# 启用加密
aws s3api put-bucket-encryption \
  --bucket 10kbooks-production \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# 设置生命周期策略
aws s3api put-bucket-lifecycle-configuration \
  --bucket 10kbooks-production \
  --lifecycle-configuration '{
    "Rules": [
      {
        "ID": "archive-old-files",
        "Status": "Enabled",
        "Filter": {
          "Prefix": "uploads/"
        },
        "Transitions": [
          {
            "Days": 30,
            "StorageClass": "STANDARD_IA"
          },
          {
            "Days": 90,
            "StorageClass": "GLACIER"
          }
        ],
        "Expiration": {
          "Days": 365
        }
      }
    ]
  }'
```

### 配置存储桶策略

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::10kbooks-production/public/*"
    },
    {
      "Sid": "PrivateReadWrite",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/10kbooks-app"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::10kbooks-production/uploads/*"
    }
  ]
}
```

### IAM 策略配置

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::10kbooks-production",
        "arn:aws:s3:::10kbooks-production/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "arn:aws:s3:::10kbooks-production/uploads/*"
    }
  ]
}
```

---

## 阿里云 OSS 配置

### 创建 OSS 存储桶

```bash
# 使用阿里云 CLI
aliyun oss mb oss://10kbooks-production

# 设置存储类型为低频访问
aliyun oss set-bucket-storage-type --bucket 10kbooks-production --storage-type IA

# 设置防盗链
aliyun oss referer --bucket 10kbooks-production \
  --referer-domain-list "10kbooks.com,www.10kbooks.com,api.10kbooks.com" \
  --allow-empty-referer false

# 设置生命周期
aliyun oss lifecycle --bucket 10kbooks-production \
  --file "lifecycle.xml"
```

### lifecycle.xml

```xml
<LifecycleConfiguration>
  <Rule>
    <ID>archive-uploads</ID>
    <Prefix>uploads/</Prefix>
    <Status>Enabled</Status>
    <Transition>
      <Days>30</Days>
      <StorageClass>Archive</StorageClass>
    </Transition>
    <Expiration>
      <Days>365</Days>
    </Expiration>
  </Rule>
</LifecycleConfiguration>
```

### 应用配置示例

```typescript
// src/config/storage.ts
export const storageConfig = {
  // 阿里云 OSS
  oss: {
    endpoint: process.env.OSS_ENDPOINT || 'oss-cn-hongkong.aliyuncs.com',
    accessKeyId: process.env.OSS_ACCESS_KEY_ID,
    accessKeySecret: process.env.OSS_ACCESS_KEY_SECRET,
    bucket: process.env.OSS_BUCKET || '10kbooks-production',
    region: 'ap-east-1',
    
    // 上传配置
    upload: {
      maxSize: 100 * 1024 * 1024, // 100MB
      allowedMimeTypes: [
        'image/jpeg',
        'image/png',
        'image/gif',
        'application/pdf',
        'application/epub+zip',
        'application/x-mobipocket-ebook'
      ],
      expires: 3600 // 签名 URL 过期时间
    },
    
    // CDN 配置
    cdn: {
      domain: 'https://cdn.10kbooks.com',
      expires: 31536000 // CDN 缓存时间
    }
  },
  
  // AWS S3 (备用)
  s3: {
    region: process.env.AWS_REGION || 'ap-east-1',
    bucket: process.env.S3_BUCKET || '10kbooks-production',
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  }
};
```

---

## 云数据库配置

### RDS PostgreSQL 配置

```bash
# 创建 RDS 实例 (阿里云)
aliyun rds CreateDBInstance \
  --RegionId cn-hongkong \
  --Engine PostgreSQL \
  --EngineVersion 16 \
  --DBInstanceClass rdb.mysql.t3.small \
  --DBInstanceStorage 100 \
  --SecurityIPList 10.0.0.0/8,172.16.0.0/12 \
  --MasterUsername 10kbooks \
  --MasterPassword your_secure_password

# 设置备份策略
aliyun rds ModifyBackupPolicy \
  --DBInstanceId pg-xxxxxxxxxxxx \
  --PreferredBackupTime "03:00Z-04:00Z" \
  --PreferredBackupPeriod "Monday,Wednesday,Friday,Sunday" \
  --BackupRetentionPeriod 30

# 设置 SSL 连接
aliyun rds ModifyDBInstanceSSL \
  --DBInstanceId pg-xxxxxxxxxxxx \
  --SSLStatus Enable

# 设置只读实例
aliyun rds CreateReadOnlyDBInstance \
  --RegionId cn-hongkong \
  --EngineVersion 16 \
  --DBInstanceClass rdb.pg.t3.small \
  --DBInstanceStorage 100 \
  --SourceDBInstanceId pg-xxxxxxxxxxxx
```

### RDS 参数组配置

```bash
# 创建参数组
aliyun rds CreateParameterGroup \
  --RegionId cn-hongkong \
  --ParameterGroupType MySQL \
  --ParameterGroupName 10kbooks-optimized \
  --ParameterGroupDescription "Optimized for 10kBooks"

# 修改参数
aliyun rds ModifyParameterGroup \
  --ParameterGroupId pg-xxxxxxxxxxxx \
  --Parameters "[{\"ParameterName\":\"max_connections\",\"ParameterValue\":\"500\"}]"
```

### 连接池配置

```typescript
// src/config/database.ts
export const databaseConfig = {
  // 主库连接
  primary: {
    host: process.env.PRIMARY_DB_HOST,
    port: parseInt(process.env.PRIMARY_DB_PORT || '5432'),
    database: process.env.PRIMARY_DB_NAME || '10kbooks',
    username: process.env.PRIMARY_DB_USER,
    password: process.env.PRIMARY_DB_PASSWORD,
    ssl: { 
      rejectUnauthorized: true 
    },
    pool: {
      min: 5,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000
    }
  },
  
  // 只读库连接
  replica: {
    host: process.env.REPLICA_DB_HOST,
    port: parseInt(process.env.REPLICA_DB_PORT || '5432'),
    database: process.env.REPLICA_DB_NAME || '10kbooks',
    username: process.env.REPLICA_DB_USER,
    password: process.env.REPLICA_DB_PASSWORD,
    ssl: { 
      rejectUnauthorized: true 
    },
    pool: {
      min: 5,
      max: 20
    }
  }
};
```

---

## CDN 加速配置

### AWS CloudFront

```bash
# 创建分配
aws cloudfront create-distribution \
  --distribution-config file://cloudfront-config.json

# 缓存失效
aws cloudfront create-invalidation \
  --distribution-id EXXXXXXXX \
  --paths "/index.html" "/static/*"

# 查看分配状态
aws cloudfront get-distribution --id EXXXXXXXX
```

### 阿里云 CDN

```bash
# 添加域名
aliyun cdn AddDomain \
  --DomainName cdn.10kbooks.com \
  --CdnType web \
  --Sources '[{"Content":"api.10kbooks.com","Type":"domain","Priority":"high"}]'

# 配置缓存规则
aliyun cdn SetCacheConfig \
  --DomainName cdn.10kbooks.com \
  --CacheType cache \
  --Configs '[{
    "CacheContent": "*.jpg;*.png;*.gif",
    "TTL": 31536000,
    "Weight": 99
  }, {
    "CacheContent": "*.css;*.js",
    "TTL": 604800,
    "Weight": 99
  }]'

# 配置 HTTPS
aliyun cdn SetDomainServerCertificate \
  --DomainName cdn.10kbooks.com \
  --CertType upload \
  --SSLProtocol on
```

### 缓存策略

| 资源类型 | 缓存时间 | 原因 |
|----------|----------|------|
| 静态图片 | 1 年 | 带版本 hash |
| CSS/JS | 7 天 | 短期缓存 |
| HTML | 0 | 不缓存 |
| API 响应 | 60s | 短期缓存 |
| 用户数据 | 0 | 不缓存 |
| 书籍封面 | 30 天 | 中期缓存 |

---

## 环境变量配置

```bash
# .env.production

# ==========================================
# 云存储配置 (选择一种)
# ==========================================

# AWS S3
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_REGION=ap-east-1
S3_BUCKET=10kbooks-production

# 或阿里云 OSS
OSS_ENDPOINT=oss-cn-hongkong.aliyuncs.com
OSS_BUCKET=10kbooks-production
OSS_ACCESS_KEY_ID=LTAI5t7hXXXXXXXXXX
OSS_ACCESS_KEY_SECRET=your_secret_key

# ==========================================
# 云数据库配置
# ==========================================

# RDS PostgreSQL
PRIMARY_DB_HOST=pg.aliyuncs.com
PRIMARY_DB_PORT=5432
PRIMARY_DB_NAME=10kbooks
PRIMARY_DB_USER=10kbooks
PRIMARY_DB_PASSWORD=your_secure_password

# RDS 只读实例
REPLICA_DB_HOST=pg-ro.aliyuncs.com
REPLICA_DB_PORT=5432

# ==========================================
# CDN 配置
# ==========================================

CDN_DOMAIN=https://cdn.10kbooks.com
CDN_SECRET=your_cdn_auth_secret
```
