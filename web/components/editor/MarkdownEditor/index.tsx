'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import {
  Bold,
  Italic,
  Heading,
  List,
  ListOrdered,
  Quote,
  Code,
  Link,
  Image,
  Eye,
  Edit3,
  Sparkles,
  Check,
  X,
} from 'lucide-react';

interface MarkdownEditorProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  minHeight?: string;
  className?: string;
}

export function MarkdownEditor({
  value,
  onChange,
  placeholder = '开始写作... (支持Markdown语法)',
  minHeight = '400px',
  className,
}: MarkdownEditorProps) {
  const [isPreview, setIsPreview] = React.useState(false);
  const [suggestions, setSuggestions] = React.useState<string[]>([]);
  const [selectedSuggestion, setSelectedSuggestion] = React.useState(-1);
  const textareaRef = React.useRef<HTMLTextAreaElement>(null);

  const insertText = (before: string, after: string = '') => {
    const textarea = textareaRef.current;
    if (!textarea) return;

    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const selectedText = value.substring(start, end);
    const newText =
      value.substring(0, start) + before + selectedText + after + value.substring(end);

    onChange(newText);

    // Reset cursor position
    setTimeout(() => {
      textarea.focus();
      textarea.setSelectionRange(
        start + before.length,
        start + before.length + selectedText.length
      );
    }, 0);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    // AI suggestion navigation
    if (suggestions.length > 0) {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        setSelectedSuggestion((prev) =>
          prev < suggestions.length - 1 ? prev + 1 : 0
        );
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        setSelectedSuggestion((prev) =>
          prev > 0 ? prev - 1 : suggestions.length - 1
        );
      } else if (e.key === 'Enter' && selectedSuggestion >= 0) {
        e.preventDefault();
        applySuggestion(suggestions[selectedSuggestion]);
      } else if (e.key === 'Escape') {
        setSuggestions([]);
        setSelectedSuggestion(-1);
      }
    }

    // Tab for indentation
    if (e.key === 'Tab') {
      e.preventDefault();
      insertText('  ');
    }
  };

  const applySuggestion = (text: string) => {
    const textarea = textareaRef.current;
    if (!textarea) return;

    const cursorPos = textarea.selectionStart;
    const newText = value.substring(0, cursorPos) + text + value.substring(cursorPos);
    onChange(newText);
    setSuggestions([]);
    setSelectedSuggestion(-1);

    setTimeout(() => {
      textarea.focus();
      const newPos = cursorPos + text.length;
      textarea.setSelectionRange(newPos, newPos);
    }, 0);
  };

  // Simple AI suggestions (mock)
  React.useEffect(() => {
    const timer = setTimeout(() => {
      // Mock AI suggestions
      if (value.endsWith('。') || value.endsWith('，')) {
        const mockSuggestions = [
          '突然，一道光芒闪过...',
          '就在这时，门外传来一阵急促的敲门声。',
          '他心中一动，似乎想起了什么。',
        ];
        setSuggestions(mockSuggestions);
      }
    }, 1000);

    return () => clearTimeout(timer);
  }, [value]);

  const renderMarkdown = (text: string) => {
    // Basic markdown rendering
    let html = text
      // Headers
      .replace(/^### (.*$)/gm, '<h3 class="text-lg font-semibold mt-4 mb-2">$1</h3>')
      .replace(/^## (.*$)/gm, '<h2 class="text-xl font-semibold mt-6 mb-3">$1</h2>')
      .replace(/^# (.*$)/gm, '<h1 class="text-2xl font-bold mt-6 mb-4">$1</h1>')
      // Bold
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      // Italic
      .replace(/\*(.*?)\*/g, '<em>$1</em>')
      // Code blocks
      .replace(/```([\s\S]*?)```/g, '<pre class="bg-muted p-3 rounded-lg my-3 overflow-x-auto"><code>$1</code></pre>')
      // Inline code
      .replace(/`(.*?)`/g, '<code class="bg-muted px-1 rounded">$1</code>')
      // Blockquotes
      .replace(/^> (.*$)/gm, '<blockquote class="border-l-4 border-primary pl-4 my-3 italic">$1</blockquote>')
      // Lists
      .replace(/^\* (.*$)/gm, '<li class="ml-6 list-disc">$1</li>')
      .replace(/^\d+\. (.*$)/gm, '<li class="ml-6 list-decimal">$1</li>')
      // Links
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" class="text-primary underline" target="_blank">$1</a>')
      // Paragraphs
      .replace(/\n\n/g, '</p><p class="mb-4">')
      // Line breaks
      .replace(/\n/g, '<br />');

    return `<p class="mb-4">${html}</p>`;
  };

  return (
    <div className={cn('border rounded-lg overflow-hidden', className)}>
      {/* Toolbar */}
      <div className="flex items-center gap-1 p-2 border-b bg-muted/50">
        <button
          onClick={() => insertText('**', '**')}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="加粗"
        >
          <Bold className="h-4 w-4" />
        </button>
        <button
          onClick={() => insertText('*', '*')}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="斜体"
        >
          <Italic className="h-4 w-4" />
        </button>
        <button
          onClick={() => insertText('## ')}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="标题"
        >
          <Heading className="h-4 w-4" />
        </button>
        <button
          onClick={() => insertText('* ')}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="无序列表"
        >
          <List className="h-4 w-4" />
        </button>
        <button
          onClick={() => insertText('1. ')}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="有序列表"
        >
          <ListOrdered className="h-4 w-4" />
        </button>
        <button
          onClick={() => insertText('> ')}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="引用"
        >
          <Quote className="h-4 w-4" />
        </button>
        <button
          onClick={() => insertText('`', '`')}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="代码"
        >
          <Code className="h-4 w-4" />
        </button>
        <button
          onClick={() => {
            const url = prompt('输入链接地址');
            if (url) insertText('[', `](${url})`);
          }}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="链接"
        >
          <Link className="h-4 w-4" />
        </button>
        <button
          onClick={() => {
            const url = prompt('输入图片地址');
            if (url) insertText(`![图片](${url})`);
          }}
          className="p-2 rounded-lg hover:bg-accent transition-colors"
          title="图片"
        >
          <Image className="h-4 w-4" />
        </button>

        <div className="flex-1" />

        <Button
          variant={isPreview ? 'default' : 'ghost'}
          size="sm"
          onClick={() => setIsPreview(!isPreview)}
        >
          {isPreview ? (
            <>
              <Edit3 className="h-4 w-4 mr-1" />
              编辑
            </>
          ) : (
            <>
              <Eye className="h-4 w-4 mr-1" />
              预览
            </>
          )}
        </Button>
      </div>

      {/* Editor / Preview */}
      <div className="relative" style={{ minHeight }}>
        {isPreview ? (
          <div
            className="p-4 overflow-y-auto prose prose-sm max-w-none"
            style={{ minHeight }}
            dangerouslySetInnerHTML={{ __html: renderMarkdown(value) }}
          />
        ) : (
          <textarea
            ref={textareaRef}
            value={value}
            onChange={(e) => onChange(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder={placeholder}
            className="w-full p-4 resize-none focus:outline-none font-mono text-sm"
            style={{ minHeight }}
          />
        )}

        {/* AI Suggestions */}
        {suggestions.length > 0 && !isPreview && (
          <div className="absolute bottom-4 left-4 right-4 bg-background border rounded-lg shadow-lg p-2">
            <div className="flex items-center gap-2 mb-2 text-xs text-muted-foreground">
              <Sparkles className="h-3 w-3" />
              AI建议 (按Enter采纳)
            </div>
            <div className="flex flex-wrap gap-2">
              {suggestions.map((suggestion, index) => (
                <button
                  key={index}
                  onClick={() => applySuggestion(suggestion)}
                  className={cn(
                    'px-3 py-1.5 rounded-full text-sm transition-colors',
                    selectedSuggestion === index
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-muted hover:bg-accent'
                  )}
                >
                  {suggestion.slice(0, 20)}...
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
