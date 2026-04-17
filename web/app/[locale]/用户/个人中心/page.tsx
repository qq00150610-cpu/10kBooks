'use client';

import * as React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { useAuthStore, useBookshelfStore } from '@/lib/store';
import {
  Settings,
  User,
  Shield,
  Bell,
  Key,
  Smartphone,
  Mail,
  Heart,
  BookOpen,
  History,
  Bookmark,
  MessageSquare,
  CreditCard,
  Crown,
  PenTool,
  ChevronRight,
  Edit3,
  Camera,
} from 'lucide-react';
import { formatNumber } from '@/lib/utils';

const MENU_ITEMS = [
  {
    title: '账号设置',
    items: [
      { icon: User, label: '个人信息', href: '/profile/edit' },
      { icon: Shield, label: '账号安全', href: '/profile/security' },
      { icon: Smartphone, label: '绑定手机', href: '/profile/phone' },
      { icon: Mail, label: '绑定邮箱', href: '/profile/email' },
      { icon: Bell, label: '消息通知', href: '/profile/notifications' },
    ],
  },
  {
    title: '阅读相关',
    items: [
      { icon: BookOpen, label: '我的书架', href: '/bookshelf' },
      { icon: History, label: '阅读历史', href: '/history' },
      { icon: Bookmark, label: '我的书签', href: '/bookmarks' },
      { icon: Heart, label: '我的收藏', href: '/favorites' },
      { icon: MessageSquare, label: '我的评论', href: '/comments' },
    ],
  },
  {
    title: '消费相关',
    items: [
      { icon: Crown, label: '会员中心', href: '/vip' },
      { icon: CreditCard, label: '充值记录', href: '/recharge' },
      { icon: History, label: '消费记录', href: '/consumption' },
    ],
  },
];

export default function ProfilePage() {
  const { user, isAuthenticated } = useAuthStore();
  const { books } = useBookshelfStore();

  if (!isAuthenticated || !user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <p className="text-muted-foreground mb-4">请先登录</p>
          <Button asChild>
            <Link href="/login">去登录</Link>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-muted/30">
      {/* Header */}
      <div className="bg-gradient-to-r from-primary to-secondary">
        <div className="container mx-auto px-4 py-8">
          <div className="flex items-center gap-6">
            <div className="relative">
              <Avatar src={user.avatar} alt={user.username} size="xl" />
              <button className="absolute bottom-0 right-0 p-1.5 bg-background rounded-full shadow-lg hover:bg-accent transition-colors">
                <Camera className="h-4 w-4" />
              </button>
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-3">
                <h1 className="text-2xl font-bold text-white">{user.username}</h1>
                {user.vipLevel > 0 && (
                  <Badge variant="premium">
                    <Crown className="h-3 w-3 mr-1" />
                    VIP
                  </Badge>
                )}
              </div>
              <p className="text-white/70 mt-1">{user.email}</p>
              <div className="flex gap-6 mt-3">
                <div className="text-center">
                  <p className="text-xl font-bold text-white">{formatNumber(user.stats.followers)}</p>
                  <p className="text-sm text-white/70">关注</p>
                </div>
                <div className="text-center">
                  <p className="text-xl font-bold text-white">{formatNumber(user.stats.following)}</p>
                  <p className="text-sm text-white/70">粉丝</p>
                </div>
                <div className="text-center">
                  <p className="text-xl font-bold text-white">{books.length}</p>
                  <p className="text-sm text-white/70">书架</p>
                </div>
              </div>
            </div>
            <Button variant="secondary" asChild>
              <Link href="/profile/edit">
                <Edit3 className="h-4 w-4 mr-2" />
                编辑资料
              </Link>
            </Button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-4 gap-8">
          {/* Sidebar */}
          <div className="lg:col-span-1">
            <Card>
              <CardContent className="p-4">
                <nav className="space-y-6">
                  {MENU_ITEMS.map((section) => (
                    <div key={section.title}>
                      <h3 className="text-sm font-medium text-muted-foreground mb-2">
                        {section.title}
                      </h3>
                      <div className="space-y-1">
                        {section.items.map((item) => {
                          const Icon = item.icon;
                          return (
                            <Link
                              key={item.href}
                              href={item.href}
                              className="flex items-center justify-between p-2 rounded-lg hover:bg-accent transition-colors group"
                            >
                              <span className="flex items-center gap-3">
                                <Icon className="h-5 w-5 text-muted-foreground group-hover:text-foreground" />
                                <span>{item.label}</span>
                              </span>
                              <ChevronRight className="h-4 w-4 text-muted-foreground group-hover:text-foreground" />
                            </Link>
                          );
                        })}
                      </div>
                    </div>
                  ))}
                </nav>
              </CardContent>
            </Card>
          </div>

          {/* Main Content */}
          <div className="lg:col-span-3 space-y-6">
            {/* Quick Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <Card>
                <CardContent className="p-4 text-center">
                  <BookOpen className="h-8 w-8 text-primary mx-auto mb-2" />
                  <p className="text-2xl font-bold">{books.length}</p>
                  <p className="text-sm text-muted-foreground">书架书籍</p>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-4 text-center">
                  <History className="h-8 w-8 text-blue-500 mx-auto mb-2" />
                  <p className="text-2xl font-bold">156</p>
                  <p className="text-sm text-muted-foreground">阅读时长</p>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-4 text-center">
                  <Heart className="h-8 w-8 text-red-500 mx-auto mb-2" />
                  <p className="text-2xl font-bold">42</p>
                  <p className="text-sm text-muted-foreground">收藏书籍</p>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="p-4 text-center">
                  <MessageSquare className="h-8 w-8 text-green-500 mx-auto mb-2" />
                  <p className="text-2xl font-bold">89</p>
                  <p className="text-sm text-muted-foreground">发表评论</p>
                </CardContent>
              </Card>
            </div>

            {/* VIP Banner */}
            {user.vipLevel === 0 && (
              <Card className="bg-gradient-to-r from-amber-500 to-orange-500 text-white border-0">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <Crown className="h-6 w-6" />
                        <h3 className="text-xl font-bold">开通VIP会员</h3>
                      </div>
                      <p className="text-white/80">
                        享受免费阅读、抢先更新、无广告等特权
                      </p>
                    </div>
                    <Button
                      variant="secondary"
                      asChild
                      className="bg-white text-orange-600 hover:bg-white/90"
                    >
                      <Link href="/vip">立即开通</Link>
                    </Button>
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Continue Reading */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center justify-between">
                  继续阅读
                  <Button variant="ghost" size="sm" asChild>
                    <Link href="/history">查看全部</Link>
                  </Button>
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                  {[1, 2, 3, 4].map((i) => (
                    <Link
                      key={i}
                      href={`/read/book-${i}/chapter-1`}
                      className="group"
                    >
                      <div className="relative aspect-[3/4] rounded-lg overflow-hidden mb-2">
                        <Image
                          src={`https://picsum.photos/seed/reading${i}/300/400`}
                          alt={`书籍${i}`}
                          fill
                          className="object-cover group-hover:scale-105 transition-transform"
                        />
                        <div className="absolute bottom-0 left-0 right-0 h-1 bg-muted">
                          <div
                            className="h-full bg-primary"
                            style={{ width: `${30 + i * 15}%` }}
                          />
                        </div>
                      </div>
                      <p className="text-sm font-medium line-clamp-1 group-hover:text-primary transition-colors">
                        书籍名称{i}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        阅读至第{10 + i}章
                      </p>
                    </Link>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Recent Activity */}
            <Card>
              <CardHeader>
                <CardTitle>最近动态</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {[
                    { action: '阅读了', book: '仙武帝尊', time: '10分钟前' },
                    { action: '收藏了', book: '都市逍遥医神', time: '1小时前' },
                    { action: '评论了', book: '庆余年', time: '3小时前' },
                    { action: '订阅了', book: '全职高手', time: '昨天' },
                  ].map((activity, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between py-2 border-b last:border-0"
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                          <BookOpen className="h-5 w-5 text-primary" />
                        </div>
                        <div>
                          <p className="text-sm">
                            <span className="text-muted-foreground">{activity.action}</span>{' '}
                            <span className="font-medium">{activity.book}</span>
                          </p>
                        </div>
                      </div>
                      <span className="text-xs text-muted-foreground">{activity.time}</span>
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
