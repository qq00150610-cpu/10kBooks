-- ============================================
-- 万卷书苑 / 10kBooks 种子数据
-- 包含测试数据用于开发、演示
-- ============================================

-- ============================================
-- 1. 系统配置数据
-- ============================================

INSERT INTO system_configs (config_key, config_value, config_type, description, is_public) VALUES
-- 功能开关
('feature.translation_enabled', '{"value": true, "description": "是否启用AI翻译功能"}', 'feature', 'AI翻译功能开关', true),
('feature.ai_generation_enabled', '{"value": true, "description": "是否启用AI内容生成"}', 'feature', 'AI生成功能开关', true),
('feature.comments_enabled', '{"value": true, "description": "是否启用评论功能"}', 'feature', '评论功能开关', true),

-- 支付配置
('payment.platform_share', '{"subscription": 50, "chapter_purchase": 70, "gift": 20, "description": "平台抽成比例%"}', 'payment', '平台分成比例', false),
('payment.min_withdrawal', '{"CNY": 10000, "description": "最低提现金额(分)"}', 'payment', '最低提现额度', true),
('payment.withdrawal_fee_rate', '{"rate": 0, "description": "提现手续费率%"}', 'payment', '提现手续费', false),

-- 内容限制
('content.max_chapter_length', '{"value": 50000, "description": "单章最大字数"}', 'content', '章节字数限制', true),
('content.max_book_tags', '{"value": 5, "description": "书籍最大标签数"}', 'content', '标签数量限制', true),
('content.review_threshold', '{"value": 500, "description": "发布评论最低字数"}', 'content', '评论字数要求', true),

-- 限流配置
('limit.api_rate_limit', '{"default": 100, "premium": 500, "window": 60, "description": "API限流(次/分钟)"}', 'limit', 'API限流配置', false),
('limit.chapter_publish_daily', '{"value": 10, "description": "每日发布章节限制"}', 'limit', '章节发布限制', true),

-- AI配置
('ai.free_translation_quota', '{"monthly": 100000, "description": "免费翻译额度(token/月)"}', 'limit', '免费翻译配额', true),
('ai.free_generation_quota', '{"monthly": 50000, "description": "免费生成额度(token/月)"}', 'limit', '免费生成配额', true),

-- VIP配置
('vip.levels', '{"1": {"name": "月度会员", "days": 30, "benefits": ["去广告", "专属书源"]}, "2": {"name": "季度会员", "days": 90, "benefits": ["去广告", "专属书源", "8折购书"]}, "3": {"name": "年度会员", "days": 365, "benefits": ["去广告", "专属书源", "7折购书", "优先更新"]}}', 'payment', 'VIP会员配置', true);

-- ============================================
-- 2. 分类数据
-- ============================================

INSERT INTO categories (slug, name_i18n, sort_order, icon) VALUES
('fantasy', '{"zh-CN": "玄幻奇幻", "en": "Fantasy", "ja": "ファンタジー", "ko": "판타지"}', 1, 'fa-magic'),
('xianxia', '{"zh-CN": "仙侠修真", "en": "Xianxia", "ja": "仙侠", "ko": "선협"}', 2, 'fa-cloud'),
('urban', '{"zh-CN": "都市异能", "en": "Urban Fantasy", "ja": "現代都市", "ko": "현대도시"}', 3, 'fa-city'),
('scifi', '{"zh-CN": "科幻未来", "en": "Science Fiction", "ja": "SF", "ko": "SF"}', 4, 'fa-rocket'),
('romance', '{"zh-CN": "浪漫言情", "en": "Romance", "ja": "恋愛", "ko": "로맨스"}', 5, 'fa-heart'),
('historical', '{"zh-CN": "古风历史", "en": "Historical", "ja": "歴史", "ko": "역사"}', 6, 'fa-landmark'),
('mystery', '{"zh-CN": "悬疑惊悚", "en": "Mystery", "ja": "ミステリー", "ko": "미스터리"}', 7, 'fa-search'),
('game', '{"zh-CN": "游戏竞技", "en": "Gaming", "ja": "ゲーム", "ko": "게임"}', 8, 'fa-gamepad'),
('literary', '{"zh-CN": "文学小说", "en": "Literary Fiction", "ja": "文学", "ko": "문학"}', 9, 'fa-book'),
('biography', '{"zh-CN": "人物传记", "en": "Biography", "ja": "伝記", "ko": "전기"}', 10, 'fa-user');

-- ============================================
-- 3. 标签数据
-- ============================================

INSERT INTO tags (slug, name_i18n, usage_count, is_hot, is_official) VALUES
('boss', '{"zh-CN": "总裁豪门", "en": "CEO/Tycoon", "ja": "社長", "ko": "사장"}', 5200, true, true),
('transmigration', '{"zh-CN": "穿越重生", "en": "Reincarnation", "ja": "転生", "ko": "전생"}', 4800, true, true),
('sweet', '{"zh-CN": "甜宠", "en": "Sweet Romance", "ja": "甘々", "ko": "달콤"}', 4500, true, true),
('cultivation', '{"zh-CN": "修炼", "en": "Cultivation", "ja": "修炼", "ko": "수련"}', 3200, true, true),
('system', '{"zh-CN": "系统流", "en": "System", "ja": "システム", "ko": "시스템"}', 3100, true, true),
('war', '{"zh-CN": "战争", "en": "War", "ja": "戦争", "ko": "전쟁"}', 2800, true, false),
('school', '{"zh-CN": "校园", "en": "School", "ja": "学園", "ko": "학교"}', 2600, false, true),
('revenge', '{"zh-CN": "复仇", "en": "Revenge", "ja": "復讐", "ko": "복수"}', 2400, false, false),
('comedy', '{"zh-CN": "轻松", "en": "Comedy", "ja": "コメディ", "ko": "코미디"}', 2300, false, true),
('horror', '{"zh-CN": "恐怖", "en": "Horror", "ja": "ホラー", "ko": "공포"}', 1800, false, false);

-- ============================================
-- 4. AI模型配置
-- ============================================

INSERT INTO ai_models (model_key, provider, name, description, capabilities, supported_locales, input_price_per_1k_tokens, output_price_per_1k_tokens, max_tokens, is_active, is_default) VALUES
('gpt-4o', 'openai', 'GPT-4o', 'OpenAI最新多模态模型', ARRAY['translation', 'summary', 'generate', 'qa'], ARRAY['en', 'zh-CN', 'ja', 'ko', 'es', 'fr', 'de', 'pt', 'ru', 'ar'], 350, 500, 128000, true, true),
('gpt-4o-mini', 'openai', 'GPT-4o Mini', '轻量级GPT-4o', ARRAY['translation', 'summary'], ARRAY['en', 'zh-CN', 'ja', 'ko'], 15, 60, 128000, true, false),
('claude-3-5-sonnet', 'anthropic', 'Claude 3.5 Sonnet', 'Anthropic高性能模型', ARRAY['translation', 'summary', 'generate', 'qa'], ARRAY['en', 'zh-CN', 'ja', 'ko', 'es', 'fr', 'de', 'pt'], 300, 450, 200000, true, false),
('gemini-pro', 'google', 'Gemini Pro', 'Google多模态AI', ARRAY['translation', 'summary', 'generate'], ARRAY['en', 'zh-CN', 'ja', 'ko'], 50, 150, 32768, true, false),
('ERNIE-4', 'baidu', '文心一言4.0', '百度中文优化模型', ARRAY['translation', 'summary', 'generate', 'qa'], ARRAY['zh-CN', 'en'], 100, 200, 8000, true, false);

-- ============================================
-- 5. 充值套餐
-- ============================================

INSERT INTO recharge_packages (name, coins, bonus_coins, currency, price, is_active, is_featured, sort_order, name_i18n) VALUES
('小试牛刀', 100, 0, 'CNY', 100, true, false, 1, '{"zh-CN": "小试牛刀", "en": "Starter Pack"}'),
('初出茅庐', 600, 30, 'CNY', 600, true, true, 2, '{"zh-CN": "初出茅庐", "en": "Beginner Pack"}'),
('渐入佳境', 1200, 120, 'CNY', 1200, true, true, 3, '{"zh-CN": "渐入佳境", "en": "Value Pack"}'),
('挥金如土', 3000, 500, 'CNY', 3000, true, true, 4, '{"zh-CN": "挥金如土", "en": "Premium Pack"}'),
('富甲一方', 6000, 1500, 'CNY', 6000, true, false, 5, '{"zh-CN": "富甲一方", "en": "Ultimate Pack"}');

-- ============================================
-- 6. 敏感词示例
-- ============================================

INSERT INTO sensitive_words (word, word_type, level, locale) VALUES
('赌博', 'ads', 2, 'zh-CN'),
('毒品', 'violence', 3, 'all'),
('色情', 'porn', 3, 'all'),
('暴力', 'violence', 2, 'all'),
('敏感政治', 'political', 3, 'zh-CN');

-- ============================================
-- 7. 通知模板
-- ============================================

INSERT INTO notification_templates (template_code, template_type, title_i18n, content_i18n, variables) VALUES
('new_chapter', 'activity', 
 '{"zh-CN": "《{{book_title}}》更新啦!", "en": "{{book_title}} has a new chapter!"}', 
 '{"zh-CN": "作者 {{author_name}} 更新了《{{book_title}}》第{{chapter_number}}章: {{chapter_title}}", "en": "Author {{author_name}} updated Chapter {{chapter_number}}: {{chapter_title}}"}',
 ARRAY['book_title', 'author_name', 'chapter_number', 'chapter_title']),

('new_follower', 'interaction',
 '{"zh-CN": "新粉丝", "en": "New Follower"}',
 '{"zh-CN": "{{user_name}} 关注了你,你们现在是朋友啦!", "en": "{{user_name}} started following you!"}',
 ARRAY['user_name']),

('comment_on_book', 'interaction',
 '{"zh-CN": "有人评论了你的书", "en": "New Comment on Your Book"}',
 '{"zh-CN": "{{user_name}} 评论了《{{book_title}}》: {{comment_preview}}...", "en": "{{user_name}} commented on {{book_title}}: {{comment_preview}}..."}',
 ARRAY['user_name', 'book_title', 'comment_preview']),

('earnings_update', 'transaction',
 '{"zh-CN": "收益到账", "en": "Earnings Update"}',
 '{"zh-CN": "恭喜! 您的账户收到 {{amount}} 金币,来自《{{book_title}}》的章节订阅分成", "en": "Congratulations! You received {{amount}} coins from {{book_title}} subscriptions"}',
 ARRAY['amount', 'book_title']),

('vip_expiring', 'system',
 '{"zh-CN": "VIP会员即将到期", "en": "VIP Expiring Soon"}',
 '{"zh-CN": "您的{{vip_level}}将于{{expire_date}}到期,到期后将无法享受VIP专属权益", "en": "Your {{vip_level}} will expire on {{expire_date}}"}',
 ARRAY['vip_level', 'expire_date']);

-- ============================================
-- 8. 测试用户数据
-- ============================================

-- 测试用户1 - 普通用户
INSERT INTO users (id, uuid, username, email, password_hash, display_name, avatar_url, bio, locale, status, email_verified, vip_level, vip_expire_at)
VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'user_000001',
    'reader_demo',
    'reader@10kbooks.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfH.',  -- password: demo123
    '阅读者小明',
    'https://cdn.10kbooks.com/avatars/default_avatar.png',
    '热爱阅读的普通人,喜欢玄幻和都市小说',
    'zh-CN',
    1,
    true,
    0,
    NULL
);

-- 测试用户2 - VIP用户
INSERT INTO users (id, uuid, username, email, password_hash, display_name, avatar_url, bio, locale, status, email_verified, vip_level, vip_expire_at)
VALUES (
    'a0000000-0000-0000-0000-000000000002',
    'user_000002',
    'vip_reader',
    'vip@10kbooks.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfH.',
    'VIP阅读达人',
    'https://cdn.10kbooks.com/avatars/vip_avatar.png',
    'VIP用户,专注阅读精品好书',
    'en',
    1,
    true,
    3,
    '2025-12-31 23:59:59+08'
);

-- 测试用户3 - 作者用户
INSERT INTO users (id, uuid, username, email, password_hash, display_name, avatar_url, bio, locale, status, email_verified)
VALUES (
    'a0000000-0000-0000-0000-000000000003',
    'user_000003',
    'author_demo',
    'author@10kbooks.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfH.',
    '知名网文作家',
    'https://cdn.10kbooks.com/avatars/author_avatar.png',
    '专注创作玄幻仙侠小说,已出版多部作品',
    'zh-CN',
    1,
    true
);

-- 创建作者
INSERT INTO authors (user_id, pen_name, avatar_url, bio, is_verified, verified_at, author_level, author_level_updated_at, total_words, total_views)
VALUES (
    'a0000000-0000-0000-0000-000000000003',
    '云起书院',
    'https://cdn.10kbooks.com/avatars/author_avatar.png',
    '十年网文创作经验,代表作《仙武帝尊》《万古剑尊》',
    true,
    '2023-01-15 10:00:00+08',
    5,
    '2024-06-01 00:00:00+08',
    15000000,
    50000000
);

-- 测试用户4 - 管理员
INSERT INTO users (id, uuid, username, email, password_hash, display_name, locale, status, email_verified)
VALUES (
    'a0000000-0000-0000-0000-000000000004',
    'user_admin001',
    'admin',
    'admin@10kbooks.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfH.',
    '系统管理员',
    'zh-CN',
    1,
    true
);

-- 创建用户钱包
INSERT INTO user_wallets (user_id, coins, points) VALUES
('a0000000-0000-0000-0000-000000000001', 500, 1200),
('a0000000-0000-0000-0000-000000000002', 5000, 5000),
('a0000000-0000-0000-0000-000000000003', 10000, 8000),
('a0000000-0000-0000-0000-000000000004', 0, 0);

-- 用户设置
INSERT INTO user_settings (user_id, preferred_genres, reading_theme, font_size)
VALUES
('a0000000-0000-0000-0000-000000000001', ARRAY['fantasy', 'urban'], 'light', 16),
('a0000000-0000-0000-0000-000000000002', ARRAY['romance', 'urban'], 'dark', 18);

-- ============================================
-- 9. 测试书籍数据
-- ============================================

-- 书籍1 - 玄幻小说
INSERT INTO books (id, book_uuid, author_id, title, title_i18n, cover_url, description, description_i18n, 
    category_id, tags, original_locale, genre, word_count, chapter_count, status, is_paywalled, 
    views_count, likes_count, followers_count, subscribers_count, avg_rating, ratings_count,
    audit_status, published_at, first_published_at, is_featured)
SELECT 
    'b0000000-0000-0000-0000-000000000001',
    'book_000001',
    'a0000000-0000-0000-0000-000000000003',
    '仙武帝尊',
    '{"en": "Martial God Emperor", "ja": "仙武帝尊"}',
    'https://cdn.10kbooks.com/covers/book_001.jpg',
    '一代仙帝重生都市,开启逆天成神之路!',
    '{"en": "A supreme immortal lord is reborn in the modern world, starting a path to becoming a god!", "ja": "最上の仙帝が現代に復活、神となる道を歩み始める!"}',
    (SELECT id FROM categories WHERE slug = 'fantasy'),
    ARRAY[(SELECT id FROM tags WHERE slug = 'cultivation'), (SELECT id FROM tags WHERE slug = 'transmigration')],
    'zh-CN',
    'fantasy',
    5800000,
    1568,
    3,
    true,
    150000000,
    850000,
    120000,
    45000,
    4.8,
    52000,
    2,
    '2020-05-01 12:00:00+08',
    '2020-05-01 12:00:00+08',
    true;

-- 书籍2 - 都市小说
INSERT INTO books (id, book_uuid, author_id, title, title_i18n, cover_url, description, 
    category_id, tags, original_locale, genre, word_count, chapter_count, status, is_paywalled,
    views_count, likes_count, followers_count, avg_rating, ratings_count,
    audit_status, published_at, first_published_at)
SELECT 
    'b0000000-0000-0000-0000-000000000002',
    'book_000002',
    'a0000000-0000-0000-0000-000000000003',
    '都市狂少',
    '{"en": "Urban Tyrant", "ja": "都市タイラント"}',
    'https://cdn.10kbooks.com/covers/book_002.jpg',
    '穷学生偶得传承,从此走上人生巅峰,成为都市传奇!',
    (SELECT id FROM categories WHERE slug = 'urban'),
    ARRAY[(SELECT id FROM tags WHERE slug = 'boss'), (SELECT id FROM tags WHERE slug = 'system'])::UUID[],
    'zh-CN',
    'urban',
    4200000,
    1200,
    3,
    true,
    98000000,
    620000,
    89000,
    4.6,
    38000,
    2,
    '2021-03-15 08:00:00+08',
    '2021-03-15 08:00:00+08';

-- 书籍3 - 言情小说
INSERT INTO books (id, book_uuid, author_id, title, title_i18n, cover_url, description,
    category_id, tags, original_locale, genre, word_count, chapter_count, status, is_paywalled,
    views_count, likes_count, followers_count, avg_rating, ratings_count,
    audit_status, published_at, first_published_at)
SELECT 
    'b0000000-0000-0000-0000-000000000003',
    'book_000003',
    'a0000000-0000-0000-0000-000000000003',
    '豪门甜宠: 总裁爹地超给力',
    '{"en": "Sweet Love: The CEO Daddy", "ja": "スイートラブ: CEODaddy"}',
    'https://cdn.10kbooks.com/covers/book_003.jpg',
    '一场意外,她与他命运交织。他是商业帝国的王者,她是落魄的千金小姐。当爱情来临,且看他们如何携手共创辉煌!',
    (SELECT id FROM categories WHERE slug = 'romance'),
    ARRAY[(SELECT id FROM tags WHERE slug = 'boss'), (SELECT id FROM tags WHERE slug = 'sweet'])::UUID[],
    'zh-CN',
    'romance',
    850000,
    256,
    3,
    true,
    45000000,
    380000,
    56000,
    4.7,
    28000,
    2,
    '2022-08-20 10:00:00+08',
    '2022-08-20 10:00:00+08';

-- 书籍价格策略
INSERT INTO book_pricing (book_id, pricing_model, monthly_price, yearly_price, full_book_price, first_chapter_free, subscription_share_author)
VALUES
('b0000000-0000-0000-0000-000000000001', 'subscription', 300, 2800, 0, true, 70),
('b0000000-0000-0000-0000-000000000002', 'subscription', 300, 2800, 0, true, 70),
('b0000000-0000-0000-0000-000000000003', 'pay_per_chapter', 0, 0, 5000, true, 60);

-- ============================================
-- 10. 测试章节数据
-- ============================================

-- 仙武帝尊 - 第1章
INSERT INTO chapters (id, chapter_uuid, book_id, chapter_number, title, title_i18n, content, content_length, word_count, status, is_paywalled, published_at, audit_status)
VALUES (
    'c0000000-0000-0000-0000-000000000001',
    'chapter_001_001',
    'b0000000-0000-0000-0000-000000000001',
    1,
    '第一章 重生',
    '{"en": "Chapter 1: Rebirth"}',
    E'第一章 重生\n\n\"砰!\"\n\n一声巨响,叶辰的身体被狠狠地砸在墙上,口中喷出一口鲜血。\n\n\"哈哈哈!叶辰,你以为你还是当年的仙帝吗?现在的你,不过是一个废物而已!\"\n\n叶辰抬起头,看着眼前的几人,眼中满是愤怒和不甘。\n\n他是九天仙域的仙帝,一介凡人逆天成帝,建立无上仙朝。然而就在渡劫飞升的关键时刻,被最信任的弟子和道侣背叛,身死道消。\n\n再次醒来,却发现自己重生到了一个同名同姓的少年身上。\n\n\"这一世,我叶辰必将重回巅峰,踏碎九天,让背叛我的人付出代价!\"\n\n......\n\n(本章为免费试读,后续章节需要订阅或购买)',
    450,
    450,
    3,
    false,
    '2020-05-01 12:00:00+08',
    2
);

-- 仙武帝尊 - 第2章
INSERT INTO chapters (id, chapter_uuid, book_id, chapter_number, title, content, content_length, word_count, status, is_paywalled, is_vip_chapter, published_at, audit_status)
VALUES (
    'c0000000-0000-0000-0000-000000000002',
    'chapter_001_002',
    'b0000000-0000-0000-0000-000000000001',
    2,
    '第二章 混沌天经',
    E'第二章 混沌天经\n\n就在叶辰绝望之际,一道金光突然从他的眉心处射出,化作一本古老的书籍。\n\n\"这是...混沌天经!\"\n\n叶辰激动得浑身发抖。作为曾经的仙帝,他自然知道这本书的来历。\n\n混沌天经,九天十地最强大的功法,据说修炼到极致可以掌控混沌,开天辟地。\n\n\"哈哈哈哈!天不亡我!\"\n\n叶辰仰天大笑,眼中闪烁着璀璨的光芒。\n\n\"前世我修炼的功法不过是残缺版的混沌天经,这一世有了完整版,我必能更快重回巅峰!\"\n\n......\n\n(本章为VIP章节,需要订阅阅读)',
    520,
    520,
    3,
    true,
    true,
    '2020-05-02 12:00:00+08',
    2
);

-- 都市狂少 - 第1章
INSERT INTO chapters (id, chapter_uuid, book_id, chapter_number, title, content, content_length, word_count, status, is_paywalled, published_at, audit_status)
VALUES (
    'c0000000-0000-0000-0000-000000000003',
    'chapter_002_001',
    'b0000000-0000-0000-0000-000000000002',
    1,
    '第一章 穷学生的逆袭',
    E'第一章 穷学生的逆袭\n\n\"叶凡,你被开除了!\"\n\n教导主任冷漠的声音在耳边响起,叶凡握紧了拳头。\n\n他不过是撞见校花被人欺负,出手相助,却反被诬陷殴打校草。\n\n\"我没有打人!\"\n\n\"证据确凿,还狡辩!保安,把他轰出去!\"\n\n就在叶凡被推出校门的那一刻,一道苍老的声音在他脑海中响起:\n\n\"孩子,我是你的祖先叶无道,现在将我的传承交给你......\"\n\n从这一刻起,叶凡的命运彻底改变。\n\n......',
    480,
    480,
    3,
    false,
    '2021-03-15 08:00:00+08',
    2
);

-- ============================================
-- 11. 测试书架数据
-- ============================================

INSERT INTO bookshelves (user_id, book_id, status, reading_progress, current_chapter_id) VALUES
('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 1, 35.5, 'c0000000-0000-0000-0000-000000000002'),
('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002', 1, 12.3, 'c0000000-0000-0000-0000-000000000003'),
('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 3, 100, NULL),
('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000003', 1, 45.0, NULL);

-- ============================================
-- 12. 测试阅读进度
-- ============================================

INSERT INTO reading_progress (user_id, book_id, chapter_id, progress, scroll_position, reading_time, last_read_at) VALUES
('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', 78.5, 15600, 1800, NOW()),
('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000003', 45.0, 5400, 900, NOW() - INTERVAL '1 day');

-- ============================================
-- 13. 测试关注关系
-- ============================================

INSERT INTO user_follows (follower_id, following_id) VALUES
('a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003'),  -- 普通用户关注作者
('a0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003'),  -- VIP用户关注作者
('a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002');  -- 用户之间互关

-- ============================================
-- 14. 测试评分
-- ============================================

INSERT INTO ratings (user_id, book_id, rating, content, content_i18n) VALUES
('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 5.0, '太好看了!仙帝重生设定很带感,剧情紧凑不拖沓,强烈推荐!', NULL),
('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 4.5, 'Very good! The cultivation story is engaging. 4.5 stars!', NULL),
('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 4.0, '都市爽文,文笔不错,打发时间很好!', NULL);

-- ============================================
-- 15. 测试评论
-- ============================================

INSERT INTO comments (user_id, target_type, target_id, content, locale, floor_number) VALUES
('a0000000-0000-0000-0000-000000000001', 'chapter', 'c0000000-0000-0000-0000-000000000001', '第一章就这么燃!仙帝重生,经典桥段!期待后续发展~', 'zh-CN', 1),
('a0000000-0000-0000-0000-000000000002', 'chapter', 'c0000000-0000-0000-0000-000000000001', 'Great chapter! Looking forward to more!', 'en', 2),
('a0000000-0000-0000-0000-000000000001', 'book', 'b0000000-0000-0000-0000-000000000001', '追更了三年,终于快完结了!作者大大加油!', 'zh-CN', 1);

-- ============================================
-- 16. 测试订单
-- ============================================

-- 充值订单
INSERT INTO orders (id, order_no, user_id, order_type, total_amount, paid_amount, payment_method, payment_status, paid_at)
VALUES (
    'o0000000-0000-0000-0000-000000000001',
    'ORD202401150001',
    'a0000000-0000-0000-0000-000000000001',
    'recharge',
    600,
    600,
    'alipay',
    'paid',
    '2024-01-15 14:30:00+08'
);

-- 章节购买订单
INSERT INTO orders (id, order_no, user_id, order_type, total_amount, paid_amount, payment_method, payment_status, paid_at, ref_type, ref_id)
VALUES (
    'o0000000-0000-0000-0000-000000000002',
    'ORD202401160001',
    'a0000000-0000-0000-0000-000000000001',
    'purchase',
    50,
    50,
    'coins',
    'paid',
    '2024-01-16 10:00:00+08',
    'chapter',
    'c0000000-0000-0000-0000-000000000002'
);

-- 购买记录
INSERT INTO purchases (id, purchase_uuid, user_id, book_id, chapter_id, order_id, price, purchase_type, author_id, author_share, commission_amount)
VALUES (
    'p0000000-0000-0000-0000-000000000001',
    'PUR202401160001',
    'a0000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000002',
    'o0000000-0000-0000-0000-000000000002',
    50,
    'chapter',
    'a0000000-0000-0000-0000-000000000003',
    70.00,
    35
);

-- ============================================
-- 17. 测试VIP订阅
-- ============================================

INSERT INTO vip_subscriptions (id, sub_uuid, user_id, vip_level, level_name, price, start_at, expire_at, source, status)
VALUES (
    'v0000000-0000-0000-0000-000000000001',
    'VIP202401010001',
    'a0000000-0000-0000-0000-000000000002',
    3,
    '年度会员',
    29800,
    '2024-01-01 00:00:00+08',
    '2025-01-01 00:00:00+08',
    'direct',
    'active'
);

-- ============================================
-- 18. 测试通知
-- ============================================

INSERT INTO notifications (notification_uuid, user_id, type, title, content, action_type, action_id, is_read)
VALUES
('n0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'new_chapter', '《仙武帝尊》更新啦!', '作者云起书院 更新了《仙武帝尊》第1568章', 'chapter', 'c0000000-0000-0000-0000-000000000002', false),
('n0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'follow', '新粉丝', 'VIP阅读达人 关注了你', 'user', 'a0000000-0000-0000-0000-000000000002', true);

-- ============================================
-- 19. 测试积分变动
-- ============================================

INSERT INTO wallet_transactions (user_id, transaction_no, type, category, amount, balance_before, balance_after, ref_type, ref_id, description)
VALUES
-- 用户1的充值
('a0000000-0000-0000-0000-000000000001', 'TXN202401150001', 'recharge', 'income', 600, 0, 600, 'order', 'o0000000-0000-0000-0000-000000000001', '支付宝充值600金币'),
-- 用户1的购买
('a0000000-0000-0000-0000-000000000001', 'TXN202401160001', 'purchase', 'expense', -50, 600, 550, 'chapter', 'c0000000-0000-0000-0000-000000000002', '购买《仙武帝尊》第2章'),
-- 作者收益
('a0000000-0000-0000-0000-000000000003', 'TXN202401160002', 'commission', 'income', 35, 999965, 100000, 'purchase', 'p0000000-0000-0000-0000-000000000001', '《仙武帝尊》第2章订阅分成');

-- ============================================
-- 20. 测试书籍多语言翻译
-- ============================================

INSERT INTO book_translations (book_id, locale, title, description, is_translated)
VALUES
('b0000000-0000-0000-0000-000000000001', 'en', 'Martial God Emperor', 'A supreme immortal lord is reborn in the modern world, starting a path to becoming a god!', true),
('b0000000-0000-0000-0000-000000000001', 'ja', '仙武帝尊', '最上の仙帝が現代に復活、神となる道を歩み始める!', true),
('b0000000-0000-0000-0000-000000000002', 'en', 'Urban Tyrant', 'A poor student accidentally obtains an ancient inheritance, becoming an urban legend!', true),
('b0000000-0000-0000-0000-000000000003', 'en', 'Sweet Love: The CEO Daddy', 'A romance between a CEO and a fallen noble lady. A touching love story!', true);

-- ============================================
-- 完成标记
-- ============================================

SELECT '10kBooks Seed Data v1.0.0 Loaded Successfully!' AS status;
SELECT 'Total Records Inserted:' AS info;
SELECT 
    (SELECT COUNT(*) FROM users) AS users_count,
    (SELECT COUNT(*) FROM authors) AS authors_count,
    (SELECT COUNT(*) FROM books) AS books_count,
    (SELECT COUNT(*) FROM chapters) AS chapters_count,
    (SELECT COUNT(*) FROM categories) AS categories_count,
    (SELECT COUNT(*) FROM tags) AS tags_count;
