'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { useReaderStore } from '@/lib/store';
import { READER_THEMES, READER_FONT_SIZES, READER_LINE_HEIGHTS } from '@/lib/constants';
import { Button } from '@/components/ui/Button';
import {
  Sun,
  Moon,
  Type,
  AlignJustify,
  BookOpen,
  ChevronLeft,
  ChevronRight,
  Settings,
  Bookmark,
  Home,
  List,
} from 'lucide-react';

interface ReaderToolbarProps {
  bookTitle?: string;
  chapterTitle?: string;
  currentChapter?: number;
  totalChapters?: number;
  onPreviousChapter?: () => void;
  onNextChapter?: () => void;
  onToggleChapterList?: () => void;
  onToggleBookmark?: () => void;
  isBookmarked?: boolean;
}

export function ReaderToolbar({
  bookTitle,
  chapterTitle,
  currentChapter = 1,
  totalChapters = 1,
  onPreviousChapter,
  onNextChapter,
  onToggleChapterList,
  onToggleBookmark,
  isBookmarked = false,
}: ReaderToolbarProps) {
  const { settings, updateSettings, isToolbarVisible, toggleToolbar } = useReaderStore();

  return (
    <>
      {/* Top Toolbar */}
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
              onClick={onToggleBookmark}
              className={cn(isBookmarked && 'text-amber-500')}
            >
              <Bookmark className={cn('h-5 w-5', isBookmarked && 'fill-current')} />
            </Button>
            <Button variant="ghost" size="icon" onClick={onToggleChapterList}>
              <List className="h-5 w-5" />
            </Button>
            <Button variant="ghost" size="icon" onClick={toggleToolbar}>
              <Settings className="h-5 w-5" />
            </Button>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="h-1 bg-muted">
          <div
            className="h-full bg-primary transition-all duration-300"
            style={{ width: `${(currentChapter / totalChapters) * 100}%` }}
          />
        </div>
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
            disabled={currentChapter <= 1}
          >
            <ChevronLeft className="h-4 w-4 mr-1" />
            上一章
          </Button>

          <div className="flex items-center gap-2">
            <span className="text-sm text-muted-foreground">
              {currentChapter} / {totalChapters}
            </span>
          </div>

          <Button
            variant="outline"
            size="sm"
            onClick={onNextChapter}
            disabled={currentChapter >= totalChapters}
          >
            下一章
            <ChevronRight className="h-4 w-4 ml-1" />
          </Button>
        </div>
      </div>
    </>
  );
}

interface ReaderSettingsProps {
  isOpen: boolean;
  onClose: () => void;
}

export function ReaderSettings({ isOpen, onClose }: ReaderSettingsProps) {
  const { settings, updateSettings } = useReaderStore();

  if (!isOpen) return null;

  return (
    <>
      <div className="fixed inset-0 z-40 bg-black/50" onClick={onClose} />
      <div className="fixed right-0 top-0 bottom-0 z-50 w-80 bg-background border-l shadow-xl animate-in slide-in-from-right duration-300 overflow-y-auto">
        <div className="p-4 border-b flex items-center justify-between">
          <h3 className="font-semibold">阅读设置</h3>
          <Button variant="ghost" size="icon" onClick={onClose}>
            ×
          </Button>
        </div>

        <div className="p-4 space-y-6">
          {/* Theme */}
          <div>
            <h4 className="mb-3 text-sm font-medium flex items-center gap-2">
              <Sun className="h-4 w-4" />
              主题
            </h4>
            <div className="flex gap-2">
              {READER_THEMES.map((theme) => (
                <button
                  key={theme.id}
                  onClick={() => updateSettings({ theme: theme.id as any })}
                  className={cn(
                    'flex-1 h-12 rounded-lg border-2 transition-all flex items-center justify-center',
                    settings.theme === theme.id
                      ? 'border-primary'
                      : 'border-transparent hover:border-muted'
                  )}
                  style={{ backgroundColor: theme.bg }}
                >
                  <span
                    className="w-6 h-6 rounded-full border"
                    style={{ backgroundColor: theme.text }}
                  />
                </button>
              ))}
            </div>
          </div>

          {/* Font Size */}
          <div>
            <h4 className="mb-3 text-sm font-medium flex items-center gap-2">
              <Type className="h-4 w-4" />
              字体大小
            </h4>
            <div className="flex items-center gap-3">
              <span className="text-xs text-muted-foreground">A</span>
              <input
                type="range"
                min={14}
                max={32}
                value={settings.fontSize}
                onChange={(e) => updateSettings({ fontSize: parseInt(e.target.value) })}
                className="flex-1"
              />
              <span className="text-lg text-muted-foreground">A</span>
            </div>
            <p className="mt-2 text-center text-sm">{settings.fontSize}px</p>
          </div>

          {/* Line Height */}
          <div>
            <h4 className="mb-3 text-sm font-medium flex items-center gap-2">
              <AlignJustify className="h-4 w-4" />
              行间距
            </h4>
            <div className="flex gap-2">
              {READER_LINE_HEIGHTS.map((lh) => (
                <button
                  key={lh}
                  onClick={() => updateSettings({ lineHeight: lh })}
                  className={cn(
                    'flex-1 py-2 rounded-lg border text-sm transition-all',
                    settings.lineHeight === lh
                      ? 'border-primary bg-primary/10'
                      : 'border-border hover:border-primary/50'
                  )}
                >
                  {lh}
                </button>
              ))}
            </div>
          </div>

          {/* Page Mode */}
          <div>
            <h4 className="mb-3 text-sm font-medium flex items-center gap-2">
              <BookOpen className="h-4 w-4" />
              翻页模式
            </h4>
            <div className="flex gap-2">
              <button
                onClick={() => updateSettings({ pageMode: 'scroll' })}
                className={cn(
                  'flex-1 py-2 rounded-lg border text-sm transition-all',
                  settings.pageMode === 'scroll'
                    ? 'border-primary bg-primary/10'
                    : 'border-border hover:border-primary/50'
                )}
              >
                滚动
              </button>
              <button
                onClick={() => updateSettings({ pageMode: 'paginate' })}
                className={cn(
                  'flex-1 py-2 rounded-lg border text-sm transition-all',
                  settings.pageMode === 'paginate'
                    ? 'border-primary bg-primary/10'
                    : 'border-border hover:border-primary/50'
                )}
              >
                分页
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
