'use client';

import * as React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { useAuthStore } from '@/lib/store';
import {
  MessageSquare,
  Heart,
  Share2,
  Bookmark,
  MoreHorizontal,
  TrendingUp,
  Users,
  Clock,
  Image as ImageIcon,
  Send,
} from 'lucide-react';
import { formatRelativeTime, cn } from '@/lib/utils';

const TRENDING_TOPICS = [
  { id: 1, title: '#斗破苍穹结局#', count: 125000 },
  { id: 2, title: '#推荐好看的玄幻小说#', count: 98000 },
  { id: 3, title: '#仙侠小说经典语录#', count: 87000 },
  { id: 4, title: '#全职高手电竞精神#', count: 76000 },
  { id: 5, title: '#都市修仙流推荐#', count: 65000 },
];

const MOCK_POSTS = [
  {
    id: '1',
    user: {
      id: '1',
      username: '书虫小明',
      avatar: 'https://picsum.photos/seed/user1/100/100',
      vipLevel: 1,
    },
    content: '刚刚看完了《仙武帝尊》最新章节，真的太精彩了！主角叶尘的成长历程让人热血沸腾，期待后续发展！有没有同好在追这本小说的？',
    images: ['https://picsum.photos/seed/post1/400/300'],
    book: { id: '1', title: '仙武帝尊' },
    likes: 234,
    comments: 45,
    shares: 12,
    isLiked: false,
    createdAt: '2024-01-21T10:30:00Z',
  },
  {
    id: '2',
    user: {
      id: '2',
      username: '阅读达人',
      avatar: 'https://picsum.photos/seed/user2/100/100',
      vipLevel: 2,
    },
    content: '今天给大家推荐几本近期看过的精品都市小说，文笔一流，剧情紧凑，绝对值得一看！\n\n1. 《都市逍遥医神》\n2. 《最强狂兵》\n3. 《一号狂兵》',
    images: [],
    book: null,
    likes: 567,
    comments: 89,
    shares: 34,
    isLiked: true,
    createdAt: '2024-01-21T08:15:00Z',
  },
  {
    id: '3',
    user: {
      id: '3',
      username: '玄幻迷',
      avatar: 'https://picsum.photos/seed/user3/100/100',
      vipLevel: 0,
    },
    content: '《庆余年》这本书真的太好看了！范闲的性格塑造得太棒了，智谋与武力并存，看得过瘾！',
    images: ['https://picsum.photos/seed/post3/400/300', 'https://picsum.photos/seed/post3b/400/300'],
    book: { id: '3', title: '庆余年' },
    likes: 1234,
    comments: 234,
    shares: 56,
    isLiked: false,
    createdAt: '2024-01-20T22:00:00Z',
  },
];

export default function CommunityPage() {
  const { user, isAuthenticated } = useAuthStore();
  const [newPost, setNewPost] = React.useState('');

  return (
    <div className="min-h-screen bg-muted/30">
      <div className="container mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Create Post */}
            <Card>
              <CardContent className="p-4">
                {isAuthenticated && user ? (
                  <div className="flex gap-3">
                    <Avatar src={user.avatar} alt={user.username} size="md" />
                    <div className="flex-1">
                      <textarea
                        value={newPost}
                        onChange={(e) => setNewPost(e.target.value)}
                        placeholder="分享你的阅读心得..."
                        rows={3}
                        className="w-full rounded-lg border bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                      />
                      <div className="flex items-center justify-between mt-3">
                        <div className="flex gap-2">
                          <Button variant="ghost" size="sm">
                            <ImageIcon className="h-4 w-4 mr-1" />
                            图片
                          </Button>
                          <Button variant="ghost" size="sm">
                            <Bookmark className="h-4 w-4 mr-1" />
                            书籍
                          </Button>
                        </div>
                        <Button size="sm" disabled={!newPost.trim()}>
                          <Send className="h-4 w-4 mr-1" />
                          发布
                        </Button>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-4">
                    <p className="text-muted-foreground mb-3">
                      登录后可发布动态
                    </p>
                    <Button asChild>
                      <Link href="/login">去登录</Link>
                    </Button>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Posts */}
            <div className="space-y-4">
              {MOCK_POSTS.map((post) => (
                <Card key={post.id}>
                  <CardContent className="p-4">
                    <div className="flex gap-3">
                      <Avatar
                        src={post.user.avatar}
                        alt={post.user.username}
                        size="md"
                      />
                      <div className="flex-1">
                        <div className="flex items-center gap-2">
                          <span className="font-medium">{post.user.username}</span>
                          {post.user.vipLevel > 0 && (
                            <Badge variant="premium" className="text-xs">
                              VIP
                            </Badge>
                          )}
                          <span className="text-xs text-muted-foreground">
                            {formatRelativeTime(post.createdAt)}
                          </span>
                        </div>

                        {/* Content */}
                        <p className="mt-2 text-sm whitespace-pre-wrap">
                          {post.content}
                        </p>

                        {/* Book Reference */}
                        {post.book && (
                          <Link
                            href={`/book/${post.book.id}`}
                            className="inline-flex items-center gap-2 mt-2 px-3 py-2 rounded-lg bg-muted/50 hover:bg-muted transition-colors"
                          >
                            <Bookmark className="h-4 w-4 text-primary" />
                            <span className="text-sm">{post.book.title}</span>
                          </Link>
                        )}

                        {/* Images */}
                        {post.images.length > 0 && (
                          <div
                            className={cn(
                              'grid gap-2 mt-3',
                              post.images.length === 1 && 'grid-cols-1',
                              post.images.length === 2 && 'grid-cols-2',
                              post.images.length >= 3 && 'grid-cols-3'
                            )}
                          >
                            {post.images.slice(0, 3).map((img, index) => (
                              <div
                                key={index}
                                className="relative aspect-video rounded-lg overflow-hidden"
                              >
                                <Image
                                  src={img}
                                  alt={`图片${index + 1}`}
                                  fill
                                  className="object-cover"
                                />
                              </div>
                            ))}
                          </div>
                        )}

                        {/* Actions */}
                        <div className="flex items-center gap-6 mt-4 pt-3 border-t">
                          <button
                            className={cn(
                              'flex items-center gap-1.5 text-sm transition-colors',
                              post.isLiked
                                ? 'text-red-500'
                                : 'text-muted-foreground hover:text-red-500'
                            )}
                          >
                            <Heart
                              className={cn('h-5 w-5', post.isLiked && 'fill-current')}
                            />
                            {post.likes}
                          </button>
                          <button className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors">
                            <MessageSquare className="h-5 w-5" />
                            {post.comments}
                          </button>
                          <button className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors">
                            <Share2 className="h-5 w-5" />
                            {post.shares}
                          </button>
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Trending Topics */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-base">
                  <TrendingUp className="h-5 w-5 text-orange-500" />
                  热门话题
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {TRENDING_TOPICS.map((topic, index) => (
                    <Link
                      key={topic.id}
                      href={`/community/topic/${topic.id}`}
                      className="block py-2 hover:text-primary transition-colors"
                    >
                      <p className="font-medium text-sm">{topic.title}</p>
                      <p className="text-xs text-muted-foreground">
                        {topic.count.toLocaleString()} 讨论
                      </p>
                    </Link>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Quick Links */}
            <Card>
              <CardHeader>
                <CardTitle className="text-base">快捷入口</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 gap-2">
                  {[
                    { icon: Users, label: '书单', href: '/community/booklists' },
                    { icon: Bookmark, label: '我的收藏', href: '/favorites' },
                    { icon: Clock, label: '阅读历史', href: '/history' },
                    { icon: MessageSquare, label: '我的评论', href: '/comments' },
                  ].map((link) => {
                    const Icon = link.icon;
                    return (
                      <Button
                        key={link.label}
                        variant="outline"
                        className="h-16 flex-col gap-1"
                        asChild
                      >
                        <Link href={link.href}>
                          <Icon className="h-5 w-5" />
                          <span className="text-xs">{link.label}</span>
                        </Link>
                      </Button>
                    );
                  })}
                </div>
              </CardContent>
            </Card>

            {/* Active Users */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-base">
                  <Users className="h-5 w-5 text-green-500" />
                  活跃书友
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {MOCK_POSTS.slice(0, 3).map((post) => (
                    <Link
                      key={post.user.id}
                      href={`/user/${post.user.id}`}
                      className="flex items-center gap-3 py-2 hover:text-primary transition-colors"
                    >
                      <Avatar
                        src={post.user.avatar}
                        alt={post.user.username}
                        size="sm"
                      />
                      <div>
                        <p className="text-sm font-medium">{post.user.username}</p>
                        <p className="text-xs text-muted-foreground">刚刚活跃</p>
                      </div>
                    </Link>
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
