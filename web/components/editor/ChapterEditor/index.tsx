'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/Button';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { RichEditor } from '../RichEditor';
import { MarkdownEditor } from '../MarkdownEditor';
import { Sparkles, Save, Eye, Edit3, Clock, Check } from 'lucide-react';

interface ChapterEditorProps {
  initialTitle?: string;
  initialContent?: string;
  onSave?: (title: string, content: string) => void;
  onPublish?: (title: string, content: string) => void;
  bookTitle?: string;
  chapterNumber?: number;
  isDraft?: boolean;
  lastSavedAt?: string;
  className?: string;
}

export function ChapterEditor({
  initialTitle = '',
  initialContent = '',
  onSave,
  onPublish,
  bookTitle,
  chapterNumber,
  isDraft = true,
  lastSavedAt,
  className,
}: ChapterEditorProps) {
  const [title, setTitle] = React.useState(initialTitle);
  const [content, setContent] = React.useState(initialContent);
  const [isSaving, setIsSaving] = React.useState(false);
  const [isDirty, setIsDirty] = React.useState(false);
  const [wordCount, setWordCount] = React.useState(0);
  const [editorMode, setEditorMode] = React.useState<'rich' | 'markdown'>('rich');

  // Calculate word count
  React.useEffect(() => {
    const text = content.replace(/<[^>]*>/g, '').replace(/[#*`_~\[\]]/g, '');
    const words = text.trim().split(/\s+/).filter(Boolean).length;
    setWordCount(words);
  }, [content]);

  // Track changes
  React.useEffect(() => {
    if (content !== initialContent || title !== initialTitle) {
      setIsDirty(true);
    }
  }, [content, title, initialContent, initialTitle]);

  // Auto-save
  React.useEffect(() => {
    if (!isDirty) return;

    const timer = setTimeout(() => {
      handleSave();
    }, 30000); // Auto-save after 30 seconds of inactivity

    return () => clearTimeout(timer);
  }, [isDirty, content, title]);

  const handleSave = async () => {
    if (!title.trim()) {
      alert('请输入章节标题');
      return;
    }
    setIsSaving(true);
    try {
      await onSave?.(title, content);
      setIsDirty(false);
    } finally {
      setIsSaving(false);
    }
  };

  const handlePublish = async () => {
    if (!title.trim()) {
      alert('请输入章节标题');
      return;
    }
    setIsSaving(true);
    try {
      await onPublish?.(title, content);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className={cn('space-y-4', className)}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          {bookTitle && (
            <p className="text-sm text-muted-foreground">
              {bookTitle} · 第{chapterNumber}章
            </p>
          )}
          <h1 className="text-xl font-semibold">
            {isDraft ? '编辑草稿' : '发布章节'}
          </h1>
        </div>
        <div className="flex items-center gap-4">
          {lastSavedAt && (
            <span className="text-xs text-muted-foreground flex items-center gap-1">
              <Clock className="h-3 w-3" />
              {new Date(lastSavedAt).toLocaleTimeString()}
            </span>
          )}
          {isDirty && (
            <span className="text-xs text-amber-500 flex items-center gap-1">
              <Edit3 className="h-3 w-3" />
              未保存
            </span>
          )}
          {!isDirty && (
            <span className="text-xs text-green-500 flex items-center gap-1">
              <Check className="h-3 w-3" />
              已保存
            </span>
          )}
          <span className="text-sm text-muted-foreground">
            {wordCount.toLocaleString()} 字
          </span>
        </div>
      </div>

      {/* Title Input */}
      <input
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="请输入章节标题"
        className="w-full text-xl font-semibold border-0 border-b-2 border-transparent focus:border-primary focus:outline-none pb-2 bg-transparent"
      />

      {/* Editor Mode Tabs */}
      <Tabs defaultValue="rich" onValueChange={(v) => setEditorMode(v as any)}>
        <TabsList>
          <TabsTrigger value="rich">
            <Edit3 className="h-4 w-4 mr-2" />
            富文本
          </TabsTrigger>
          <TabsTrigger value="markdown">
            <Sparkles className="h-4 w-4 mr-2" />
            Markdown
          </TabsTrigger>
        </TabsList>
        <TabsContent value="rich" className="mt-4">
          <RichEditor
            value={content}
            onChange={setContent}
            onSave={handleSave}
            isSaving={isSaving}
            minHeight="calc(100vh - 300px)"
          />
        </TabsContent>
        <TabsContent value="markdown" className="mt-4">
          <MarkdownEditor
            value={content}
            onChange={setContent}
            minHeight="calc(100vh - 300px)"
          />
        </TabsContent>
      </Tabs>

      {/* AI Assistant Hint */}
      <div className="rounded-lg bg-primary/5 border border-primary/20 p-4">
        <div className="flex items-start gap-3">
          <Sparkles className="h-5 w-5 text-primary shrink-0 mt-0.5" />
          <div>
            <p className="font-medium text-sm">AI写作助手</p>
            <p className="text-xs text-muted-foreground mt-1">
              使用Tab键触发AI补全建议，按Enter采纳建议
            </p>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex items-center justify-end gap-3 pt-4 border-t">
        <Button variant="outline" onClick={handleSave} isLoading={isSaving}>
          <Save className="h-4 w-4 mr-2" />
          保存草稿
        </Button>
        <Button onClick={handlePublish} isLoading={isSaving}>
          发布章节
        </Button>
      </div>
    </div>
  );
}
