import { Suspense } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { getTranslations } from 'next-intl/server';
import { BookCard } from '@/components/common/BookCard';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { SearchBar } from '@/components/common/SearchBar';
import { Loading, CardSkeleton } from '@/components/ui/Loading';
import {
  BookOpen,
  TrendingUp,
  Star,
  Users,
  Crown,
  ChevronRight,
  Sparkles,
  Flame,
  Clock,
} from 'lucide-react';

// Mock data
const FEATURED_BOOKS = [
  {
    id: '1',
    title: '仙武帝尊',
    cover: 'https://picsum.photos/seed/book1/300/400',
    author: { id: '1', name: '火星引力', avatar: '' },
    category: '玄幻',
    tags: ['东方玄幻', '热血'],
    description: '三千年前，他被人陷害，生死之际，却意外获得绝世功法，从此踏上一条逆天成神之路...',
    status: 'completed' as const,
    wordCount: 8560000,
    viewCount: 125600000,
    likeCount: 890000,
    commentCount: 45600,
    subscribeCount: 125000,
    rating: 4.8,
    ratingCount: 89000,
    chapters: [],
    createdAt: '2020-01-01',
    updatedAt: '2024-01-15',
    isVip: false,
    isPaid: false,
    freeChapterCount: 30,
  },
  {
    id: '2',
    title: '都市逍遥医神',
    cover: 'https://picsum.photos/seed/book2/300/400',
    author: { id: '2', name: '疯狂小马甲', avatar: '' },
    category: '都市',
    tags: ['都市生活', '医术'],
    description: '一代神医重生都市，左手惊天医术，右手霸道都市，逍遥花都...',
    status: 'ongoing' as const,
    wordCount: 3200000,
    viewCount: 45600000,
    likeCount: 320000,
    commentCount: 23400,
    subscribeCount: 89000,
    rating: 4.6,
    ratingCount: 56700,
    chapters: [],
    createdAt: '2022-03-15',
    updatedAt: '2024-01-20',
    isVip: true,
    isPaid: false,
    freeChapterCount: 10,
  },
  {
    id: '3',
    title: '庆余年',
    cover: 'https://picsum.photos/seed/book3/300/400',
    author: { id: '3', name: '猫腻', avatar: '' },
    category: '历史',
    tags: ['架空历史', '权谋'],
    description: '积善之家，必有余庆，留余庆，留余庆，忽遇恩人...',
    status: 'completed' as const,
    wordCount: 3980000,
    viewCount: 98700000,
    likeCount: 1200000,
    commentCount: 89000,
    subscribeCount: 234000,
    rating: 4.9,
    ratingCount: 156000,
    chapters: [],
    createdAt: '2019-05-20',
    updatedAt: '2023-12-01',
    isVip: false,
    isPaid: false,
    freeChapterCount: 50,
  },
  {
    id: '4',
    title: '全职高手',
    cover: 'https://picsum.photos/seed/book4/300/400',
    author: { id: '4', name: '蝴蝶蓝', avatar: '' },
    category: '游戏',
    tags: ['电竞', '热血'],
    description: '网游荣耀中被誉为教科书级别的顶尖高手叶修，因为种种原因遭到俱乐部的驱逐...',
    status: 'completed' as const,
    wordCount: 2150000,
    viewCount: 78900000,
    likeCount: 980000,
    commentCount: 67000,
    subscribeCount: 189000,
    rating: 4.9,
    ratingCount: 134000,
    chapters: [],
    createdAt: '2018-08-10',
    updatedAt: '2023-06-15',
    isVip: false,
    isPaid: false,
    freeChapterCount: 30,
  },
  {
    id: '5',
    title: '凡人修仙传',
    cover: 'https://picsum.photos/seed/book5/300/400',
    author: { id: '5', name: '忘语', avatar: '' },
    category: '仙侠',
    tags: ['凡人流', '修仙'],
    description: '一个资质平庸的少年，偶得机遇，一步步踏上修仙之路...',
    status: 'completed' as const,
    wordCount: 7450000,
    viewCount: 156000000,
    likeCount: 2100000,
    commentCount: 123000,
    subscribeCount: 345000,
    rating: 4.8,
    ratingCount: 234000,
    chapters: [],
    createdAt: '2016-01-01',
    updatedAt: '2023-08-20',
    isVip: true,
    isPaid: false,
    freeChapterCount: 20,
  },
  {
    id: '6',
    title: '雪中悍刀行',
    cover: 'https://picsum.photos/seed/book6/300/400',
    author: { id: '6', name: '烽火戏诸侯', avatar: '' },
    category: '武侠',
    tags: ['武侠', '权谋'],
    description: '江湖是一张珠帘。大人物小人物，是珠子，大故事小故事，是串线...',
    status: 'completed' as const,
    wordCount: 3920000,
    viewCount: 89000000,
    likeCount: 1560000,
    commentCount: 98000,
    subscribeCount: 267000,
    rating: 4.9,
    ratingCount: 189000,
    chapters: [],
    createdAt: '2017-06-01',
    updatedAt: '2023-03-15',
    isVip: false,
    isPaid: false,
    freeChapterCount: 40,
  },
];

const HOT_RANKING = [
  { id: 1, book: FEATURED_BOOKS[4] },
  { id: 2, book: FEATURED_BOOKS[0] },
  { id: 3, book: FEATURED_BOOKS[2] },
  { id: 4, book: FEATURED_BOOKS[3] },
  { id: 5, book: FEATURED_BOOKS[5] },
  { id: 6, book: FEATURED_BOOKS[1] },
];

const CATEGORIES = [
  { id: 'fantasy', name: '玄幻奇幻', icon: '🐉', count: 125000 },
  { id: 'xianxia', name: '仙侠修真', icon: '⚔️', count: 98000 },
  { id: 'urban', name: '都市言情', icon: '🏙️', count: 156000 },
  { id: 'romance', name: '浪漫青春', icon: '💕', count: 87000 },
  { id: 'thriller', name: '悬疑灵异', icon: '🔮', count: 67000 },
  { id: 'scifi', name: '科幻未来', icon: '🚀', count: 45000 },
  { id: 'history', name: '历史军事', icon: '🏯', count: 56000 },
  { id: 'gaming', name: '游戏竞技', icon: '🎮', count: 78000 },
];

export default function HomePage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-br from-primary/10 via-background to-secondary/10">
        <div className="container mx-auto px-4 py-16 md:py-24">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div className="space-y-6">
              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight">
                万卷书苑
                <span className="block text-2xl md:text-3xl lg:text-4xl mt-2 text-muted-foreground">
                  10kBooks
                </span>
              </h1>
              <p className="text-lg md:text-xl text-muted-foreground max-w-md">
                探索海量优质小说，开启你的阅读之旅。海量书籍、智能推荐、流畅阅读体验。
              </p>
              <div className="flex flex-wrap gap-4">
                <Button size="lg" asChild>
                  <Link href="/category">
                    <BookOpen className="h-5 w-5 mr-2" />
                    开始阅读
                  </Link>
                </Button>
                <Button size="lg" variant="outline" asChild>
                  <Link href="/author/join">
                    <Sparkles className="h-5 w-5 mr-2" />
                    成为作者
                  </Link>
                </Button>
              </div>
              <div className="flex gap-8 pt-4">
                <div className="text-center">
                  <p className="text-2xl font-bold">5000万+</p>
                  <p className="text-sm text-muted-foreground">活跃读者</p>
                </div>
                <div className="text-center">
                  <p className="text-2xl font-bold">150万+</p>
                  <p className="text-sm text-muted-foreground">作品数量</p>
                </div>
                <div className="text-center">
                  <p className="text-2xl font-bold">50万+</p>
                  <p className="text-sm text-muted-foreground">签约作者</p>
                </div>
              </div>
            </div>
            <div className="relative">
              <div className="grid grid-cols-2 gap-4">
                {FEATURED_BOOKS.slice(0, 4).map((book, index) => (
                  <div
                    key={book.id}
                    className="relative aspect-[3/4] rounded-xl overflow-hidden shadow-xl transform hover:scale-105 transition-transform"
                    style={{ zIndex: 4 - index }}
                  >
                    <Image
                      src={book.cover}
                      alt={book.title}
                      fill
                      className="object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
                    <div className="absolute bottom-3 left-3 right-3">
                      <p className="text-white font-semibold text-sm line-clamp-1">{book.title}</p>
                      <p className="text-white/70 text-xs">{book.author.name}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Search Section */}
      <section className="container mx-auto px-4 -mt-8 relative z-10">
        <Card className="shadow-xl border-0">
          <CardContent className="p-6">
            <SearchBar className="w-full" placeholder="搜索书名、作者或关键字..." />
          </CardContent>
        </Card>
      </section>

      {/* Categories Section */}
      <section className="container mx-auto px-4 py-12">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold">分类浏览</h2>
          <Button variant="ghost" asChild>
            <Link href="/category">
              查看全部
              <ChevronRight className="h-4 w-4 ml-1" />
            </Link>
          </Button>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-8 gap-4">
          {CATEGORIES.map((category) => (
            <Link
              key={category.id}
              href={`/category/${category.id}`}
              className="group text-center p-4 rounded-xl bg-muted/50 hover:bg-primary/10 transition-colors"
            >
              <span className="text-4xl">{category.icon}</span>
              <p className="mt-2 font-medium group-hover:text-primary transition-colors">
                {category.name}
              </p>
              <p className="text-xs text-muted-foreground">
                {(category.count / 10000).toFixed(1)}万+
              </p>
            </Link>
          ))}
        </div>
      </section>

      {/* Main Content */}
      <section className="container mx-auto px-4 py-8">
        <Tabs defaultValue="featured">
          <div className="flex items-center justify-between mb-6">
            <TabsList>
              <TabsTrigger value="featured">
                <Sparkles className="h-4 w-4 mr-2" />
                主编推荐
              </TabsTrigger>
              <TabsTrigger value="hot">
                <Flame className="h-4 w-4 mr-2" />
                热门连载
              </TabsTrigger>
              <TabsTrigger value="new">
                <Clock className="h-4 w-4 mr-2" />
                新书抢鲜
              </TabsTrigger>
              <TabsTrigger value="complete">
                <Star className="h-4 w-4 mr-2" />
                完本佳作
              </TabsTrigger>
            </TabsList>
          </div>

          <TabsContent value="featured">
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
              {FEATURED_BOOKS.map((book) => (
                <BookCard key={book.id} book={book} />
              ))}
            </div>
          </TabsContent>

          <TabsContent value="hot">
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
              {FEATURED_BOOKS.filter(b => b.status === 'ongoing').map((book) => (
                <BookCard key={book.id} book={book} />
              ))}
            </div>
          </TabsContent>

          <TabsContent value="new">
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
              {FEATURED_BOOKS.slice(0, 6).map((book) => (
                <BookCard key={book.id} book={book} />
              ))}
            </div>
          </TabsContent>

          <TabsContent value="complete">
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
              {FEATURED_BOOKS.filter(b => b.status === 'completed').map((book) => (
                <BookCard key={book.id} book={book} />
              ))}
            </div>
          </TabsContent>
        </Tabs>
      </section>

      {/* Ranking Section */}
      <section className="container mx-auto px-4 py-12">
        <div className="grid md:grid-cols-2 gap-8">
          {/* Hot Ranking */}
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle className="flex items-center gap-2">
                <Flame className="h-5 w-5 text-orange-500" />
                热销榜单
              </CardTitle>
              <Button variant="ghost" size="sm" asChild>
                <Link href="/rankings">查看更多</Link>
              </Button>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {HOT_RANKING.slice(0, 5).map((item) => (
                  <div
                    key={item.id}
                    className="flex items-center gap-4 group cursor-pointer"
                  >
                    <span
                      className={`text-2xl font-bold w-8 ${
                        item.id <= 3 ? 'text-orange-500' : 'text-muted-foreground'
                      }`}
                    >
                      {item.id}
                    </span>
                    <div className="relative h-16 w-12 rounded overflow-hidden shrink-0">
                      <Image
                        src={item.book.cover}
                        alt={item.book.title}
                        fill
                        className="object-cover"
                      />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium line-clamp-1 group-hover:text-primary transition-colors">
                        {item.book.title}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        {item.book.author.name}
                      </p>
                    </div>
                    <Badge variant="hot">热</Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Rating Ranking */}
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle className="flex items-center gap-2">
                <Star className="h-5 w-5 text-amber-500" />
                评分榜单
              </CardTitle>
              <Button variant="ghost" size="sm" asChild>
                <Link href="/rankings">查看更多</Link>
              </Button>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {HOT_RANKING.slice(0, 5).map((item, index) => (
                  <div
                    key={item.id}
                    className="flex items-center gap-4 group cursor-pointer"
                  >
                    <span
                      className={`text-2xl font-bold w-8 ${
                        index <= 2 ? 'text-amber-500' : 'text-muted-foreground'
                      }`}
                    >
                      {index + 1}
                    </span>
                    <div className="relative h-16 w-12 rounded overflow-hidden shrink-0">
                      <Image
                        src={item.book.cover}
                        alt={item.book.title}
                        fill
                        className="object-cover"
                      />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium line-clamp-1 group-hover:text-primary transition-colors">
                        {item.book.title}
                      </p>
                      <div className="flex items-center gap-2 text-sm">
                        <Star className="h-3 w-3 text-amber-500 fill-current" />
                        <span className="text-amber-500">{item.book.rating}</span>
                      </div>
                    </div>
                    <Badge variant="default">高分</Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* VIP Banner */}
      <section className="container mx-auto px-4 py-12">
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-amber-500 via-orange-500 to-amber-500 p-8 text-white">
          <div className="absolute inset-0 bg-[url('/images/pattern.png')] opacity-10" />
          <div className="relative grid md:grid-cols-2 gap-8 items-center">
            <div>
              <div className="inline-flex items-center gap-2 rounded-full bg-white/20 px-4 py-1 text-sm mb-4">
                <Crown className="h-4 w-4" />
                VIP会员
              </div>
              <h3 className="text-3xl font-bold mb-4">尊享会员特权</h3>
              <p className="text-white/80 mb-6">
                成为VIP会员，享受免费阅读、抢先更新、无广告干扰等特权，开启极致阅读体验。
              </p>
              <div className="flex gap-4">
                <Button
                  variant="secondary"
                  size="lg"
                  className="bg-white text-orange-600 hover:bg-white/90"
                  asChild
                >
                  <Link href="/vip">立即开通</Link>
                </Button>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {[
                { icon: '📚', title: '免费阅读', desc: 'VIP书籍免费读' },
                { icon: '⚡', title: '抢先看', desc: '最新章节提前读' },
                { icon: '🎁', title: '专属书单', desc: '创建私人收藏' },
                { icon: '💎', title: '无广告', desc: '清爽阅读体验' },
              ].map((benefit) => (
                <div
                  key={benefit.title}
                  className="bg-white/10 backdrop-blur rounded-xl p-4"
                >
                  <span className="text-2xl">{benefit.icon}</span>
                  <p className="font-medium mt-2">{benefit.title}</p>
                  <p className="text-sm text-white/70">{benefit.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
