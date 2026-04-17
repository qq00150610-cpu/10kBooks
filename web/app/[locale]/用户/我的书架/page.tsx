'use client';

import * as React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { Pagination } from '@/components/ui/Pagination';
import { useAuthStore, useBookshelfStore } from '@/lib/store';
import {
  BookOpen,
  Clock,
  Plus,
  Search,
  Filter,
  MoreVertical,
  Trash2,
  Eye,
} from 'lucide-react';
import { formatDate, formatRelativeTime, cn } from '@/lib/utils';

const MOCK_BOOKSHELF = [
  {
    id: '1',
    book: {
      id: '1',
      title: '仙武帝尊',
      cover: 'https://picsum.photos/seed/book1/300/400',
      author: { name: '火星引力' },
      category: '玄幻',
    },
    progress: 75,
    lastReadAt: '2024-01-20T10:00:00Z',
    addedAt: '2024-01-01T00:00:00Z',
    isSubscribed: true,
  },
  {
    id: '2',
    book: {
      id: '2',
      title: '都市逍遥医神',
      cover: 'https://picsum.photos/seed/book2/300/400',
      author: { name: '疯狂小马甲' },
      category: '都市',
    },
    progress: 45,
    lastReadAt: '2024-01-19T15:30:00Z',
    addedAt: '2024-01-05T00:00:00Z',
    isSubscribed: false,
  },
  {
    id: '3',
    book: {
      id: '3',
      title: '庆余年',
      cover: 'https://picsum.photos/seed/book3/300/400',
      author: { name: '猫腻' },
      category: '历史',
    },
    progress: 100,
    lastReadAt: '2024-01-15T20:00:00Z',
    addedAt: '2023-12-01T00:00:00Z',
    isSubscribed: true,
  },
  {
    id: '4',
    book: {
      id: '4',
      title: '全职高手',
      cover: 'https://picsum.photos/seed/book4/300/400',
      author: { name: '蝴蝶蓝' },
      category: '游戏',
    },
    progress: 30,
    lastReadAt: '2024-01-18T09:00:00Z',
    addedAt: '2024-01-10T00:00:00Z',
    isSubscribed: false,
  },
  {
    id: '5',
    book: {
      id: '5',
      title: '凡人修仙传',
      cover: 'https://picsum.photos/seed/book5/300/400',
      author: { name: '忘语' },
      category: '仙侠',
    },
    progress: 60,
    lastReadAt: '2024-01-17T14:00:00Z',
    addedAt: '2023-11-15T00:00:00Z',
    isSubscribed: true,
  },
  {
    id: '6',
    book: {
      id: '6',
      title: '雪中悍刀行',
      cover: 'https://picsum.photos/seed/book6/300/400',
      author: { name: '烽火戏诸侯' },
      category: '武侠',
    },
    progress: 20,
    lastReadAt: '2024-01-16T11:00:00Z',
    addedAt: '2024-01-08T00:00:00Z',
    isSubscribed: false,
  },
];

export default function BookshelfPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();
  const { books, removeBook } = useBookshelfStore();

  const [viewMode, setViewMode] = React.useState<'grid' | 'list'>('grid');
  const [searchQuery, setSearchQuery] = React.useState('');
  const [sortBy, setSortBy] = React.useState<'recent' | 'progress' | 'added'>('recent');
  const [currentPage, setCurrentPage] = React.useState(1);
  const pageSize = 12;

  const filteredBooks = MOCK_BOOKSHELF.filter((item) =>
    item.book.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const sortedBooks = [...filteredBooks].sort((a, b) => {
    if (sortBy === 'recent') {
      return new Date(b.lastReadAt).getTime() - new Date(a.lastReadAt).getTime();
    }
    if (sortBy === 'progress') {
      return b.progress - a.progress;
    }
    return new Date(b.addedAt).getTime() - new Date(a.addedAt).getTime();
  });

  const paginatedBooks = sortedBooks.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

  const handleRead = (bookId: string, chapterId = 'chapter-1') => {
    router.push(`/read/${bookId}/${chapterId}`);
  };

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <BookOpen className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
          <p className="text-muted-foreground mb-4">登录后查看您的书架</p>
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
      <div className="bg-background border-b">
        <div className="container mx-auto px-4 py-6">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-2xl font-bold">我的书架</h1>
              <p className="text-sm text-muted-foreground">共 {MOCK_BOOKSHELF.length} 本书籍</p>
            </div>
            <Button asChild>
              <Link href="/category">
                <Plus className="h-4 w-4 mr-2" />
                添加书籍
              </Link>
            </Button>
          </div>

          {/* Filters */}
          <div className="flex flex-wrap items-center gap-4">
            <div className="flex-1 min-w-[200px] max-w-md">
              <Input
                placeholder="搜索书架..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                leftIcon={<Search className="h-5 w-5" />}
              />
            </div>
            <div className="flex items-center gap-2">
              <span className="text-sm text-muted-foreground">排序：</span>
              <Tabs
                defaultValue="recent"
                onValueChange={(v) => setSortBy(v as any)}
              >
                <TabsList className="h-9">
                  <TabsTrigger value="recent" className="text-xs px-3">
                    最近阅读
                  </TabsTrigger>
                  <TabsTrigger value="progress" className="text-xs px-3">
                    阅读进度
                  </TabsTrigger>
                  <TabsTrigger value="added" className="text-xs px-3">
                    添加时间
                  </TabsTrigger>
                </TabsList>
              </Tabs>
            </div>
            <div className="flex items-center gap-1 border rounded-lg p-1">
              <button
                onClick={() => setViewMode('grid')}
                className={cn(
                  'p-1.5 rounded',
                  viewMode === 'grid' ? 'bg-accent' : 'hover:bg-accent'
                )}
              >
                <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
                </svg>
              </button>
              <button
                onClick={() => setViewMode('list')}
                className={cn(
                  'p-1.5 rounded',
                  viewMode === 'list' ? 'bg-accent' : 'hover:bg-accent'
                )}
              >
                <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 10h16M4 14h16M4 18h16" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="container mx-auto px-4 py-8">
        {paginatedBooks.length === 0 ? (
          <div className="text-center py-16">
            <BookOpen className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
            <h3 className="text-lg font-medium mb-2">书架空空如也</h3>
            <p className="text-muted-foreground mb-4">去分类浏览，添加喜欢的书籍吧</p>
            <Button asChild>
              <Link href="/category">浏览书籍</Link>
            </Button>
          </div>
        ) : viewMode === 'grid' ? (
          <>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
              {paginatedBooks.map((item) => (
                <Link
                  key={item.id}
                  href={`/book/${item.book.id}`}
                  className="group"
                >
                  <Card hover className="overflow-hidden">
                    <div className="relative aspect-[3/4]">
                      <Image
                        src={item.book.cover}
                        alt={item.book.title}
                        fill
                        className="object-cover"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
                      <div className="absolute bottom-0 left-0 right-0 p-3">
                        <div className="h-1 bg-white/30 rounded-full overflow-hidden">
                          <div
                            className="h-full bg-primary transition-all"
                            style={{ width: `${item.progress}%` }}
                          />
                        </div>
                        <p className="text-white text-xs mt-1">{item.progress}%</p>
                      </div>
                      {item.isSubscribed && (
                        <Badge className="absolute top-2 right-2" variant="premium">
                          订阅
                        </Badge>
                      )}
                    </div>
                    <CardContent className="p-3">
                      <h3 className="font-medium text-sm line-clamp-1 group-hover:text-primary transition-colors">
                        {item.book.title}
                      </h3>
                      <p className="text-xs text-muted-foreground mt-1">
                        {item.book.author.name}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {formatRelativeTime(item.lastReadAt)}
                      </p>
                    </CardContent>
                  </Card>
                </Link>
              ))}
            </div>
          </>
        ) : (
          <div className="space-y-4">
            {paginatedBooks.map((item) => (
              <Card key={item.id} hover>
                <CardContent className="p-4">
                  <div className="flex gap-4">
                    <Link href={`/book/${item.book.id}`} className="shrink-0">
                      <div className="relative w-20 h-28 rounded-lg overflow-hidden">
                        <Image
                          src={item.book.cover}
                          alt={item.book.title}
                          fill
                          className="object-cover"
                        />
                      </div>
                    </Link>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between">
                        <div>
                          <Link
                            href={`/book/${item.book.id}`}
                            className="font-medium hover:text-primary transition-colors"
                          >
                            {item.book.title}
                          </Link>
                          <p className="text-sm text-muted-foreground mt-1">
                            {item.book.author.name} · {item.book.category}
                          </p>
                        </div>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => removeBook(item.book.id)}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                      <div className="mt-4">
                        <div className="flex items-center justify-between text-sm mb-1">
                          <span className="text-muted-foreground">阅读进度</span>
                          <span className="font-medium">{item.progress}%</span>
                        </div>
                        <div className="h-2 bg-muted rounded-full overflow-hidden">
                          <div
                            className="h-full bg-primary transition-all"
                            style={{ width: `${item.progress}%` }}
                          />
                        </div>
                      </div>
                      <div className="mt-3 flex items-center gap-3">
                        <Button
                          size="sm"
                          onClick={() => handleRead(item.book.id)}
                        >
                          {item.progress > 0 ? '继续阅读' : '开始阅读'}
                        </Button>
                        <span className="text-xs text-muted-foreground">
                          最后阅读: {formatRelativeTime(item.lastReadAt)}
                        </span>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {/* Pagination */}
        {sortedBooks.length > pageSize && (
          <div className="mt-8 flex justify-center">
            <Pagination
              currentPage={currentPage}
              totalPages={Math.ceil(sortedBooks.length / pageSize)}
              onPageChange={setCurrentPage}
            />
          </div>
        )}
      </div>
    </div>
  );
}
