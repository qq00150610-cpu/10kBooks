'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { useReaderStore } from '@/lib/store';
import { Button } from '@/components/ui/Button';
import { Progress } from '@/components/ui/Progress';
import {
  Bookmark,
  ChevronLeft,
  ChevronRight,
  Sun,
  Moon,
  Settings,
  Home,
  List,
} from 'lucide-react';

interface ReaderViewerProps {
  bookId: string;
  bookTitle: string;
  chapterId: string;
  chapterTitle: string;
  chapterNumber: number;
  totalChapters: number;
  content: string;
  onPreviousChapter?: () => void;
  onNextChapter?: () => void;
  onToggleChapterList?: () => void;
  onToggleSettings?: () => void;
  onAddBookmark?: () => void;
  isBookmarked?: boolean;
}

export function ReaderViewer({
  bookId,
  bookTitle,
  chapterId,
  chapterTitle,
  chapterNumber,
  totalChapters,
  content,
  onPreviousChapter,
  onNextChapter,
  onToggleChapterList,
  onToggleSettings,
  onAddBookmark,
  isBookmarked = false,
}: ReaderViewerProps) {
  const { settings, isToolbarVisible, toggleToolbar, setProgress } = useReaderStore();
  const contentRef = React.useRef<HTMLDivElement>(null);
  const [readingProgress, setReadingProgress] = React.useState(0);

  // Track reading progress
  React.useEffect(() => {
    const handleScroll = () => {
      if (contentRef.current) {
        const { scrollTop, scrollHeight, clientHeight } = contentRef.current;
        const progress = Math.round((scrollTop / (scrollHeight - clientHeight)) * 100) || 0;
        setReadingProgress(progress);
        setProgress({
          id: chapterId,
          userId: '',
          bookId,
          chapterId,
          position: scrollTop,
          percentage: progress,
          lastReadAt: new Date().toISOString(),
        });
      }
    };

    const container = contentRef.current;
    container?.addEventListener('scroll', handleScroll);
    return () => container?.removeEventListener('scroll', handleScroll);
  }, [chapterId, bookId, setProgress]);

  // Theme classes
  const themeClasses = {
    paper: 'bg-[#f5f5f0] text-[#333]',
    sepia: 'bg-[#f4ecd8] text-[#5b4636]',
    night: 'bg-[#1a1a2e] text-[#c4c4c4]',
    dark: 'bg-[#0f0f0f] text-[#e0e0e0]',
  };

  return (
    <div className="min-h-screen">
      {/* Top Bar */}
      <div
        className={cn(
          'fixed top-0 left-0 right-0 z-50 bg-background/95 backdrop-blur border-b transition-transform duration-300',
          isToolbarVisible ? 'translate-y-0' : '-translate-y-full'
        )}
      >
        <div className="flex h-14 items-center justify-between px-4">
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="icon" asChild>
              <a href="/">
                <Home className="h-5 w-5" />
              </a>
            </Button>
            <div className="hidden sm:block">
              <h1 className="font-medium line-clamp-1">{bookTitle}</h1>
              <p className="text-xs text-muted-foreground">{chapterTitle}</p>
            </div>
          </div>

          <div className="flex items-center gap-1">
            <Button
              variant="ghost"
              size="icon"
              onClick={onAddBookmark}
              className={cn(isBookmarked && 'text-amber-500')}
            >
              <Bookmark className={cn('h-5 w-5', isBookmarked && 'fill-current')} />
            </Button>
            <Button variant="ghost" size="icon" onClick={onToggleChapterList}>
              <List className="h-5 w-5" />
            </Button>
            <Button variant="ghost" size="icon" onClick={onToggleSettings}>
              <Settings className="h-5 w-5" />
            </Button>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="h-1 bg-muted">
          <div
            className="h-full bg-primary transition-all duration-300"
            style={{ width: `${((chapterNumber - 1) / totalChapters) * 100 + readingProgress / totalChapters}%` }}
          />
        </div>
      </div>

      {/* Content */}
      <div
        ref={contentRef}
        className={cn(
          'min-h-screen pt-16 pb-20 px-4 md:px-[15%] lg:px-[20%] overflow-y-auto',
          themeClasses[settings.theme]
        )}
        style={{
          fontSize: `${settings.fontSize}px`,
          lineHeight: settings.lineHeight,
        }}
        onClick={() => toggleToolbar()}
      >
        <article className="max-w-3xl mx-auto py-8">
          {/* Chapter Title */}
          <h1 className="text-2xl font-bold mb-8 text-center">
            第{chapterNumber}章 {chapterTitle}
          </h1>

          {/* Chapter Content */}
          <div
            className="whitespace-pre-wrap leading-relaxed"
            style={{ lineHeight: settings.lineHeight }}
          >
            {content.split('\n\n').map((paragraph, index) => (
              <p key={index} className="mb-4">
                {paragraph}
              </p>
            ))}
          </div>

          {/* Watermark */}
          <div className="mt-12 pt-8 border-t border-current/10">
            <p className="text-xs text-center opacity-30">
              万卷书苑 10kBooks · 尊重原创 · 请勿盗版
            </p>
          </div>
        </article>
      </div>

      {/* Bottom Navigation */}
      <div
        className={cn(
          'fixed bottom-0 left-0 right-0 z-50 bg-background/95 backdrop-blur border-t transition-transform duration-300',
          isToolbarVisible ? 'translate-y-0' : 'translate-y-full'
        )}
      >
        <div className="flex h-14 items-center justify-between px-4">
          <Button
            variant="outline"
            size="sm"
            onClick={onPreviousChapter}
            disabled={chapterNumber <= 1}
          >
            <ChevronLeft className="h-4 w-4 mr-1" />
            上一章
          </Button>

          <div className="flex items-center gap-2">
            <span className="text-sm text-muted-foreground">
              {chapterNumber} / {totalChapters}
            </span>
          </div>

          <Button
            variant="outline"
            size="sm"
            onClick={onNextChapter}
            disabled={chapterNumber >= totalChapters}
          >
            下一章
            <ChevronRight className="h-4 w-4 ml-1" />
          </Button>
        </div>
      </div>
    </div>
  );
}
