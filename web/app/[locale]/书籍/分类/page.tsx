'use client';

import * as React from 'react';
import Link from 'next/link';
import { useParams, useSearchParams } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Pagination } from '@/components/ui/Pagination';
import { BookCard } from '@/components/common/BookCard';
import { BOOK_CATEGORIES, BOOK_STATUSES, SORT_OPTIONS } from '@/lib/constants';
import {
  Search,
  Filter,
  Grid3X3,
  List,
  ChevronRight,
  TrendingUp,
  Clock,
  Eye,
  Star,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import type { Book } from '@/lib/types';

// Mock data
const MOCK_BOOKS: Book[] = Array.from({ length: 50 }, (_, i) => ({
  id: `book-${i + 1}`,
  title: `书籍标题${i + 1}`,
  cover: `https://picsum.photos/seed/book${i + 1}/300/400`,
  author: {
    id: `author-${(i % 10) + 1}`,
    name: `作者${(i % 10) + 1}`,
    avatar: '',
  },
  category: BOOK_CATEGORIES[i % BOOK_CATEGORIES.length].name,
  tags: ['热门', '推荐'],
  description: '这是一本非常精彩的小说，讲述了...',
  status: BOOK_STATUSES[i % 3].value as 'ongoing' | 'completed' | 'paused',
  wordCount: 1000000 + Math.floor(Math.random() * 5000000),
  viewCount: Math.floor(Math.random() * 100000000),
  likeCount: Math.floor(Math.random() * 1000000),
  commentCount: Math.floor(Math.random() * 50000),
  subscribeCount: Math.floor(Math.random() * 100000),
  rating: 3.5 + Math.random() * 1.5,
  ratingCount: Math.floor(Math.random() * 100000),
  chapters: [],
  createdAt: '2020-01-01',
  updatedAt: '2024-01-15',
  isVip: i % 3 === 0,
  isPaid: false,
  freeChapterCount: 10,
}));

export default function CategoryPage() {
  const params = useParams();
  const searchParams = useSearchParams();
  
  const currentCategory = params.category as string | undefined;
  
  const [viewMode, setViewMode] = React.useState<'grid' | 'list'>('grid');
  const [sortBy, setSortBy] = React.useState('rating');
  const [statusFilter, setStatusFilter] = React.useState<string | null>(null);
  const [vipFilter, setVipFilter] = React.useState(false);
  const [searchQuery, setSearchQuery] = React.useState('');
  const [currentPage, setCurrentPage] = React.useState(1);
  const [showFilters, setShowFilters] = React.useState(false);
  
  const pageSize = 24;

  const filteredBooks = MOCK_BOOKS.filter((book) => {
    if (currentCategory) {
      const category = BOOK_CATEGORIES.find((c) => c.id === currentCategory);
      if (category && book.category !== category.name) return false;
    }
    if (statusFilter && book.status !== statusFilter) return false;
    if (vipFilter && !book.isVip) return false;
    if (searchQuery && !book.title.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    return true;
  });

  const sortedBooks = [...filteredBooks].sort((a, b) => {
    switch (sortBy) {
      case 'rating':
        return b.rating - a.rating;
      case 'views':
        return b.viewCount - a.viewCount;
      case 'updated':
        return new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime();
      case 'newest':
        return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
      default:
        return 0;
    }
  });

  const paginatedBooks = sortedBooks.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

  const currentCategoryInfo = currentCategory
    ? BOOK_CATEGORIES.find((c) => c.id === currentCategory)
    : null;

  return (
    <div className="min-h-screen bg-muted/30">
      {/* Header */}
      <div className="bg-gradient-to-r from-primary/10 to-secondary/10">
        <div className="container mx-auto px-4 py-8">
          <h1 className="text-3xl font-bold mb-2">
            {currentCategoryInfo ? currentCategoryInfo.name : '全部分类'}
          </h1>
          <p className="text-muted-foreground">
            {currentCategoryInfo ? currentCategoryInfo.nameEn : 'Browse all categories'}
          </p>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-4 gap-8">
          {/* Sidebar - Categories */}
          <div className="lg:col-span-1">
            <Card>
              <CardHeader>
                <CardTitle className="text-base">分类</CardTitle>
              </CardHeader>
              <CardContent className="p-0">
                <nav className="space-y-1">
                  <Link
                    href="/category"
                    className={cn(
                      'flex items-center justify-between px-4 py-2.5 hover:bg-accent transition-colors',
                      !currentCategory && 'bg-accent'
                    )}
                  >
                    <span className="flex items-center gap-3">
                      <span className="text-xl">📚</span>
                      <span>全部分类</span>
                    </span>
                    <ChevronRight className="h-4 w-4 text-muted-foreground" />
                  </Link>
                  {BOOK_CATEGORIES.map((category) => (
                    <Link
                      key={category.id}
                      href={`/category/${category.id}`}
                      className={cn(
                        'flex items-center justify-between px-4 py-2.5 hover:bg-accent transition-colors',
                        currentCategory === category.id && 'bg-accent'
                      )}
                    >
                      <span className="flex items-center gap-3">
                        <span className="text-xl">{category.icon}</span>
                        <span>{category.name}</span>
                      </span>
                      <ChevronRight className="h-4 w-4 text-muted-foreground" />
                    </Link>
                  ))}
                </nav>
              </CardContent>
            </Card>

            {/* Sub Categories */}
            {currentCategoryInfo?.subCategories && (
              <Card className="mt-4">
                <CardHeader>
                  <CardTitle className="text-base">子分类</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex flex-wrap gap-2">
                    {currentCategoryInfo.subCategories.map((sub) => (
                      <Badge key={sub} variant="outline" className="cursor-pointer hover:bg-accent">
                        {sub}
                      </Badge>
                    ))}
                  </div>
                </CardContent>
              </Card>
            )}
          </div>

          {/* Main Content */}
          <div className="lg:col-span-3 space-y-6">
            {/* Filters */}
            <Card>
              <CardContent className="p-4">
                <div className="flex flex-wrap items-center gap-4">
                  {/* Search */}
                  <div className="flex-1 min-w-[200px]">
                    <Input
                      placeholder="搜索书籍..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      leftIcon={<Search className="h-5 w-5" />}
                    />
                  </div>

                  {/* Status Filter */}
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-muted-foreground">状态：</span>
                    <Button
                      variant={statusFilter === null ? 'default' : 'outline'}
                      size="sm"
                      onClick={() => setStatusFilter(null)}
                    >
                      全部
                    </Button>
                    {BOOK_STATUSES.map((status) => (
                      <Button
                        key={status.value}
                        variant={statusFilter === status.value ? 'default' : 'outline'}
                        size="sm"
                        onClick={() => setStatusFilter(status.value)}
                      >
                        {status.label}
                      </Button>
                    ))}
                  </div>

                  {/* Sort */}
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-muted-foreground">排序：</span>
                    <select
                      value={sortBy}
                      onChange={(e) => setSortBy(e.target.value)}
                      className="h-9 rounded-lg border bg-background px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                    >
                      {SORT_OPTIONS.map((option) => (
                        <option key={option.value} value={option.value}>
                          {option.label}
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* View Mode */}
                  <div className="flex items-center gap-1 border rounded-lg p-1">
                    <button
                      onClick={() => setViewMode('grid')}
                      className={cn(
                        'p-1.5 rounded',
                        viewMode === 'grid' ? 'bg-accent' : 'hover:bg-accent'
                      )}
                    >
                      <Grid3X3 className="h-5 w-5" />
                    </button>
                    <button
                      onClick={() => setViewMode('list')}
                      className={cn(
                        'p-1.5 rounded',
                        viewMode === 'list' ? 'bg-accent' : 'hover:bg-accent'
                      )}
                    >
                      <List className="h-5 w-5" />
                    </button>
                  </div>

                  {/* VIP Filter */}
                  <Button
                    variant={vipFilter ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setVipFilter(!vipFilter)}
                  >
                    VIP书籍
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Results */}
            <div className="flex items-center justify-between">
              <p className="text-sm text-muted-foreground">
                共找到 <span className="font-medium text-foreground">{sortedBooks.length}</span> 本书籍
              </p>
            </div>

            {/* Books Grid/List */}
            {paginatedBooks.length === 0 ? (
              <div className="text-center py-16">
                <Search className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
                <h3 className="text-lg font-medium mb-2">未找到相关书籍</h3>
                <p className="text-muted-foreground">试试其他筛选条件</p>
              </div>
            ) : viewMode === 'grid' ? (
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                {paginatedBooks.map((book) => (
                  <BookCard key={book.id} book={book} />
                ))}
              </div>
            ) : (
              <div className="space-y-4">
                {paginatedBooks.map((book) => (
                  <BookCard key={book.id} book={book} variant="horizontal" />
                ))}
              </div>
            )}

            {/* Pagination */}
            {sortedBooks.length > pageSize && (
              <div className="flex justify-center mt-8">
                <Pagination
                  currentPage={currentPage}
                  totalPages={Math.ceil(sortedBooks.length / pageSize)}
                  onPageChange={setCurrentPage}
                />
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
