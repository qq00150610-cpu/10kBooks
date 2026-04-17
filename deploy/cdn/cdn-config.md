# ============================================
# 万卷书苑 / 10kBooks - CDN 配置指南
# AWS CloudFront / 阿里云 CDN
# ============================================

# ==========================================
# AWS CloudFront 配置
# ==========================================

# 1. 创建 CloudFront 分配

# 分发设置
{
  "CallerReference": "10kbooks-production",
  "Comment": "10kBooks Production CDN",
  "DefaultRootObject": "index.html",
  "Enabled": true,
  "Aliases": {
    "Quantity": 2,
    "Items": [
      "www.10kbooks.com",
      "10kbooks.com"
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "10kbooks-api-origin",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "CachedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "Compress": true,
    "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
    "SmoothStreaming": false,
    "MinTTL": 0,
    "MaxTTL": 31536000,
    "DefaultTTL": 86400
  },
  "CacheBehaviors": {
    "Quantity": 3,
    "Items": [
      {
        "PathPattern": "/api/*",
        "TargetOriginId": "10kbooks-api-origin",
        "ViewerProtocolPolicy": "https-only",
        "AllowedMethods": {
          "Quantity": 2,
          "Items": ["GET", "HEAD"]
        },
        "CachedMethods": {
          "Quantity": 2,
          "Items": ["GET", "HEAD"]
        },
        "Compress": false,
        "CachePolicyId": "0b67f16c-a2cd-11e6-989f-9f3d7e30f16d",
        "MinTTL": 0,
        "MaxTTL": 60,
        "DefaultTTL": 60
      },
      {
        "PathPattern": "/static/*",
        "TargetOriginId": "10kbooks-web-origin",
        "ViewerProtocolPolicy": "redirect-to-https",
        "Compress": true,
        "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
        "MinTTL": 31536000,
        "MaxTTL": 31536000,
        "DefaultTTL": 31536000
      },
      {
        "PathPattern": "/covers/*",
        "TargetOriginId": "10kbooks-cdn-origin",
        "ViewerProtocolPolicy": "redirect-to-https",
        "Compress": false,
        "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
        "MinTTL": 604800,
        "MaxTTL": 604800,
        "DefaultTTL": 604800
      }
    ]
  },
  "Origins": {
    "Quantity": 3,
    "Items": [
      {
        "Id": "10kbooks-web-origin",
        "DomainName": "10kbooks.com",
        "OriginPath": "",
        "CustomHeaders": {
          "Quantity": 0
        },
        "Protocol": "https",
        "OriginShield": "enabled",
        "OriginShieldRegion": "ap-east-1"
      },
      {
        "Id": "10kbooks-api-origin",
        "DomainName": "api.10kbooks.com",
        "OriginPath": "",
        "CustomHeaders": {
          "Quantity": 1,
          "Items": [
            {
              "HeaderName": "X-CDN-Secret",
              "HeaderValue": "your-cdn-secret-token"
            }
          ]
        },
        "Protocol": "https"
      },
      {
        "Id": "10kbooks-cdn-origin",
        "DomainName": "10kbooks-media.s3.amazonaws.com",
        "OriginPath": "",
        "Protocol": "https"
      }
    ]
  },
  "PriceClass": "PriceClass_All",
  "ViewerCertificate": {
    "ACMCertificateArn": "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021",
    "Certificate": "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx",
    "CertificateSource": "acm"
  },
  "HttpVersion": "http2and3",
  "IsIPV6Enabled": true
}

# ==========================================
# 缓存策略配置
# ==========================================

# 静态资源缓存策略
CachePolicy:
  Name: "10kBooks-StaticAssets"
  Comment: "缓存静态资源 1 年"
  MinTTL: 31536000
  MaxTTL: 31536000
  DefaultTTL: 86400
  
  ParametersInCacheKeyAndForwardedToOrigin:
    HeaderBehavior: whitelist
    Headers:
      - X-CDN-Secret
    
    CookieBehavior: none
    QueryStringBehavior: none
    
    EnableAcceptEncodingGzip: true
    EnableAcceptEncodingBrotli: true

# API 缓存策略
CachePolicy:
  Name: "10kBooks-API"
  Comment: "API 请求不缓存或短期缓存"
  MinTTL: 0
  MaxTTL: 60
  DefaultTTL: 60
  
  ParametersInCacheKeyAndForwardedToOrigin:
    HeaderBehavior: whitelist
    Headers:
      - Authorization
      - X-User-ID
    
    CookieBehavior: none
    QueryStringBehavior: include-all

# ==========================================
# 失效规则 (Invalidation)
# ==========================================

# 创建失效
aws cloudfront create-invalidation \
  --distribution-id EXXXXXXXX \
  --paths "/index.html" "/static/*"

# 失效规则
InvalidationBatch:
  CallerReference: "deploy-$(date +%s)"
  Paths:
    Quantity: 2
    Items:
      - "/index.html"
      - "/static/*"

# ==========================================
# 函数配置 (用于防盗链)
# ==========================================

# Origin Request Policy
ViewerRequestFunction:
  // 检查 Referer 头
  // 允许的来源
  const allowedDomains = [
    '10kbooks.com',
    'www.10kbooks.com',
    'api.10kbooks.com'
  ];
  
  if (event.request.headers.referer) {
    const referer = event.request.headers.referer.value;
    const isAllowed = allowedDomains.some(
      domain => referer.includes(domain)
    );
    
    if (!isAllowed && !referer.includes('cdn.10kbooks.com')) {
      return {
        statusCode: 403,
        statusDescription: 'Forbidden'
      };
    }
  }
  
  return event.request;

# ==========================================
# 阿里云 CDN 配置
# ==========================================

# CDN 域名添加
aliyun alidns AddDomain \
  --DomainName 10kbooks.com \
  --RecordType CNAME \
  --Value your-cdn-domain.alikunlun.com

# 缓存配置
aliyun cdn SetCacheConfig \
  --DomainName www.10kbooks.com \
  --CacheType cache \
  --Configs \
    '[{"CacheContent":"*.jpg;*.png;*.gif","TTL":31536000,"Weight":99},{"CacheContent":"*.html;*.htm","TTL":0,"Weight":99}]'

# 防盗链配置
aliyun cdn SetRefererConfig \
  --DomainName www.10kbooks.com \
  --ReferType block \
  --ReferList "10kbooks.com;www.10kbooks.com"

# HTTPS 配置
aliyun cdn SetDomainServerCertificate \
  --DomainName www.10kbooks.com \
  --CertType upload \
  --CertName 10kbooks-cert \
  --SSLProtocol on

# ==========================================
# 最佳实践
# ==========================================

# 1. 静态资源长期缓存
# - JS/CSS: 1 年 (带 hash 版本号)
# - 图片: 1 个月 - 1 年
# - HTML: 不缓存或短期

# 2. API 不缓存
# - GET /api/* 短期缓存 60s
# - POST/PUT/DELETE 不缓存

# 3. 防盗链
# - 检查 Referer
# - 使用签名 URL
# - IP 白名单

# 4. 性能优化
# - 启用 Brotli 压缩
# - 启用 HTTP/2 或 HTTP/3
# - 开启 TLS 1.3
# - 使用边缘计算
