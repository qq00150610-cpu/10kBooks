// Book categories
export const BOOK_CATEGORIES = [
  {
    id: 'fantasy',
    name: '玄幻奇幻',
    nameEn: 'Fantasy',
    icon: '🐉',
    subCategories: ['东方玄幻', '西方奇幻', '异世大陆', '远古神话'],
  },
  {
    id: 'xianxia',
    name: '仙侠修真',
    nameEn: 'Xianxia',
    icon: '⚔️',
    subCategories: ['古典仙侠', '现代修仙', '凡人流', '洪荒流'],
  },
  {
    id: 'urban',
    name: '都市言情',
    nameEn: 'Urban Romance',
    icon: '🏙️',
    subCategories: ['都市生活', '职场商战', '黑道风云', '特种兵'],
  },
  {
    id: 'romance',
    name: '浪漫青春',
    nameEn: 'Romance',
    icon: '💕',
    subCategories: ['现代言情', '古代言情', '青春校园', '纯爱同人'],
  },
  {
    id: 'thriller',
    name: '悬疑灵异',
    nameEn: 'Thriller',
    icon: '🔮',
    subCategories: ['推理探案', '灵异鬼怪', '探险墓穴', '恐怖惊悚'],
  },
  {
    id: 'scifi',
    name: '科幻未来',
    nameEn: 'Sci-Fi',
    icon: '🚀',
    subCategories: ['星际科幻', '未来世界', '进化变异', '时空穿梭'],
  },
  {
    id: 'history',
    name: '历史军事',
    nameEn: 'Historical',
    icon: '🏯',
    subCategories: ['历史传奇', '军事战争', '穿越历史', '架空历史'],
  },
  {
    id: 'gaming',
    name: '游戏竞技',
    nameEn: 'Gaming',
    icon: '🎮',
    subCategories: ['虚拟网游', '电竞游戏', '全息网游', '游戏异界'],
  },
] as const;

// VIP levels
export const VIP_LEVELS = [
  { level: 0, name: '普通会员', nameEn: 'Member', color: 'gray' },
  { level: 1, name: 'VIP会员', nameEn: 'VIP', color: 'yellow' },
  { level: 2, name: 'SVIP会员', nameEn: 'SVIP', color: 'purple' },
  { level: 3, name: '年度会员', nameEn: 'Annual', color: 'gold' },
] as const;

// VIP benefits
export const VIP_BENEFITS = [
  { icon: '📚', title: '免费阅读', desc: 'VIP专属书籍免费读' },
  { icon: '⚡', title: '抢先看', desc: '最新章节提前阅读' },
  { icon: '🎁', title: '专属书单', desc: '创建私人收藏夹' },
  { icon: '💎', title: '无广告', desc: '清爽阅读体验' },
  { icon: '📱', title: '多端同步', desc: '跨设备同步阅读进度' },
  { icon: '🎫', title: '活动优先', desc: '优先参与平台活动' },
] as const;

// Reader themes
export const READER_THEMES = [
  { id: 'paper', name: '白天', bg: '#f5f5f0', text: '#333333' },
  { id: 'sepia', name: '护眼', bg: '#f4ecd8', text: '#5b4636' },
  { id: 'night', name: '夜间', bg: '#1a1a2e', text: '#c4c4c4' },
  { id: 'dark', name: '深黑', bg: '#0f0f0f', text: '#e0e0e0' },
] as const;

// Reader font sizes
export const READER_FONT_SIZES = [14, 16, 18, 20, 22, 24, 26, 28, 30, 32] as const;

// Reader line heights
export const READER_LINE_HEIGHTS = [1.4, 1.6, 1.8, 2.0, 2.2] as const;

// Book statuses
export const BOOK_STATUSES = [
  { value: 'ongoing', label: '连载中', labelEn: 'Ongoing' },
  { value: 'completed', label: '已完结', labelEn: 'Completed' },
  { value: 'paused', label: '暂停更新', labelEn: 'Paused' },
] as const;

// Sort options
export const SORT_OPTIONS = [
  { value: 'relevance', label: '相关度', labelEn: 'Relevance' },
  { value: 'rating', label: '评分', labelEn: 'Rating' },
  { value: 'views', label: '热度', labelEn: 'Popularity' },
  { value: 'updated', label: '更新时间', labelEn: 'Recently Updated' },
  { value: 'newest', label: '最新', labelEn: 'Newest' },
] as const;

// Author levels
export const AUTHOR_LEVELS = [
  { level: 1, name: '新人作者', minWords: 0, minBooks: 0 },
  { level: 2, name: '签约作者', minWords: 30000, minBooks: 1 },
  { level: 3, name: '星级作者', minWords: 100000, minBooks: 2 },
  { level: 4, name: '白金作者', minWords: 500000, minBooks: 5 },
  { level: 5, name: '大神作者', minWords: 1000000, minBooks: 10 },
] as const;

// Withdrawal limits
export const WITHDRAWAL_LIMITS = {
  minAmount: 100,
  maxAmount: 100000,
  fee: 0.05,
  processingDays: 3,
} as const;

// Platform stats
export const PLATFORM_STATS = {
  totalBooks: 1500000,
  totalAuthors: 500000,
  totalUsers: 50000000,
  totalReads: 100000000000,
} as const;

// Recharge packages
export const RECHARGE_PACKAGES = [
  { coins: 100, amount: 10, bonus: 0 },
  { coins: 500, amount: 50, bonus: 20 },
  { coins: 1000, amount: 100, bonus: 50 },
  { coins: 2000, amount: 200, bonus: 120 },
  { coins: 5000, amount: 500, bonus: 350 },
  { coins: 10000, amount: 1000, bonus: 800 },
] as const;
