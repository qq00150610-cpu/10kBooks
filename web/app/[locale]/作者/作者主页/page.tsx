'use client';

import * as React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { Pagination } from '@/components/ui/Pagination';
import { Avatar } from '@/components/ui/Avatar';
import { useAuthStore } from '@/lib/store';
import {
  BookOpen,
  Plus,
  Edit3,
  TrendingUp,
  Eye,
  PenTool,
  DollarSign,
  Users,
  FileText,
  Star,
  ArrowUp,
  ArrowDown,
  MoreVertical,
  Settings,
  Trash2,
} from 'lucide-react';
import { formatNumber, formatDate, formatWordCount, formatCurrency, cn } from '@/lib/utils';

const MOCK_STATS = {
  totalWords: 8560000,
  totalViews: 125600000,
  totalEarnings: 125680.5,
  pendingEarnings: 5680.5,
  totalBooks: 5,
  totalChapters: 150,
  subscribers: 125000,
  rating: 4.8,
};

const MOCK_BOOKS = [
  {
    id: '1',
    title: '仙武帝尊',
    cover: 'https://picsum.photos/seed/book1/300/400',
    status: 'completed',
    wordCount: 8560000,
    viewCount: 125600000,
    subscribers: 125000,
    rating: 4.8,
    chapters: 150,
    lastUpdated: '2024-01-20',
    earnings: 56800,
    isRecommended: true,
  },
  {
    id: '2',
    title: '神墓传奇',
    cover: 'https://picsum.photos/seed/book2/300/400',
    status: 'ongoing',
    wordCount: 3200000,
    viewCount: 45600000,
    subscribers: 45000,
    rating: 4.6,
    chapters: 89,
    lastUpdated: '2024-01-21',
    earnings: 12500,
    isRecommended: false,
  },
  {
    id: '3',
    title: '天帝传',
    cover: 'https://picsum.photos/seed/book3/300/400',
    status: 'paused',
    wordCount: 1560000,
    viewCount: 23000000,
    subscribers: 23000,
    rating: 4.5,
    chapters: 45,
    lastUpdated: '2023-12-15',
    earnings: 6800,
    isRecommended: false,
  },
];

export default function AuthorDashboardPage() {
  const router = useRouter();
  const { user, isAuthenticated } = useAuthStore();

  if (!isAuthenticated || user?.role !== 'author') {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center max-w-md">
          <PenTool className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
          <h2 className="text-xl font-bold mb-2">作者中心</h2>
          <p className="text-muted-foreground mb-4">
            加入作者行列，开始创作你的故事
          </p>
          <Button asChild>
            <Link href="/author/join">申请成为作者</Link>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-muted/30">
      {/* Header */}
      <div className="bg-gradient-to-r from-primary to-secondary text-white">
        <div className="container mx-auto px-4 py-8">
          <div className="flex items-center gap-6">
            <Avatar src={user.avatar} alt={user.username} size="xl" />
            <div className="flex-1">
              <div className="flex items-center gap-3">
                <h1 className="text-2xl font-bold">{user.username}</h1>
                <Badge variant="secondary">签约作者</Badge>
              </div>
              <p className="text-white/70 mt-1">创作你的世界</p>
            </div>
            <Button variant="secondary" asChild>
              <Link href="/author/join">
                <Plus className="h-4 w-4 mr-2" />
                新建作品
              </Link>
            </Button>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-4 mb-8">
          <Card>
            <CardContent className="p-4 text-center">
              <TrendingUp className="h-8 w-8 text-primary mx-auto mb-2" />
              <p className="text-2xl font-bold">{formatCurrency(MOCK_STATS.pendingEarnings)}</p>
              <p className="text-sm text-muted-foreground">待结算收益</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <DollarSign className="h-8 w-8 text-green-500 mx-auto mb-2" />
              <p className="text-2xl font-bold">{formatCurrency(MOCK_STATS.totalEarnings)}</p>
              <p className="text-sm text-muted-foreground">总收入</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <Eye className="h-8 w-8 text-blue-500 mx-auto mb-2" />
              <p className="text-2xl font-bold">{formatNumber(MOCK_STATS.totalViews)}</p>
              <p className="text-sm text-muted-foreground">总阅读</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <Users className="h-8 w-8 text-purple-500 mx-auto mb-2" />
              <p className="text-2xl font-bold">{formatNumber(MOCK_STATS.subscribers)}</p>
              <p className="text-sm text-muted-foreground">总订阅</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <Star className="h-8 w-8 text-amber-500 mx-auto mb-2" />
              <p className="text-2xl font-bold">{MOCK_STATS.rating}</p>
              <p className="text-sm text-muted-foreground">作者评分</p>
            </CardContent>
          </Card>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* My Books */}
            <Card>
              <CardHeader className="flex flex-row items-center justify-between">
                <CardTitle>我的作品</CardTitle>
                <Button asChild>
                  <Link href="/author/new-book">
                    <Plus className="h-4 w-4 mr-2" />
                    新建作品
                  </Link>
                </Button>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {MOCK_BOOKS.map((book) => (
                    <div
                      key={book.id}
                      className="flex gap-4 p-4 rounded-lg border hover:bg-accent/50 transition-colors"
                    >
                      <Link href={`/book/${book.id}`}>
                        <div className="relative w-20 h-28 rounded overflow-hidden shrink-0">
                          <Image
                            src={book.cover}
                            alt={book.title}
                            fill
                            className="object-cover"
                          />
                        </div>
                      </Link>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between">
                          <div>
                            <Link
                              href={`/book/${book.id}`}
                              className="font-semibold hover:text-primary transition-colors"
                            >
                              {book.title}
                            </Link>
                            <div className="flex items-center gap-2 mt-1">
                              <Badge
                                variant={
                                  book.status === 'completed'
                                    ? 'success'
                                    : book.status === 'ongoing'
                                    ? 'default'
                                    : 'secondary'
                                }
                              >
                                {book.status === 'completed'
                                  ? '已完结'
                                  : book.status === 'ongoing'
                                  ? '连载中'
                                  : '暂停'}
                              </Badge>
                              {book.isRecommended && <Badge variant="premium">推荐</Badge>}
                            </div>
                          </div>
                          <Button variant="ghost" size="icon">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </div>
                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-3">
                          <div>
                            <p className="text-xs text-muted-foreground">字数</p>
                            <p className="font-medium">{formatWordCount(book.wordCount)}</p>
                          </div>
                          <div>
                            <p className="text-xs text-muted-foreground">章节</p>
                            <p className="font-medium">{book.chapters}章</p>
                          </div>
                          <div>
                            <p className="text-xs text-muted-foreground">订阅</p>
                            <p className="font-medium">{formatNumber(book.subscribers)}</p>
                          </div>
                          <div>
                            <p className="text-xs text-muted-foreground">收益</p>
                            <p className="font-medium text-green-600">
                              {formatCurrency(book.earnings)}
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center gap-4 mt-3">
                          <Button size="sm" asChild>
                            <Link href={`/author/chapter-editor/${book.id}/new`}>
                              <Edit3 className="h-3 w-3 mr-1" />
                              写章节
                            </Link>
                          </Button>
                          <Button size="sm" variant="outline" asChild>
                            <Link href={`/author/book/${book.id}/stats`}>数据</Link>
                          </Button>
                          <span className="text-xs text-muted-foreground ml-auto">
                            更新于 {formatDate(book.lastUpdated)}
                          </span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Quick Actions */}
            <Card>
              <CardHeader>
                <CardTitle>快捷操作</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  {[
                    { icon: Plus, label: '新建作品', href: '/author/new-book' },
                    { icon: Edit3, label: '写章节', href: '/author/chapter-editor' },
                    { icon: TrendingUp, label: '数据统计', href: '/author/statistics' },
                    { icon: DollarSign, label: '收益提现', href: '/author/withdrawal' },
                  ].map((action) => {
                    const Icon = action.icon;
                    return (
                      <Button
                        key={action.label}
                        variant="outline"
                        className="h-20 flex-col gap-2"
                        asChild
                      >
                        <Link href={action.href}>
                          <Icon className="h-6 w-6" />
                          <span className="text-sm">{action.label}</span>
                        </Link>
                      </Button>
                    );
                  })}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Notice */}
            <Card className="border-l-4 border-l-primary">
              <CardHeader>
                <CardTitle className="text-base">平台公告</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {[
                    { title: '2024年作者分成比例调整通知', time: '2024-01-15' },
                    { title: '新增AI写作助手功能', time: '2024-01-10' },
                    { title: '春节活动奖励公告', time: '2024-01-05' },
                  ].map((notice, index) => (
                    <Link
                      key={index}
                      href={`/notice/${index + 1}`}
                      className="block py-2 hover:text-primary transition-colors"
                    >
                      <p className="text-sm line-clamp-1">{notice.title}</p>
                      <p className="text-xs text-muted-foreground">{notice.time}</p>
                    </Link>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Author Level */}
            <Card>
              <CardHeader>
                <CardTitle className="text-base">作者等级</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-center">
                  <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-primary to-secondary text-white text-2xl font-bold mb-4">
                    Lv.4
                  </div>
                  <p className="font-medium">白金作者</p>
                  <div className="mt-4">
                    <div className="flex justify-between text-xs mb-1">
                      <span>距离下一等级</span>
                      <span>50%</span>
                    </div>
                    <div className="h-2 bg-muted rounded-full overflow-hidden">
                      <div className="h-full bg-primary" style={{ width: '75%' }} />
                    </div>
                    <p className="text-xs text-muted-foreground mt-2">
                      再创作 50万字 即可升级
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Recent Earnings */}
            <Card>
              <CardHeader className="flex flex-row items-center justify-between">
                <CardTitle className="text-base">近期收益</CardTitle>
                <Button variant="ghost" size="sm" asChild>
                  <Link href="/author/earnings">详情</Link>
                </Button>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {[
                    { date: '01-21', amount: 1250.5, trend: 'up' },
                    { date: '01-20', amount: 980.3, trend: 'up' },
                    { date: '01-19', amount: 1150.8, trend: 'down' },
                    { date: '01-18', amount: 1320.2, trend: 'up' },
                  ].map((item, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between py-2 border-b last:border-0"
                    >
                      <div className="flex items-center gap-2">
                        <span className="text-sm text-muted-foreground">
                          {item.date}
                        </span>
                        {item.trend === 'up' ? (
                          <ArrowUp className="h-3 w-3 text-green-500" />
                        ) : (
                          <ArrowDown className="h-3 w-3 text-red-500" />
                        )}
                      </div>
                      <span className="font-medium text-green-600">
                        +{formatCurrency(item.amount)}
                      </span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
