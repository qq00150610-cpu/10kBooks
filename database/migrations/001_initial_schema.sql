-- ============================================
-- 万卷书苑 / 10kBooks 数据库架构
-- 版本: v1.0.0
-- 数据库: PostgreSQL 15
-- 描述: 多语言在线阅读与创作平台核心数据库设计
-- ============================================

-- 启用扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- 全文搜索支持

-- ============================================
-- 1. 用户系统
-- ============================================

-- 用户主表
CREATE TABLE users (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    uuid            VARCHAR(64)     UNIQUE NOT NULL,           -- 唯一标识(用于API)
    username        VARCHAR(50)     UNIQUE NOT NULL,           -- 用户名
    email           VARCHAR(255)    UNIQUE,
    phone           VARCHAR(20)     UNIQUE,
    password_hash   VARCHAR(255),                                -- 密码(可为空,第三方登录)
    
    -- 基本信息
    display_name    VARCHAR(100),                                -- 显示名称
    avatar_url      VARCHAR(500),
    bio             TEXT,                                        -- 个人简介
    gender          SMALLINT DEFAULT 0,                          -- 0未知 1男 2女
    birthday        DATE,
    locale          VARCHAR(10) DEFAULT 'zh-CN',                  -- 用户偏好语言
    timezone        VARCHAR(50) DEFAULT 'Asia/Shanghai',
    
    -- 第三方登录
    auth_provider   VARCHAR(20),                                 -- google, apple, facebook, wechat, phone
    auth_provider_id VARCHAR(255),                               -- 第三方用户ID
    
    -- 会员系统
    vip_level       SMALLINT DEFAULT 0,                          -- 0普通 1月度 2季度 3年度 4永久
    vip_expire_at   TIMESTAMPTZ,                                 -- VIP到期时间
    vip_auto_renew  BOOLEAN DEFAULT FALSE,                       -- 自动续费
    
    -- 账户状态
    status          SMALLINT DEFAULT 1,                           -- 1正常 2禁言 3封禁 4注销
    banned_until    TIMESTAMPTZ,                                 -- 禁言/封禁截止时间
    ban_reason      TEXT,
    
    -- 统计
    followers_count     BIGINT DEFAULT 0,
    following_count     BIGINT DEFAULT 0,
    books_count         BIGINT DEFAULT 0,                        -- 收藏/阅读的书籍数
    
    -- 安全
    email_verified      BOOLEAN DEFAULT FALSE,
    phone_verified      BOOLEAN DEFAULT FALSE,
    last_login_at       TIMESTAMPTZ,
    last_login_ip       INET,
    login_attempts      INTEGER DEFAULT 0,
    locked_until        TIMESTAMPTZ,
    
    -- 国际化
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- 用户设置表
CREATE TABLE user_settings (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 阅读偏好
    preferred_genres    TEXT[],                                -- 偏好的分类
    reading_theme       VARCHAR(20) DEFAULT 'light',           -- light, dark, sepia
    font_size           SMALLINT DEFAULT 16,
    font_family         VARCHAR(50) DEFAULT 'default',
    line_height         DECIMAL(3,2) DEFAULT 1.8,
    reading_mode        VARCHAR(20) DEFAULT 'scroll',           -- scroll, paginate
    auto_next_chapter   BOOLEAN DEFAULT TRUE,
    
    -- 通知设置
    notify_new_chapter  BOOLEAN DEFAULT TRUE,
    notify_comment      BOOLEAN DEFAULT TRUE,
    notify_like         BOOLEAN DEFAULT TRUE,
    notify_system       BOOLEAN DEFAULT TRUE,
    notify_email        BOOLEAN DEFAULT FALSE,
    notify_push         BOOLEAN DEFAULT TRUE,
    
    -- 隐私设置
    profile_public      BOOLEAN DEFAULT TRUE,
    reading_history_public BOOLEAN DEFAULT FALSE,
    following_list_public BOOLEAN DEFAULT FALSE,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- 用户积分/金币表
CREATE TABLE user_wallets (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID            UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 虚拟货币
    coins           BIGINT DEFAULT 0,                            -- 金币(消费用)
    points          BIGINT DEFAULT 0,                            -- 积分(等级/活动)
    
    -- 累计
    total_spent_coins   BIGINT DEFAULT 0,                       -- 累计消耗金币
    total_earned_coins  BIGINT DEFAULT 0,                       -- 累计获得金币
    total_recharged     BIGINT DEFAULT 0,                        -- 累计充值金额(分)
    
    version         INTEGER DEFAULT 0,                          -- 乐观锁版本号
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 积分变动记录表
CREATE TABLE wallet_transactions (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_no  VARCHAR(64)     UNIQUE NOT NULL,
    
    type            VARCHAR(20)     NOT NULL,                   -- recharge, purchase, reward, refund, signin, task, commission, withdraw
    category        VARCHAR(20)     NOT NULL,                   -- income, expense, refund
    
    amount          BIGINT          NOT NULL,                   -- 变动数量(正数增加,负数减少)
    balance_before  BIGINT          NOT NULL,                   -- 变动前余额
    balance_after   BIGINT          NOT NULL,                   -- 变动后余额
    
    -- 关联信息
    ref_type        VARCHAR(30),                                -- order, chapter, activity, task, withdrawal
    ref_id          UUID,
    
    description     TEXT,                                        -- 变动说明
    metadata        JSONB,                                       -- 扩展数据
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_users_locale ON users(locale);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_vip_level ON users(vip_level) WHERE vip_level > 0;
CREATE INDEX idx_users_auth ON users(auth_provider, auth_provider_id);
CREATE INDEX idx_users_created ON users(created_at DESC);

-- ============================================
-- 2. 作者系统
-- ============================================

-- 作者申请表
CREATE TABLE author_applications (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID            NOT NULL REFERENCES users(id),
    
    pen_name        VARCHAR(100)    NOT NULL,                   -- 笔名
    real_name       VARCHAR(100),                               -- 真名(实名认证用)
    id_card         VARCHAR(30),                                 -- 身份证号(加密存储)
    id_card_front   VARCHAR(500),                               -- 身份证正面
    id_card_back    VARCHAR(500),                               -- 身份证背面
    
    intro           TEXT,                                        -- 作者简介
    writing_experience TEXT,                                     -- 写作经历
    
    status          SMALLINT DEFAULT 1,                          -- 1待审核 2通过 3拒绝
    reviewer_id     UUID,
    reviewed_at     TIMESTAMPTZ,
    reject_reason   TEXT,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- 作者主表
CREATE TABLE authors (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID            UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    pen_name        VARCHAR(100)    NOT NULL,                   -- 笔名
    avatar_url      VARCHAR(500),
    bio             TEXT,                                        -- 作者简介
    
    -- 认证状态
    is_verified     BOOLEAN DEFAULT FALSE,                       -- 已认证作者
    verified_at     TIMESTAMPTZ,
    verification_badges TEXT[],                                  -- 认证徽章
    
    -- 等级
    author_level    SMALLINT DEFAULT 1,                          -- 1新人 2潜力 3人气 4大神 5白金
    level_updated_at TIMESTAMPTZ,
    
    -- 收益账户
    payment_info    JSONB,                                        -- 支付信息(支付宝/银行卡等,加密存储)
    default_payment_method VARCHAR(20),                          -- 默认支付方式
    
    -- 统计
    books_count         INTEGER DEFAULT 0,
    total_words         BIGINT DEFAULT 0,                        -- 累计字数
    total_views         BIGINT DEFAULT 0,                        -- 累计阅读量
    total_likes         BIGINT DEFAULT 0,                        -- 累计获赞
    subscribers_count   BIGINT DEFAULT 0,                        -- 关注人数
    total_earnings      BIGINT DEFAULT 0,                        -- 累计收益(分)
    withdrawable_amount BIGINT DEFAULT 0,                        -- 可提现金额(分)
    pending_amount      BIGINT DEFAULT 0,                         -- 待结金额(分)
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 作者收益结算记录
CREATE TABLE author_settlements (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id       UUID            NOT NULL REFERENCES authors(id),
    settlement_no   VARCHAR(64)     UNIQUE NOT NULL,
    
    period_start    DATE            NOT NULL,                   -- 结算周期开始
    period_end      DATE            NOT NULL,                   -- 结算周期结束
    
    -- 收益明细
    book_revenue    BIGINT DEFAULT 0,                            -- 订阅分成(分)
    chapter_revenue BIGINT DEFAULT 0,                            -- 章节付费(分)
    gift_revenue    BIGINT DEFAULT 0,                            -- 礼物打赏(分)
    bonus_revenue   BIGINT DEFAULT 0,                            -- 活动奖励(分)
    other_revenue   BIGINT DEFAULT 0,                            -- 其他收益(分)
    total_revenue   BIGINT DEFAULT 0,                            -- 总收益(分)
    
    platform_fee    BIGINT DEFAULT 0,                            -- 平台分成(分)
    tax_amount      BIGINT DEFAULT 0,                            -- 代扣税(分)
    net_amount      BIGINT DEFAULT 0,                            -- 实际结算(分)
    
    status          SMALLINT DEFAULT 1,                          -- 1待确认 2已确认 3已打款 4已到账
    paid_at         TIMESTAMPTZ,
    payment_method   VARCHAR(20),
    payment_txn      VARCHAR(100),
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    confirmed_at     TIMESTAMPTZ
);

-- 索引
CREATE INDEX idx_authors_user ON authors(user_id);
CREATE INDEX idx_authors_level ON authors(author_level);
CREATE INDEX idx_authors_earnings ON authors(total_earnings DESC);

-- ============================================
-- 3. 书籍系统
-- ============================================

-- 书籍分类表
CREATE TABLE categories (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    slug            VARCHAR(50)     UNIQUE NOT NULL,             -- 分类slug
    icon            VARCHAR(100),
    sort_order      INTEGER DEFAULT 0,
    is_active       BOOLEAN DEFAULT TRUE,
    
    -- 多语言名称
    name_i18n       JSONB NOT NULL,                               -- {"zh-CN": "玄幻", "en": "Fantasy", "ja": "ファンタジー"}
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 书籍标签表
CREATE TABLE tags (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    slug            VARCHAR(50)     UNIQUE NOT NULL,
    usage_count     INTEGER DEFAULT 0,                           -- 使用次数(用于热门标签)
    is_hot          BOOLEAN DEFAULT FALSE,
    is_official     BOOLEAN DEFAULT FALSE,                       -- 官方标签
    
    name_i18n       JSONB NOT NULL,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 书籍主表
CREATE TABLE books (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    book_uuid       VARCHAR(64)     UNIQUE NOT NULL,
    
    author_id       UUID            NOT NULL REFERENCES authors(id),
    
    -- 基础信息
    title           VARCHAR(200)    NOT NULL,                    -- 原语言标题
    title_i18n      JSONB,                                        -- 多语言翻译标题
    cover_url       VARCHAR(500),                                -- 封面图
    description     TEXT,                                        -- 简介
    description_i18n JSONB,                                      -- 多语言简介
    
    -- 分类与标签
    category_id     UUID            REFERENCES categories(id),
    tags            UUID[] DEFAULT '{}',                         -- 关联标签
    custom_tags     TEXT[],                                     -- 自定义标签
    
    -- 语言
    original_locale VARCHAR(10)     NOT NULL,                    -- 原始语言
    translation_status SMALLINT DEFAULT 0,                       -- 0仅原文 1部分翻译 2全部翻译
    
    -- 内容属性
    genre           VARCHAR(30),                                 -- 题材: fantasy, romance, sci-fi...
    maturity_rating SMALLINT DEFAULT 1,                          -- 1全年龄 2青少年 3成人
    word_count      INTEGER DEFAULT 0,                           -- 总字数
    chapter_count   INTEGER DEFAULT 0,                           -- 章节数
    
    -- 状态
    status          SMALLINT DEFAULT 1,                          -- 1创作中 2已完结 3连载 4停更
    is_paywalled    BOOLEAN DEFAULT FALSE,                       -- 是否付费
    is_free         BOOLEAN DEFAULT FALSE,                       -- 是否全本免费
    is_serialize    BOOLEAN DEFAULT TRUE,                        -- 是否连载中
    
    -- 可见性
    visibility      SMALLINT DEFAULT 1,                          -- 1公开 2隐藏 3私有
    is_featured     BOOLEAN DEFAULT FALSE,                       -- 主编推荐
    is_banner       BOOLEAN DEFAULT FALSE,                       -- 横幅推荐
    
    -- 统计数据(冗余优化)
    views_count     BIGINT DEFAULT 0,
    likes_count     BIGINT DEFAULT 0,
    followers_count BIGINT DEFAULT 0,
    subscribers_count BIGINT DEFAULT 0,                         -- 订阅人数(追更)
    comments_count  BIGINT DEFAULT 0,
    ratings_count   BIGINT DEFAULT 0,
    avg_rating      DECIMAL(3,2) DEFAULT 0,                       -- 平均评分
    
    -- SEO
    seo_title       VARCHAR(200),
    seo_description TEXT,
    
    -- 审核
    audit_status    SMALLINT DEFAULT 1,                          -- 1待审核 2通过 3拒绝
    audit_reason    TEXT,
    audited_at      TIMESTAMPTZ,
    auditor_id      UUID,
    
    published_at    TIMESTAMPTZ,                                 -- 发布时间
    first_published_at TIMESTAMPTZ,                              -- 首次发布时间
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- 书籍多语言版本表
CREATE TABLE book_translations (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    locale          VARCHAR(10)     NOT NULL,                    -- 语言代码
    
    title           VARCHAR(200),
    description     TEXT,
    
    seo_title       VARCHAR(200),
    seo_description TEXT,
    
    is_translated   BOOLEAN DEFAULT FALSE,
    translator_id   UUID,
    translated_at   TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(book_id, locale)
);

-- 书籍价格策略表
CREATE TABLE book_pricing (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    book_id         UUID            UNIQUE NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    
    -- 定价模式
    pricing_model   VARCHAR(20) DEFAULT 'freemium',              -- free, freemium, subscription, pay_per_chapter
    currency        VARCHAR(10) DEFAULT 'CNY',
    
    -- 订阅价格(分/千字/月)
    monthly_price   INTEGER DEFAULT 0,                            -- 月票价格
    yearly_price    INTEGER DEFAULT 0,                            -- 年票价格
    
    -- 全本价格
    full_book_price INTEGER DEFAULT 0,                            -- 全本购买(分)
    
    -- 首章免费
    first_chapter_free BOOLEAN DEFAULT TRUE,
    free_chapters  INTEGER DEFAULT 1,                             -- 免费章节数
    
    -- 折扣
    discount_enabled BOOLEAN DEFAULT FALSE,
    discount_start  TIMESTAMPTZ,
    discount_end    TIMESTAMPTZ,
    discount_price  INTEGER,
    
    -- 订阅分成比例
    subscription_share_author DECIMAL(5,2) DEFAULT 50.00,         -- 作者分成%
    subscription_share_platform DECIMAL(5,2) DEFAULT 50.00,      -- 平台分成%
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 书籍章节表
CREATE TABLE chapters (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    chapter_uuid    VARCHAR(64)     UNIQUE NOT NULL,
    
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    
    -- 章节信息
    chapter_number  INTEGER         NOT NULL,                     -- 章节号
    volume_id       UUID,                                         -- 卷ID(可选)
    title           VARCHAR(200),                                -- 章节标题
    title_i18n      JSONB,                                        -- 多语言标题
    
    -- 内容
    content         TEXT,                                         -- 章节内容(正文)
    content_length  INTEGER DEFAULT 0,                            -- 正文字数
    
    -- 状态
    status          SMALLINT DEFAULT 1,                            -- 1草稿 2待审核 3已发布 4已锁定
    is_paywalled    BOOLEAN DEFAULT FALSE,                         -- 是否付费
    is_vip_chapter  BOOLEAN DEFAULT FALSE,                         -- VIP专属
    is_extra_chapter BOOLEAN DEFAULT FALSE,                        -- 额外章节(番外)
    
    -- 统计
    word_count      INTEGER DEFAULT 0,                            -- 章节字数
    views_count     BIGINT DEFAULT 0,
    likes_count     BIGINT DEFAULT 0,
    comments_count  BIGINT DEFAULT 0,
    
    -- 审核
    audit_status    SMALLINT DEFAULT 1,
    audit_reason    TEXT,
    audited_at      TIMESTAMPTZ,
    auditor_id      UUID,
    
    -- 定时发布
    scheduled_publish_at TIMESTAMPTZ,                             -- 定时发布
    
    published_at    TIMESTAMPTZ,                                 -- 发布时间
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- 章节多语言内容表
CREATE TABLE chapter_translations (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    chapter_id      UUID            NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    locale          VARCHAR(10)     NOT NULL,
    
    title           VARCHAR(200),
    content         TEXT,
    
    is_translated   BOOLEAN DEFAULT FALSE,
    translator_id   UUID,
    translated_at   TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(chapter_id, locale)
);

-- 书籍收藏/书架
CREATE TABLE bookshelves (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    
    -- 状态
    status          SMALLINT DEFAULT 1,                          -- 1在读 2想读 3已读 4弃坑
    reading_progress DECIMAL(5,2) DEFAULT 0,                     -- 阅读进度%
    current_chapter_id UUID,                                    -- 当前阅读章节
    
    -- 书架分组
    shelf_id        UUID,                                         -- 书架ID
    shelf_name      VARCHAR(50),                                  -- 自定义书架名
    
    -- 用户评分
    user_rating     DECIMAL(2,1),                                 -- 用户评分1-5
    
    -- 提醒
    notify_new_chapter BOOLEAN DEFAULT TRUE,                     -- 追更通知
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, book_id)
);

-- 阅读进度表
CREATE TABLE reading_progress (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    chapter_id      UUID            NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    
    progress        DECIMAL(5,2) DEFAULT 0,                      -- 章节内进度%
    scroll_position INTEGER DEFAULT 0,                            -- 滚动位置
    reading_time    INTEGER DEFAULT 0,                           -- 本次阅读时长(秒)
    
    -- 阅读时间统计
    last_read_at    TIMESTAMPTZ DEFAULT NOW(),
    read_days       INTEGER DEFAULT 1,                            -- 连续阅读天数
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, chapter_id)
);

-- 书签表
CREATE TABLE bookmarks (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    chapter_id      UUID            NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    
    position        INTEGER         NOT NULL,                    -- 书签位置
    note            TEXT,                                        -- 书签备注
    color           VARCHAR(20),                                  -- 书签颜色
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 阅读笔记表
CREATE TABLE reading_notes (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    chapter_id      UUID            NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    
    content         TEXT            NOT NULL,                    -- 笔记内容
    excerpt         TEXT,                                        -- 引用原文
    start_position  INTEGER,
    end_position    INTEGER,
    
    -- 互动
    likes_count     INTEGER DEFAULT 0,
    is_public       BOOLEAN DEFAULT TRUE,                        -- 是否公开
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_books_author ON books(author_id);
CREATE INDEX idx_books_category ON books(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_status ON books(status, deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_locale ON books(original_locale);
CREATE INDEX idx_books_published ON books(published_at DESC) WHERE deleted_at IS NULL AND status = 3;
CREATE INDEX idx_books_rating ON books(avg_rating DESC, ratings_count DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_views ON books(views_count DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_likes ON books(likes_count DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_books_search ON books USING gin(title gin_trgm_ops);
CREATE INDEX idx_chapters_book ON chapters(book_id, chapter_number);
CREATE INDEX idx_chapters_published ON chapters(book_id, published_at DESC) WHERE status = 3;
CREATE INDEX idx_bookshelves_user ON bookshelves(user_id, status);
CREATE INDEX idx_reading_progress_user ON reading_progress(user_id, last_read_at DESC);

-- ============================================
-- 4. 社交系统
-- ============================================

-- 用户关注表
CREATE TABLE user_follows (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    follower_id     UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id    UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- 书籍动态表
CREATE TABLE book_activities (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    chapter_id      UUID,                                         -- 可选
    
    activity_type   VARCHAR(30)     NOT NULL,                     -- started_reading, finished_reading, 
                                                                -- reviewing, new_chapter, new_book,
                                                                -- recommendation, quote, discussion
    
    content         TEXT,                                         -- 动态内容
    images          TEXT[],                                        -- 图片
    locale          VARCHAR(10) DEFAULT 'zh-CN',                  -- 动态语言
    
    likes_count     INTEGER DEFAULT 0,
    comments_count  INTEGER DEFAULT 0,
    shares_count    INTEGER DEFAULT 0,
    
    is_pinned       BOOLEAN DEFAULT FALSE,
    is_featured     BOOLEAN DEFAULT FALSE,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 动态评论表
CREATE TABLE comments (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 评论对象
    target_type     VARCHAR(20)     NOT NULL,                     -- book, chapter, activity, note
    target_id       UUID            NOT NULL,
    
    -- 内容
    content         TEXT            NOT NULL,
    content_i18n    JSONB,                                        -- 多语言翻译
    locale          VARCHAR(10) DEFAULT 'zh-CN',
    
    -- 楼层
    parent_id       UUID,                                         -- 父评论ID(回复)
    root_id         UUID,                                         -- 根评论ID
    floor_number    INTEGER,                                      -- 楼层号
    
    likes_count     INTEGER DEFAULT 0,
    
    -- 状态
    status          SMALLINT DEFAULT 1,                            -- 1正常 2待审核 3已删除 4折叠
    audit_reason    TEXT,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- 评分表
CREATE TABLE ratings (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    
    rating          DECIMAL(2,1)    NOT NULL CHECK (rating >= 1 AND rating <= 5),
    content         TEXT,                                         -- 评语
    content_i18n    JSONB,
    locale          VARCHAR(10) DEFAULT 'zh-CN',
    
    likes_count     INTEGER DEFAULT 0,
    
    is_verified_purchase BOOLEAN DEFAULT FALSE,                   -- 是否已购买
    is_featured     BOOLEAN DEFAULT FALSE,                        -- 是否精选
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, book_id)
);

-- 点赞表
CREATE TABLE likes (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 点赞对象
    target_type     VARCHAR(20)     NOT NULL,                     -- book, chapter, activity, comment, note
    target_id       UUID            NOT NULL,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, target_type, target_id)
);

-- 举报表
CREATE TABLE reports (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_uuid     VARCHAR(64)     UNIQUE NOT NULL,
    
    reporter_id     UUID            NOT NULL REFERENCES users(id),
    
    target_type     VARCHAR(30)     NOT NULL,                     -- user, book, chapter, comment, activity
    target_id       UUID            NOT NULL,
    
    reason          VARCHAR(30)     NOT NULL,                     -- spam, harassment, plagiarism, copyright, other
    description     TEXT,
    evidence        TEXT[],                                        -- 证据截图等
    
    status          SMALLINT DEFAULT 1,                            -- 1待处理 2已处理 3已驳回
    handler_id      UUID,
    handled_at      TIMESTAMPTZ,
    result          TEXT,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_follows_follower ON user_follows(follower_id);
CREATE INDEX idx_follows_following ON user_follows(following_id);
CREATE INDEX idx_activities_user ON book_activities(user_id, created_at DESC);
CREATE INDEX idx_activities_book ON book_activities(book_id, created_at DESC);
CREATE INDEX idx_activities_type ON book_activities(activity_type, created_at DESC);
CREATE INDEX idx_comments_target ON comments(target_type, target_id, created_at DESC);
CREATE INDEX idx_comments_user ON comments(user_id, created_at DESC);
CREATE INDEX idx_ratings_book ON ratings(book_id, created_at DESC);
CREATE INDEX idx_likes_target ON likes(target_type, target_id);

-- ============================================
-- 5. 订单/支付系统
-- ============================================

-- 支付订单表
CREATE TABLE orders (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_no        VARCHAR(64)     UNIQUE NOT NULL,
    
    user_id         UUID            NOT NULL REFERENCES users(id),
    
    -- 订单类型
    order_type      VARCHAR(20)     NOT NULL,                     -- recharge, purchase, vip, gift
    
    -- 金额
    currency        VARCHAR(10) DEFAULT 'CNY',
    total_amount    INTEGER         NOT NULL,                     -- 订单总额(分)
    paid_amount     INTEGER DEFAULT 0,                            -- 实付金额(分)
    
    -- 关联
    ref_type        VARCHAR(30),                                   -- book, chapter, vip, package
    ref_id          UUID,
    
    -- 支付信息
    payment_method  VARCHAR(30),                                   -- alipay, wechat, apple_iap, google_billing
    payment_status  VARCHAR(20) DEFAULT 'pending',                -- pending, paid, failed, refunded, cancelled
    paid_at         TIMESTAMPTZ,
    payment_txn_id  VARCHAR(100),                                 -- 第三方交易号
    
    -- 折扣
    discount_code   VARCHAR(50),
    discount_amount INTEGER DEFAULT 0,
    
    -- 附加数据
    metadata        JSONB,
    
    -- 退款
    refund_status   VARCHAR(20) DEFAULT 'none',                   -- none, requested, approved, rejected, completed
    refund_amount   INTEGER DEFAULT 0,
    refund_reason   TEXT,
    refund_at       TIMESTAMPTZ,
    
    expire_at       TIMESTAMPTZ,                                  -- 订单过期时间
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 消费记录表(章节购买)
CREATE TABLE purchases (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_uuid   VARCHAR(64)     UNIQUE NOT NULL,
    
    user_id         UUID            NOT NULL REFERENCES users(id),
    book_id         UUID            NOT NULL REFERENCES books(id),
    chapter_id      UUID,                                         -- 全本购买时为空
    
    order_id        UUID            REFERENCES orders(id),
    
    -- 价格
    price           INTEGER         NOT NULL,                     -- 购买时价格(分)
    currency        VARCHAR(10) DEFAULT 'CNY',
    
    -- 购买类型
    purchase_type   VARCHAR(20)     NOT NULL,                     -- chapter, book, subscription
    
    -- 作者分成计算
    author_id       UUID            NOT NULL,
    author_share    DECIMAL(5,2),                                  -- 作者分成比例
    commission_amount INTEGER,                                    -- 作者佣金(分)
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- VIP会员表
CREATE TABLE vip_subscriptions (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    sub_uuid        VARCHAR(64)     UNIQUE NOT NULL,
    
    user_id         UUID            NOT NULL REFERENCES users(id),
    
    -- 订阅信息
    vip_level       SMALLINT        NOT NULL,                    -- 1月度 2季度 3年度 4永久
    level_name      VARCHAR(50),
    
    -- 费用
    currency        VARCHAR(10) DEFAULT 'CNY',
    price           INTEGER         NOT NULL,                     -- 购买价格(分)
    
    -- 时间
    start_at        TIMESTAMPTZ     NOT NULL,
    expire_at       TIMESTAMPTZ     NOT NULL,
    
    -- 自动续费
    auto_renew      BOOLEAN DEFAULT TRUE,
    renew_count     INTEGER DEFAULT 0,                            -- 自动续费次数
    
    -- 来源
    source          VARCHAR(20) DEFAULT 'direct',                -- direct, gift, promotion, trial
    order_id        UUID            REFERENCES orders(id),
    gift_from_user  UUID,
    
    -- 状态
    status          VARCHAR(20) DEFAULT 'active',                -- active, expired, cancelled, pending
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 充值套餐表
CREATE TABLE recharge_packages (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    name            VARCHAR(100)    NOT NULL,
    coins           BIGINT          NOT NULL,                     -- 赠送金币数
    bonus_coins     BIGINT DEFAULT 0,                             -- 额外赠送
    
    currency        VARCHAR(10) DEFAULT 'CNY',
    price           INTEGER         NOT NULL,                     -- 价格(分)
    
    is_active       BOOLEAN DEFAULT TRUE,
    is_featured     BOOLEAN DEFAULT FALSE,                        -- 推荐套餐
    sort_order      INTEGER DEFAULT 0,
    
    -- 多语言
    name_i18n       JSONB,
    
    -- 限制
    daily_limit     INTEGER,                                      -- 每日限购
    total_limit     INTEGER,                                      -- 总限售
    
    start_at        TIMESTAMPTZ,
    end_at          TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 提现申请表
CREATE TABLE withdrawals (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    withdraw_no     VARCHAR(64)     UNIQUE NOT NULL,
    
    author_id       UUID            NOT NULL REFERENCES authors(id),
    user_id         UUID            NOT NULL REFERENCES users(id),
    
    -- 金额
    amount          INTEGER         NOT NULL,                     -- 提现金额(分)
    currency        VARCHAR(10) DEFAULT 'CNY',
    fee             INTEGER DEFAULT 0,                            -- 手续费(分)
    actual_amount   INTEGER         NOT NULL,                     -- 实到金额(分)
    
    -- 方式
    method          VARCHAR(20)     NOT NULL,                     -- alipay, bank, paypal
    account_info    TEXT,                                         -- 账户信息(加密)
    account_name    VARCHAR(100),                                  -- 账户名
    
    -- 状态
    status          SMALLINT DEFAULT 1,                            -- 1待审核 2待打款 3已打款 4已拒绝 5已取消
    reviewer_id     UUID,
    reviewed_at     TIMESTAMPTZ,
    reject_reason   TEXT,
    
    paid_at         TIMESTAMPTZ,
    payment_txn     VARCHAR(100),                                  -- 支付流水
    
    remark          TEXT,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 邀请奖励表
CREATE TABLE invitations (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    inviter_id      UUID            NOT NULL REFERENCES users(id),  -- 邀请人
    invitee_id      UUID            NOT NULL REFERENCES users(id),  -- 被邀请人
    
    -- 奖励
    inviter_reward  INTEGER DEFAULT 0,                              -- 邀请人奖励金币
    invitee_reward  INTEGER DEFAULT 0,                              -- 被邀请人奖励金币
    
    -- 状态
    status          VARCHAR(20) DEFAULT 'pending',                 -- pending, completed, expired
    completed_at    TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_orders_user ON orders(user_id, created_at DESC);
CREATE INDEX idx_orders_status ON orders(payment_status, created_at);
CREATE INDEX idx_purchases_user ON purchases(user_id, created_at DESC);
CREATE INDEX idx_purchases_book ON purchases(book_id);
CREATE INDEX idx_vip_subs_user ON vip_subscriptions(user_id, status, expire_at);
CREATE INDEX idx_withdrawals_author ON withdrawals(author_id, created_at DESC);
CREATE INDEX idx_withdrawals_status ON withdrawals(status, created_at);
CREATE INDEX idx_invitations_inviter ON invitations(inviter_id);
CREATE INDEX idx_invitations_invitee ON invitations(invitee_id);

-- ============================================
-- 6. 通知系统
-- ============================================

-- 通知模板表
CREATE TABLE notification_templates (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    template_code   VARCHAR(50)     UNIQUE NOT NULL,              -- 模板代码
    template_type   VARCHAR(20)     NOT NULL,                     -- system, activity, interaction, transaction
    
    -- 多语言内容
    title_i18n      JSONB NOT NULL,
    content_i18n    JSONB NOT NULL,
    
    -- 变量
    variables       TEXT[],                                        -- 可用变量列表
    
    is_active       BOOLEAN DEFAULT TRUE,
    priority        SMALLINT DEFAULT 5,                            -- 1最高 5普通
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 通知表
CREATE TABLE notifications (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_uuid VARCHAR(64)   UNIQUE NOT NULL,
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 类型
    type            VARCHAR(30)     NOT NULL,                     -- system, new_chapter, comment, like, 
                                                                -- follow, review, vip, promotion, earnings
    
    -- 内容
    title           VARCHAR(200),
    content         TEXT            NOT NULL,
    
    -- 跳转
    action_type     VARCHAR(30),                                   -- book, chapter, activity, user, url, none
    action_id       UUID,
    action_url      VARCHAR(500),
    
    -- 状态
    is_read         BOOLEAN DEFAULT FALSE,
    read_at         TIMESTAMPTZ,
    
    -- 渠道
    channel         VARCHAR(20) DEFAULT 'app',                     -- app, email, sms, push
    is_sent         BOOLEAN DEFAULT FALSE,
    sent_at         TIMESTAMPTZ,
    
    -- 聚合
    aggregation_key VARCHAR(100),                                  -- 相同key的通知聚合
    aggregation_count INTEGER DEFAULT 1,
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 推送设备表
CREATE TABLE push_devices (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_token    VARCHAR(255)    NOT NULL,
    device_type     VARCHAR(20)     NOT NULL,                     -- ios, android, web
    
    -- 状态
    is_active       BOOLEAN DEFAULT TRUE,
    last_push_at    TIMESTAMPTZ,
    last_seen_at    TIMESTAMPTZ DEFAULT NOW(),
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, device_token, device_type)
);

-- 索引
CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_push_devices_user ON push_devices(user_id);
CREATE INDEX idx_push_devices_token ON push_devices(device_token);

-- ============================================
-- 7. 审核系统
-- ============================================

-- 审核任务表
CREATE TABLE audit_tasks (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_no         VARCHAR(64)     UNIQUE NOT NULL,
    
    -- 待审核对象
    target_type     VARCHAR(30)     NOT NULL,                     -- book, chapter, user_content, author_application
    target_id       UUID            NOT NULL,
    
    -- 内容摘要(冗余便于审核)
    content_summary TEXT,
    content_preview TEXT,                                         -- 预览片段
    
    -- 审核类型
    audit_type      VARCHAR(20)     NOT NULL,                     -- create, update, delete, report
    priority        SMALLINT DEFAULT 5,                            -- 1紧急 5普通
    
    -- 审核流程
    status          SMALLINT DEFAULT 1,                            -- 1待审核 2审核中 3通过 4拒绝 5需复核
    audit_level     SMALLINT DEFAULT 1,                            -- 1机审 2人工 3复审
    
    -- AI审核
    ai_result       JSONB,                                         -- AI审核结果
    ai_confidence   DECIMAL(5,4),                                  -- AI置信度
    
    -- 人工审核
    auditor_id      UUID,
    audited_at      TIMESTAMPTZ,
    audit_duration  INTEGER,                                       -- 审核耗时(秒)
    audit_remarks   TEXT,
    
    -- 敏感词检测
    sensitive_words JSONB,                                          -- 检测到的敏感词
    
    -- 关联举报
    report_id       UUID REFERENCES reports(id),
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 敏感词表
CREATE TABLE sensitive_words (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    word            VARCHAR(100)    NOT NULL,
    word_type       VARCHAR(20)     NOT NULL,                     -- political, porn, violence, ads, custom
    
    level           SMALLINT DEFAULT 1,                            -- 1警告 2屏蔽 3封号
    
    -- 多语言
    locale          VARCHAR(10) DEFAULT 'all',                    -- 适用语言, all表示全部
    
    is_active       BOOLEAN DEFAULT TRUE,
    created_by      UUID,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 审核日志表
CREATE TABLE audit_logs (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    task_id         UUID            REFERENCES audit_tasks(id),
    auditor_id      UUID,                                          -- 操作人
    
    action          VARCHAR(20)     NOT NULL,                     -- submit, assign, approve, reject, appeal
    before_status   SMALLINT,
    after_status    SMALLINT,
    
    content         TEXT,
    reason          TEXT,
    
    metadata        JSONB,
    
    ip_address      INET,
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_audit_tasks_target ON audit_tasks(target_type, target_id);
CREATE INDEX idx_audit_tasks_status ON audit_tasks(status, created_at) WHERE status IN (1, 2);
CREATE INDEX idx_audit_tasks_priority ON audit_tasks(priority, created_at);
CREATE INDEX idx_sensitive_words_active ON sensitive_words(word_type, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_audit_logs_task ON audit_logs(task_id);

-- ============================================
-- 8. AI系统
-- ============================================

-- AI模型配置表
CREATE TABLE ai_models (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    model_key       VARCHAR(50)     UNIQUE NOT NULL,              -- gpt-4, claude-3, gemini-pro
    provider        VARCHAR(30)     NOT NULL,                     -- openai, anthropic, google
    
    name            VARCHAR(100)    NOT NULL,
    description     TEXT,
    
    -- 能力
    capabilities    TEXT[],                                        -- translation, summary, generate, qa
    supported_locales TEXT[],                                      -- 支持的语言
    
    -- 费用
    input_price_per_1k_tokens INTEGER,                             -- 输入价格(分/1K token)
    output_price_per_1k_tokens INTEGER,
    
    -- 限制
    max_tokens      INTEGER,
    rate_limit_per_minute INTEGER,
    
    is_active       BOOLEAN DEFAULT TRUE,
    is_default      BOOLEAN DEFAULT FALSE,
    
    config          JSONB,                                         -- 模型特定配置
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- AI使用记录表
CREATE TABLE ai_usage_logs (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    log_uuid        VARCHAR(64)     UNIQUE NOT NULL,
    
    user_id         UUID            NOT NULL REFERENCES users(id),
    
    -- 任务信息
    task_type       VARCHAR(30)     NOT NULL,                     -- translation, summary, generate, recommendation
    target_type     VARCHAR(20),                                   -- book, chapter, activity
    target_id       UUID,
    
    -- 模型信息
    model_id        UUID            REFERENCES ai_models(id),
    model_key       VARCHAR(50),
    
    -- 请求信息
    prompt_tokens   INTEGER DEFAULT 0,
    completion_tokens INTEGER DEFAULT 0,
    total_tokens    INTEGER DEFAULT 0,
    
    -- 费用
    cost            INTEGER DEFAULT 0,                            -- 消耗金币/积分
    
    -- 请求数据
    request_data    JSONB,                                         -- 输入摘要
    response_data   JSONB,                                         -- 输出摘要
    
    -- 性能
    latency_ms      INTEGER,                                       -- 响应延迟
    error_message   TEXT,
    
    -- 质量评估
    quality_score   DECIMAL(3,2),                                  -- 质量评分
    user_feedback   SMALLINT,                                      -- 用户反馈: 1-5
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- AI生成任务表
CREATE TABLE ai_tasks (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_uuid       VARCHAR(64)     UNIQUE NOT NULL,
    
    user_id         UUID            NOT NULL REFERENCES users(id),
    
    task_type       VARCHAR(30)     NOT NULL,                     -- translation, generate_chapter, generate_cover
    
    -- 关联对象
    book_id         UUID,
    chapter_id      UUID,
    
    -- 任务参数
    params          JSONB           NOT NULL,                     -- 任务参数
    locale          VARCHAR(10),                                   -- 目标语言
    
    -- 状态
    status          VARCHAR(20) DEFAULT 'pending',                -- pending, processing, completed, failed
    progress        SMALLINT DEFAULT 0,                            -- 进度 0-100
    
    -- 结果
    result          JSONB,
    error_message   TEXT,
    
    -- 配额检查
    quota_type      VARCHAR(20),                                   -- free, paid
    quota_used      INTEGER DEFAULT 0,
    
    started_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_ai_usage_user ON ai_usage_logs(user_id, created_at DESC);
CREATE INDEX idx_ai_usage_task_type ON ai_usage_logs(task_type, created_at DESC);
CREATE INDEX idx_ai_usage_target ON ai_usage_logs(target_type, target_id) WHERE target_id IS NOT NULL;
CREATE INDEX idx_ai_tasks_user ON ai_tasks(user_id, created_at DESC);
CREATE INDEX idx_ai_tasks_status ON ai_tasks(status, created_at);

-- ============================================
-- 9. 系统配置与日志
-- ============================================

-- 系统配置表
CREATE TABLE system_configs (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    config_key      VARCHAR(100)    UNIQUE NOT NULL,
    config_value    JSONB           NOT NULL,
    
    config_type     VARCHAR(20)     NOT NULL,                     -- feature, limit, payment, content, seo
    description     TEXT,
    
    is_public       BOOLEAN DEFAULT FALSE,                       -- 是否对用户公开
    editable        BOOLEAN DEFAULT TRUE,                        -- 是否可编辑
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 操作日志表
CREATE TABLE operation_logs (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID,
    admin_id        UUID,
    
    action          VARCHAR(50)     NOT NULL,                     -- login, logout, create, update, delete
    target_type     VARCHAR(30),
    target_id       UUID,
    
    before_data     JSONB,
    after_data      JSONB,
    
    ip_address      INET,
    user_agent      TEXT,
    
    status          VARCHAR(20) DEFAULT 'success',                -- success, failed
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 用户会话表
CREATE TABLE user_sessions (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token   VARCHAR(255)    UNIQUE NOT NULL,
    
    device_type     VARCHAR(20),
    device_id       VARCHAR(100),
    ip_address      INET,
    user_agent      TEXT,
    
    last_active_at  TIMESTAMPTZ DEFAULT NOW(),
    expire_at       TIMESTAMPTZ,
    
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 书籍推荐记录表(机器学习特征)
CREATE TABLE book_recommendations (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id         UUID            NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    
    -- 推荐类型
    rec_type        VARCHAR(30)     NOT NULL,                     -- personalized, similar, popular, new, category
    rec_source      VARCHAR(30),                                   -- als, item_cf, content, rule
    
    -- 分数
    score           DECIMAL(10,6) DEFAULT 0,                      -- 推荐分数
    
    -- 曝光与转化
    exposed_at      TIMESTAMPTZ,                                  -- 曝光时间
    clicked_at      TIMESTAMPTZ,                                  -- 点击时间
    read_at         TIMESTAMPTZ,                                   -- 开始阅读时间
    converted_at    TIMESTAMPTZ,                                  -- 转化时间(付费/收藏)
    
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, book_id, rec_type)
);

-- 索引
CREATE INDEX idx_operation_logs_user ON operation_logs(user_id, created_at DESC);
CREATE INDEX idx_operation_logs_target ON operation_logs(target_type, target_id);
CREATE INDEX idx_sessions_user ON user_sessions(user_id, expire_at);
CREATE INDEX idx_sessions_token ON user_sessions(session_token) WHERE expire_at > NOW();
CREATE INDEX idx_recommendations_user ON book_recommendations(user_id, rec_type, score DESC);

-- ============================================
-- 10. Redis缓存数据结构设计(参考)
-- ============================================
-- 以下为Redis缓存设计说明,实际建表后通过应用层管理Redis

-- 用户Session: user:session:{token} -> JSON(user_data)
-- 用户Token: user:token:{user_id} -> token
-- 用户积分: user:wallet:{user_id} -> JSON({coins, points})
-- 书籍评分缓存: book:rating:{book_id} -> {avg, count}
-- 热门书籍: book:hot:{locale}:{period} -> ZSET(book_ids)
-- 阅读进度: user:reading:{user_id}:{book_id} -> JSON({chapter, progress})
-- 限流: rate:limit:{user_id}:{action} -> count with TTL
-- 分布式锁: lock:{resource}:{id} -> token with TTL
-- 队列: queue:ai_task -> LIST
-- 订阅: channel:user:{user_id} -> PUBLISH

-- ============================================
-- 11. 触发器和函数
-- ============================================

-- 更新时间戳函数
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为主要表创建更新时间戳触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_books_updated_at BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_chapters_updated_at BEFORE UPDATE ON chapters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 自动更新书籍章节数字数统计
CREATE OR REPLACE FUNCTION update_book_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE books SET 
            chapter_count = chapter_count + 1,
            word_count = word_count + COALESCE(NEW.word_count, 0)
        WHERE id = NEW.book_id;
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE books SET 
            word_count = word_count - COALESCE(OLD.word_count, 0) + COALESCE(NEW.word_count, 0)
        WHERE id = NEW.book_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE books SET 
            chapter_count = chapter_count - 1,
            word_count = word_count - COALESCE(OLD.word_count, 0)
        WHERE id = OLD.book_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chapter_stats_trigger
AFTER INSERT OR UPDATE OR DELETE ON chapters
FOR EACH ROW EXECUTE FUNCTION update_book_stats();

-- 自动更新用户粉丝数
CREATE OR REPLACE FUNCTION update_follower_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
        UPDATE users SET following_count = following_count + 1 WHERE id = NEW.follower_id;
        UPDATE authors SET subscribers_count = subscribers_count + 1 WHERE user_id = NEW.following_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET followers_count = GREATEST(0, followers_count - 1) WHERE id = OLD.following_id;
        UPDATE users SET following_count = GREATEST(0, following_count - 1) WHERE id = OLD.follower_id;
        UPDATE authors SET subscribers_count = GREATEST(0, subscribers_count - 1) WHERE user_id = OLD.following_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER follow_counts_trigger
AFTER INSERT OR DELETE ON user_follows
FOR EACH ROW EXECUTE FUNCTION update_follower_counts();

-- 自动更新书籍点赞/评分
CREATE OR REPLACE FUNCTION update_book_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE books SET 
            avg_rating = (SELECT COALESCE(AVG(rating), 0) FROM ratings WHERE book_id = NEW.book_id),
            ratings_count = (SELECT COUNT(*) FROM ratings WHERE book_id = NEW.book_id)
        WHERE id = NEW.book_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE books SET 
            avg_rating = (SELECT COALESCE(AVG(rating), 0) FROM ratings WHERE book_id = OLD.book_id),
            ratings_count = (SELECT COUNT(*) FROM ratings WHERE book_id = OLD.book_id)
        WHERE id = OLD.book_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rating_update_trigger
AFTER INSERT OR UPDATE OR DELETE ON ratings
FOR EACH ROW EXECUTE FUNCTION update_book_rating();

-- 自动更新点赞计数
CREATE OR REPLACE FUNCTION update_like_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.target_type = 'book' THEN
            UPDATE books SET likes_count = likes_count + 1 WHERE id = NEW.target_id;
        ELSIF NEW.target_type = 'chapter' THEN
            UPDATE chapters SET likes_count = likes_count + 1 WHERE id = NEW.target_id;
        ELSIF NEW.target_type = 'activity' THEN
            UPDATE book_activities SET likes_count = likes_count + 1 WHERE id = NEW.target_id;
        ELSIF NEW.target_type = 'comment' THEN
            UPDATE comments SET likes_count = likes_count + 1 WHERE id = NEW.target_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.target_type = 'book' THEN
            UPDATE books SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.target_id;
        ELSIF OLD.target_type = 'chapter' THEN
            UPDATE chapters SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.target_id;
        ELSIF OLD.target_type = 'activity' THEN
            UPDATE book_activities SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.target_id;
        ELSIF OLD.target_type = 'comment' THEN
            UPDATE comments SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.target_id;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER like_counts_trigger
AFTER INSERT OR DELETE ON likes
FOR EACH ROW EXECUTE FUNCTION update_like_counts();

-- 生成UUID的工具函数
CREATE OR REPLACE FUNCTION generate_uuid_str()
RETURNS VARCHAR(64) AS $$
BEGIN
    RETURN uuid_generate_v4()::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- 生成订单号的函数
CREATE OR REPLACE FUNCTION generate_order_no(prefix VARCHAR(10))
RETURNS VARCHAR(64) AS $$
BEGIN
    RETURN prefix || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(NEXTVAL('order_seq')::TEXT, 12, '0');
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS order_seq START 1;

-- 敏感词检测函数
CREATE OR REPLACE FUNCTION check_sensitive_words(content TEXT)
RETURNS TABLE(word VARCHAR, word_type VARCHAR, level SMALLINT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.word, s.word_type, s.level
    FROM sensitive_words s
    WHERE s.is_active = TRUE
      AND position(lower(s.word) IN lower(content)) > 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 12. 分区表(可选,用于大数据量)
-- ============================================

-- 如果需要,可以为日志表创建分区
-- CREATE TABLE notifications_partitioned (
--     LIKE notifications INCLUDING ALL
-- ) PARTITION BY RANGE (created_at);

-- 创建月度分区
-- CREATE TABLE notifications_2024_01 PARTITION OF notifications_partitioned
--     FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- ============================================
-- 13. 权限与安全
-- ============================================

-- 创建应用专用角色
DO $$
BEGIN
    -- 创建只读角色(用于报表)
    CREATE ROLE report_reader;
    
    -- 创建应用角色
    CREATE ROLE app_user;
    
    -- 授予基本权限
    GRANT CONNECT ON DATABASE 10kbooks TO app_user;
    GRANT USAGE ON SCHEMA public TO app_user;
    
    -- 授予表权限
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;
    
    -- 报表角色只读权限
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO report_reader;
END $$;

-- ============================================
-- 14. 注释
-- ============================================

COMMENT ON TABLE users IS '用户主表 - 存储所有用户信息';
COMMENT ON TABLE books IS '书籍主表 - 核心内容表';
COMMENT ON TABLE chapters IS '章节表 - 书籍章节内容';
COMMENT ON TABLE orders IS '订单表 - 支付和充值记录';
COMMENT ON TABLE notifications IS '通知表 - 用户通知消息';

-- 完成标记
SELECT '10kBooks Database Schema v1.0.0 Initialized Successfully!' AS status;
