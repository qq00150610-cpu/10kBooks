'use client';

import * as React from 'react';
import Link from 'next/link';
import { cn } from '@/lib/utils';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { ChevronRight, Lock, Check } from 'lucide-react';
import type { Chapter } from '@/lib/types';

interface ChapterListProps {
  chapters: Chapter[];
  currentChapterId?: string;
  bookId: string;
  freeChapterCount?: number;
  isVipUser?: boolean;
  onChapterClick?: (chapter: Chapter) => void;
  className?: string;
}

export function ChapterList({
  chapters,
  currentChapterId,
  bookId,
  freeChapterCount = 10,
  isVipUser = false,
  onChapterClick,
  className,
}: ChapterListProps) {
  const [searchQuery, setSearchQuery] = React.useState('');
  const [filter, setFilter] = React.useState<'all' | 'free' | 'vip'>('all');

  const filteredChapters = React.useMemo(() => {
    return chapters.filter((chapter) => {
      // Search filter
      if (searchQuery && !chapter.title.toLowerCase().includes(searchQuery.toLowerCase())) {
        return false;
      }
      // Status filter
      if (filter === 'free' && chapter.isVip) return false;
      if (filter === 'vip' && !chapter.isVip) return false;
      return true;
    });
  }, [chapters, searchQuery, filter]);

  // Group chapters by status
  const vipChapters = filteredChapters.filter((c) => c.isVip);
  const freeChapters = filteredChapters.filter((c) => !c.isVip);

  const renderChapter = (chapter: Chapter) => {
    const isLocked = chapter.isVip && !isVipUser;
    const isCurrent = chapter.id === currentChapterId;

    return (
      <div
        key={chapter.id}
        onClick={() => !isLocked && onChapterClick?.(chapter)}
        className={cn(
          'flex items-center justify-between py-3 px-4 rounded-lg transition-colors',
          isCurrent
            ? 'bg-primary/10 border border-primary/30'
            : 'hover:bg-accent',
          isLocked && 'opacity-60 cursor-not-allowed'
        )}
      >
        <div className="flex items-center gap-3 flex-1 min-w-0">
          <span className={cn('text-sm', isCurrent && 'text-primary font-medium')}>
            第{chapter.number}章
          </span>
          <span className={cn('text-sm truncate', isCurrent && 'text-primary')}>
            {chapter.title}
          </span>
          {isLocked ? (
            <Lock className="h-4 w-4 text-muted-foreground shrink-0" />
          ) : isCurrent ? (
            <Badge variant="default" className="shrink-0">当前</Badge>
          ) : null}
        </div>
        <div className="flex items-center gap-3">
          {chapter.isVip && (
            <Badge variant="premium" className="shrink-0">
              VIP
            </Badge>
          )}
          <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />
        </div>
      </div>
    );
  };

  return (
    <div className={cn('space-y-4', className)}>
      {/* Search and Filter */}
      <div className="space-y-3">
        <Input
          placeholder="搜索章节..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full"
        />
        <div className="flex gap-2">
          {(['all', 'free', 'vip'] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={cn(
                'flex-1 py-2 rounded-lg text-sm font-medium transition-colors',
                filter === f
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-muted hover:bg-muted/80'
              )}
            >
              {f === 'all' ? '全部' : f === 'free' ? '免费' : 'VIP'}
            </button>
          ))}
        </div>
      </div>

      {/* Chapters */}
      <div className="space-y-6">
        {/* Free Chapters */}
        {freeChapters.length > 0 && (
          <div>
            <h4 className="mb-2 text-sm font-medium text-muted-foreground">
              免费章节 ({freeChapters.length})
            </h4>
            <div className="space-y-1">
              {freeChapters.map(renderChapter)}
            </div>
          </div>
        )}

        {/* VIP Chapters */}
        {vipChapters.length > 0 && (
          <div>
            <h4 className="mb-2 text-sm font-medium text-muted-foreground">
              VIP章节 ({vipChapters.length})
            </h4>
            <div className="space-y-1">
              {vipChapters.map(renderChapter)}
            </div>
          </div>
        )}
      </div>

      {/* Empty State */}
      {filteredChapters.length === 0 && (
        <div className="py-12 text-center">
          <p className="text-muted-foreground">暂无章节</p>
        </div>
      )}
    </div>
  );
}
