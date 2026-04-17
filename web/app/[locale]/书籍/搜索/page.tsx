'use client';

import * as React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useSearchParams } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Pagination } from '@/components/ui/Pagination';
import { BookCard } from '@/components/common/BookCard';
import { useSearchStore } from '@/lib/store';
import {
  Search,
  TrendingUp,
  Clock,
  X,
  Filter,
  ArrowRight,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import type { Book } from '@/lib/types';

const HOT_SEARCH = [
  { id: 1, keyword: '斗破苍穹', heat: 9800, trend: 'up' },
  { id: 2, keyword: '庆余年', heat: 9600, trend: 'up' },
  { id: 3, keyword: '凡人修仙传', heat: 9400, trend: 'down' },
  { id: 4, keyword: '全职高手', heat: 9200, trend: 'same' },
  { id: 5, keyword: '雪中悍刀行', heat: 9000, trend: 'up' },
  { id: 6, keyword: '仙武帝尊', heat: 8800, trend: 'up' },
  { id: 7, keyword: '都市逍遥医神', heat: 8600, trend: 'down' },
  { id: 8, keyword: '大主宰', heat: 8400, trend: 'same' },
  { id: 9, keyword: '完美世界', heat: 8200, trend: 'up' },
  { id: 10, keyword: '斗罗大陆', heat: 8000, trend: 'down' },
];

const MOCK_BOOKS: Book[] = Array.from({ length: 20 }, (_, i) => ({
  id: `book-${i + 1}`,
  title: `${['玄幻', '都市', '仙侠', '历史'][i % 4]}大作${i + 1}`,
  cover: `https://picsum.photos/seed/search${i + 1}/300/400`,
  author: {
    id: `author-${i + 1}`,
    name: `知名作者${i + 1}`,
    avatar: '',
  },
  category: ['玄幻', '都市', '仙侠', '历史'][i % 4],
  tags: ['热门', '推荐'],
  description: '精彩绝伦的小说作品，深受读者喜爱...',
  status: 'ongoing' as const,
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

export default function SearchPage() {
  const searchParams = useSearchParams();
  const initialQuery = searchParams.get('q') || '';
  
  const { recentSearches, addRecentSearch, clearRecentSearches } = useSearchStore();

  const [searchQuery, setSearchQuery] = React.useState(initialQuery);
  const [results, setResults] = React.useState<Book[]>([]);
  const [isSearching, setIsSearching] = React.useState(false);
  const [hasSearched, setHasSearched] = React.useState(false);
  const [currentPage, setCurrentPage] = React.useState(1);
  const pageSize = 12;

  React.useEffect(() => {
    if (initialQuery) {
      handleSearch(initialQuery);
    }
  }, [initialQuery]);

  const handleSearch = async (query?: string) => {
    const searchTerm = query || searchQuery;
    if (!searchTerm.trim()) return;

    setIsSearching(true);
    setHasSearched(true);
    addRecentSearch(searchTerm);

    // Mock search
    await new Promise((resolve) => setTimeout(resolve, 500));
    
    const filtered = MOCK_BOOKS.filter(
      (book) =>
        book.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        book.author.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
    
    setResults(filtered.length > 0 ? filtered : MOCK_BOOKS.slice(0, 10));
    setIsSearching(false);
  };

  const handleClearHistory = () => {
    clearRecentSearches();
  };

  const paginatedResults = results.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

  return (
    <div className="min-h-screen bg-muted/30">
      {/* Search Header */}
      <div className="bg-background border-b">
        <div className="container mx-auto px-4 py-6">
          <div className="flex gap-4">
            <div className="flex-1 max-w-2xl">
              <form
                onSubmit={(e) => {
                  e.preventDefault();
                  handleSearch();
                }}
              >
                <div className="relative">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="搜索书名、作者..."
                    className="w-full h-12 pl-12 pr-12 rounded-xl border bg-background focus:outline-none focus:ring-2 focus:ring-primary"
                    autoFocus
                  />
                  {searchQuery && (
                    <button
                      type="button"
                      onClick={() => setSearchQuery('')}
                      className="absolute right-4 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                    >
                      <X className="h-5 w-5" />
                    </button>
                  )}
                </div>
              </form>
            </div>
            <Button onClick={() => handleSearch()} size="lg">
              搜索
            </Button>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="container mx-auto px-4 py-8">
        {!hasSearched ? (
          <div className="grid md:grid-cols-2 gap-8">
            {/* Recent Searches */}
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="flex items-center gap-2 font-semibold">
                    <Clock className="h-5 w-5" />
                    最近搜索
                  </h2>
                  {recentSearches.length > 0 && (
                    <Button variant="ghost" size="sm" onClick={handleClearHistory}>
                      清除
                    </Button>
                  )}
                </div>
                {recentSearches.length > 0 ? (
                  <div className="flex flex-wrap gap-2">
                    {recentSearches.map((keyword, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          setSearchQuery(keyword);
                          handleSearch(keyword);
                        }}
                        className="px-4 py-2 rounded-full bg-muted hover:bg-accent transition-colors"
                      >
                        {keyword}
                      </button>
                    ))}
                  </div>
                ) : (
                  <p className="text-muted-foreground text-sm">暂无搜索记录</p>
                )}
              </CardContent>
            </Card>

            {/* Hot Search */}
            <Card>
              <CardContent className="p-6">
                <h2 className="flex items-center gap-2 font-semibold mb-4">
                  <TrendingUp className="h-5 w-5 text-orange-500" />
                  热门搜索
                </h2>
                <div className="space-y-3">
                  {HOT_SEARCH.map((item, index) => (
                    <button
                      key={item.id}
                      onClick={() => {
                        setSearchQuery(item.keyword);
                        handleSearch(item.keyword);
                      }}
                      className="flex w-full items-center justify-between py-2 hover:text-primary transition-colors"
                    >
                      <span className="flex items-center gap-3">
                        <span
                          className={cn(
                            'w-6 text-center font-bold',
                            index < 3 ? 'text-orange-500' : 'text-muted-foreground'
                          )}
                        >
                          {index + 1}
                        </span>
                        <span>{item.keyword}</span>
                      </span>
                      <span className="text-xs text-muted-foreground">
                        {item.heat.toLocaleString()}
                      </span>
                    </button>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        ) : (
          <div>
            {/* Results Header */}
            <div className="flex items-center justify-between mb-6">
              <p className="text-muted-foreground">
                找到 <span className="font-medium text-foreground">{results.length}</span> 个相关结果
              </p>
              <div className="flex items-center gap-4">
                <Button variant="outline" size="sm" onClick={() => handleSearch()}>
                  搜索: {searchQuery}
                </Button>
              </div>
            </div>

            {/* Results */}
            {isSearching ? (
              <div className="text-center py-16">
                <div className="animate-spin h-12 w-12 border-4 border-primary border-t-transparent rounded-full mx-auto" />
                <p className="mt-4 text-muted-foreground">搜索中...</p>
              </div>
            ) : results.length === 0 ? (
              <div className="text-center py-16">
                <Search className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
                <h3 className="text-lg font-medium mb-2">未找到相关书籍</h3>
                <p className="text-muted-foreground mb-4">
                  试试其他关键词，或浏览分类
                </p>
                <Button asChild>
                  <Link href="/category">浏览分类</Link>
                </Button>
              </div>
            ) : (
              <>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
                  {paginatedResults.map((book) => (
                    <BookCard key={book.id} book={book} />
                  ))}
                </div>

                {results.length > pageSize && (
                  <div className="mt-8 flex justify-center">
                    <Pagination
                      currentPage={currentPage}
                      totalPages={Math.ceil(results.length / pageSize)}
                      onPageChange={setCurrentPage}
                    />
                  </div>
                )}
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
