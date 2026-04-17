'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { Search, X, TrendingUp, Clock, ArrowRight } from 'lucide-react';
import { useSearchStore } from '@/lib/store';
import { useRouter } from 'next/navigation';

interface SearchBarProps {
  className?: string;
  autoFocus?: boolean;
  onSearch?: (query: string) => void;
  placeholder?: string;
}

const HOT_SEARCH = [
  { id: 1, keyword: '斗破苍穹', heat: 9800 },
  { id: 2, keyword: '庆余年', heat: 9600 },
  { id: 3, keyword: '凡人修仙传', heat: 9400 },
  { id: 4, keyword: '全职高手', heat: 9200 },
  { id: 5, keyword: '雪中悍刀行', heat: 9000 },
];

export function SearchBar({
  className,
  autoFocus = false,
  onSearch,
  placeholder = '搜索书名、作者...',
}: SearchBarProps) {
  const router = useRouter();
  const [isOpen, setIsOpen] = React.useState(false);
  const [query, setQuery] = React.useState('');
  const inputRef = React.useRef<HTMLInputElement>(null);
  const { recentSearches, addRecentSearch, clearRecentSearches } = useSearchStore();

  React.useEffect(() => {
    if (autoFocus && inputRef.current) {
      inputRef.current.focus();
    }
  }, [autoFocus]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      addRecentSearch(query.trim());
      onSearch?.(query.trim());
      router.push(`/search?q=${encodeURIComponent(query.trim())}`);
      setIsOpen(false);
    }
  };

  const handleHotSearch = (keyword: string) => {
    setQuery(keyword);
    addRecentSearch(keyword);
    router.push(`/search?q=${encodeURIComponent(keyword)}`);
    setIsOpen(false);
  };

  const handleClearHistory = () => {
    clearRecentSearches();
  };

  return (
    <div className={cn('relative', className)}>
      <form onSubmit={handleSubmit}>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-muted-foreground" />
          <input
            ref={inputRef}
            type="text"
            placeholder={placeholder}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onFocus={() => setIsOpen(true)}
            className="w-full rounded-lg border bg-background py-2.5 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
          {query && (
            <button
              type="button"
              onClick={() => setQuery('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>
      </form>

      {/* Dropdown */}
      {isOpen && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setIsOpen(false)} />
          <div className="absolute left-0 right-0 top-full z-50 mt-2 rounded-lg border bg-popover p-4 shadow-lg animate-in fade-in slide-in-from-top-2 duration-200">
            {/* Recent Searches */}
            {recentSearches.length > 0 && (
              <div className="mb-4">
                <div className="mb-2 flex items-center justify-between">
                  <span className="flex items-center gap-2 text-sm font-medium">
                    <Clock className="h-4 w-4" />
                    最近搜索
                  </span>
                  <button
                    onClick={handleClearHistory}
                    className="text-xs text-muted-foreground hover:text-foreground"
                  >
                    清除
                  </button>
                </div>
                <div className="flex flex-wrap gap-2">
                  {recentSearches.slice(0, 5).map((keyword, index) => (
                    <button
                      key={index}
                      onClick={() => handleHotSearch(keyword)}
                      className="rounded-full bg-muted px-3 py-1 text-sm hover:bg-accent transition-colors"
                    >
                      {keyword}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Hot Search */}
            <div>
              <span className="mb-2 flex items-center gap-2 text-sm font-medium">
                <TrendingUp className="h-4 w-4 text-orange-500" />
                热门搜索
              </span>
              <div className="space-y-1">
                {HOT_SEARCH.map((item, index) => (
                  <button
                    key={item.id}
                    onClick={() => handleHotSearch(item.keyword)}
                    className="flex w-full items-center justify-between rounded-md px-2 py-1.5 text-sm hover:bg-accent transition-colors"
                  >
                    <span className="flex items-center gap-3">
                      <span
                        className={cn(
                          'w-5 text-center font-bold',
                          index < 3 ? 'text-orange-500' : 'text-muted-foreground'
                        )}
                      >
                        {index + 1}
                      </span>
                      <span>{item.keyword}</span>
                    </span>
                    <ArrowRight className="h-4 w-4 text-muted-foreground" />
                  </button>
                ))}
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
