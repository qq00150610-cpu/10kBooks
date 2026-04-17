'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/Button';
import {
  Bold,
  Italic,
  Underline,
  Strikethrough,
  Heading1,
  Heading2,
  Heading3,
  List,
  ListOrdered,
  Quote,
  Code,
  Link,
  Image,
  Undo,
  Redo,
  Save,
  Eye,
  Edit3,
} from 'lucide-react';

interface ToolbarButtonProps {
  icon: React.ReactNode;
  label: string;
  isActive?: boolean;
  onClick: () => void;
  disabled?: boolean;
}

function ToolbarButton({ icon, label, isActive, onClick, disabled }: ToolbarButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      title={label}
      className={cn(
        'p-2 rounded-lg transition-colors',
        isActive
          ? 'bg-primary/10 text-primary'
          : 'hover:bg-accent hover:text-accent-foreground',
        disabled && 'opacity-50 cursor-not-allowed'
      )}
    >
      {icon}
    </button>
  );
}

interface RichEditorProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  minHeight?: string;
  onSave?: () => void;
  isSaving?: boolean;
  className?: string;
}

export function RichEditor({
  value,
  onChange,
  placeholder = '开始写作...',
  minHeight = '400px',
  onSave,
  isSaving = false,
  className,
}: RichEditorProps) {
  const editorRef = React.useRef<HTMLDivElement>(null);
  const [isFocused, setIsFocused] = React.useState(false);

  const execCommand = (command: string, value?: string) => {
    document.execCommand(command, false, value);
    editorRef.current?.focus();
  };

  const handleInput = () => {
    if (editorRef.current) {
      onChange(editorRef.current.innerHTML);
    }
  };

  React.useEffect(() => {
    if (editorRef.current && editorRef.current.innerHTML !== value) {
      editorRef.current.innerHTML = value;
    }
  }, [value]);

  return (
    <div className={cn('border rounded-lg overflow-hidden', className)}>
      {/* Toolbar */}
      <div className="flex flex-wrap items-center gap-1 p-2 border-b bg-muted/50">
        <div className="flex items-center gap-1">
          <ToolbarButton
            icon={<Undo className="h-4 w-4" />}
            label="撤销"
            onClick={() => execCommand('undo')}
          />
          <ToolbarButton
            icon={<Redo className="h-4 w-4" />}
            label="重做"
            onClick={() => execCommand('redo')}
          />
        </div>

        <div className="w-px h-6 bg-border" />

        <div className="flex items-center gap-1">
          <ToolbarButton
            icon={<Bold className="h-4 w-4" />}
            label="加粗"
            onClick={() => execCommand('bold')}
          />
          <ToolbarButton
            icon={<Italic className="h-4 w-4" />}
            label="斜体"
            onClick={() => execCommand('italic')}
          />
          <ToolbarButton
            icon={<Underline className="h-4 w-4" />}
            label="下划线"
            onClick={() => execCommand('underline')}
          />
          <ToolbarButton
            icon={<Strikethrough className="h-4 w-4" />}
            label="删除线"
            onClick={() => execCommand('strikeThrough')}
          />
        </div>

        <div className="w-px h-6 bg-border" />

        <div className="flex items-center gap-1">
          <ToolbarButton
            icon={<Heading1 className="h-4 w-4" />}
            label="标题1"
            onClick={() => execCommand('formatBlock', '<h1>')}
          />
          <ToolbarButton
            icon={<Heading2 className="h-4 w-4" />}
            label="标题2"
            onClick={() => execCommand('formatBlock', '<h2>')}
          />
          <ToolbarButton
            icon={<Heading3 className="h-4 w-4" />}
            label="标题3"
            onClick={() => execCommand('formatBlock', '<h3>')}
          />
        </div>

        <div className="w-px h-6 bg-border" />

        <div className="flex items-center gap-1">
          <ToolbarButton
            icon={<List className="h-4 w-4" />}
            label="无序列表"
            onClick={() => execCommand('insertUnorderedList')}
          />
          <ToolbarButton
            icon={<ListOrdered className="h-4 w-4" />}
            label="有序列表"
            onClick={() => execCommand('insertOrderedList')}
          />
          <ToolbarButton
            icon={<Quote className="h-4 w-4" />}
            label="引用"
            onClick={() => execCommand('formatBlock', '<blockquote>')}
          />
        </div>

        <div className="w-px h-6 bg-border" />

        <div className="flex items-center gap-1">
          <ToolbarButton
            icon={<Code className="h-4 w-4" />}
            label="代码"
            onClick={() => execCommand('formatBlock', '<pre>')}
          />
          <ToolbarButton
            icon={<Link className="h-4 w-4" />}
            label="链接"
            onClick={() => {
              const url = prompt('输入链接地址');
              if (url) execCommand('createLink', url);
            }}
          />
          <ToolbarButton
            icon={<Image className="h-4 w-4" />}
            label="图片"
            onClick={() => {
              const url = prompt('输入图片地址');
              if (url) execCommand('insertImage', url);
            }}
          />
        </div>

        <div className="flex-1" />

        {onSave && (
          <Button size="sm" onClick={onSave} isLoading={isSaving}>
            <Save className="h-4 w-4 mr-1" />
            保存
          </Button>
        )}
      </div>

      {/* Editor */}
      <div
        ref={editorRef}
        contentEditable
        onInput={handleInput}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        data-placeholder={placeholder}
        className={cn(
          'p-4 focus:outline-none overflow-y-auto',
          isFocused && 'ring-2 ring-primary/50'
        )}
        style={{ minHeight }}
      />

      {/* Placeholder styles */}
      <style jsx>{`
        [contenteditable]:empty:before {
          content: attr(data-placeholder);
          color: #9ca3af;
          pointer-events: none;
          display: block;
        }
      `}</style>
    </div>
  );
}
