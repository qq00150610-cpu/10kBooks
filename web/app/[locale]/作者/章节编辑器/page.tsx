'use client';

import * as React from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { RichEditor } from '@/components/editor/RichEditor';
import { MarkdownEditor } from '@/components/editor/MarkdownEditor';
import { useAuthStore } from '@/lib/store';
import {
  Save,
  Send,
  ArrowLeft,
  List,
  Settings,
  Eye,
  Edit3,
  Clock,
  Check,
  AlertCircle,
  Sparkles,
} from 'lucide-react';
import { cn } from '@/lib/utils';

export default function ChapterEditorPage() {
  const router = useRouter();
  const params = useParams();
  const { isAuthenticated, user } = useAuthStore();
  const { bookId, chapterId } = params as { bookId: string; chapterId?: string };

  const [title, setTitle] = React.useState('');
  const [content, setContent] = React.useState('');
  const [isSaving, setIsSaving] = React.useState(false);
  const [isDirty, setIsDirty] = React.useState(false);
  const [lastSaved, setLastSaved] = React.useState<Date | null>(null);
  const [editorMode, setEditorMode] = React.useState<'rich' | 'markdown'>('rich');
  const [showAiSuggestions, setShowAiSuggestions] = React.useState(true);

  const wordCount = React.useMemo(() => {
    const text = content.replace(/<[^>]*>/g, '').replace(/[#*`_~\[\]]/g, '');
    return text.trim().split(/\s+/).filter(Boolean).length;
  }, [content]);

  const handleSave = async (asDraft = true) => {
    if (!title.trim()) {
      alert('请输入章节标题');
      return;
    }
    setIsSaving(true);
    try {
      // Mock save
      await new Promise((resolve) => setTimeout(resolve, 1000));
      setLastSaved(new Date());
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
      // Mock publish
      await new Promise((resolve) => setTimeout(resolve, 1500));
      alert('发布成功！');
      router.push(`/author/book/${bookId}`);
    } finally {
      setIsSaving(false);
    }
  };

  if (!isAuthenticated || user?.role !== 'author') {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <AlertCircle className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
          <p className="text-muted-foreground mb-4">请先登录作者账号</p>
          <Button asChild>
            <Link href="/login">去登录</Link>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="border-b sticky top-0 bg-background z-50">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between h-14">
            <div className="flex items-center gap-4">
              <Button variant="ghost" size="icon" asChild>
                <Link href={`/author/book/${bookId}`}>
                  <ArrowLeft className="h-5 w-5" />
                </Link>
              </Button>
              <div>
                <h1 className="font-semibold">
                  {chapterId === 'new' ? '新建章节' : '编辑章节'}
                </h1>
                <p className="text-xs text-muted-foreground">仙武帝尊</p>
              </div>
            </div>

            <div className="flex items-center gap-4">
              {/* Save Status */}
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                {isDirty ? (
                  <>
                    <Edit3 className="h-4 w-4" />
                    <span>未保存</span>
                  </>
                ) : lastSaved ? (
                  <>
                    <Check className="h-4 w-4 text-green-500" />
                    <span>已保存 {lastSaved.toLocaleTimeString()}</span>
                  </>
                ) : null}
              </div>

              {/* Word Count */}
              <span className="text-sm text-muted-foreground">
                {wordCount.toLocaleString()} 字
              </span>

              {/* Actions */}
              <Button variant="outline" onClick={() => handleSave(true)} isLoading={isSaving}>
                <Save className="h-4 w-4 mr-2" />
                保存草稿
              </Button>
              <Button onClick={handlePublish} isLoading={isSaving}>
                <Send className="h-4 w-4 mr-2" />
                发布
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        {/* Title */}
        <Input
          value={title}
          onChange={(e) => {
            setTitle(e.target.value);
            setIsDirty(true);
          }}
          placeholder="请输入章节标题"
          className="text-xl font-semibold border-0 border-b-2 border-transparent focus:border-primary focus:outline-none rounded-none pb-3 px-0"
        />

        {/* Editor Tabs */}
        <div className="mt-6">
          <Tabs defaultValue="rich" onValueChange={(v) => setEditorMode(v as any)}>
            <TabsList>
              <TabsTrigger value="rich">
                <Edit3 className="h-4 w-4 mr-2" />
                富文本编辑
              </TabsTrigger>
              <TabsTrigger value="markdown">
                <Sparkles className="h-4 w-4 mr-2" />
                Markdown
              </TabsTrigger>
            </TabsList>

            <TabsContent value="rich" className="mt-4">
              <RichEditor
                value={content}
                onChange={(value) => {
                  setContent(value);
                  setIsDirty(true);
                }}
                onSave={() => handleSave(true)}
                isSaving={isSaving}
                minHeight="calc(100vh - 300px)"
              />
            </TabsContent>

            <TabsContent value="markdown" className="mt-4">
              <MarkdownEditor
                value={content}
                onChange={(value) => {
                  setContent(value);
                  setIsDirty(true);
                }}
                minHeight="calc(100vh - 300px)"
              />
            </TabsContent>
          </Tabs>
        </div>

        {/* AI Assistant */}
        {showAiSuggestions && (
          <Card className="mt-6 bg-primary/5 border-primary/20">
            <CardContent className="p-4">
              <div className="flex items-start gap-3">
                <Sparkles className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-sm">AI写作助手</p>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setShowAiSuggestions(false)}
                    >
                      关闭
                    </Button>
                  </div>
                  <div className="mt-3 space-y-2">
                    <p className="text-sm text-muted-foreground">
                      输入内容后，AI会提供以下帮助：
                    </p>
                    <ul className="text-sm space-y-1">
                      <li className="flex items-center gap-2">
                        <Check className="h-3 w-3 text-green-500" />
                        智能续写建议
                      </li>
                      <li className="flex items-center gap-2">
                        <Check className="h-3 w-3 text-green-500" />
                        错别字检测
                      </li>
                      <li className="flex items-center gap-2">
                        <Check className="h-3 w-3 text-green-500" />
                        语法优化建议
                      </li>
                      <li className="flex items-center gap-2">
                        <Check className="h-3 w-3 text-green-500" />
                        剧情发展建议
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Writing Tips */}
        <Card className="mt-6">
          <CardHeader>
            <CardTitle className="text-base">写作提示</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="text-sm space-y-2 text-muted-foreground">
              <li>• 每章建议字数：2000-4000字</li>
              <li>• 使用自然段落分隔，便于阅读</li>
              <li>• 重要情节可使用对话和心理描写丰富内容</li>
              <li>• 定期保存草稿，避免意外丢失</li>
              <li>• 发布前检查错别字和标点符号</li>
            </ul>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
