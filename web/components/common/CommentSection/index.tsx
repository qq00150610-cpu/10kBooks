'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { Avatar } from '@/components/ui/Avatar';
import { Button } from '@/components/ui/Button';
import { useAuthStore } from '@/lib/store';
import { Heart, MessageCircle, Share2, Bookmark, MoreHorizontal } from 'lucide-react';
import { formatRelativeTime, formatNumber } from '@/lib/utils';
import type { Comment, User } from '@/lib/types';

interface CommentItemProps {
  comment: Comment;
  onReply?: (commentId: string) => void;
  onLike?: (commentId: string) => void;
  onReport?: (commentId: string) => void;
}

export function CommentItem({ comment, onReply, onLike, onReport }: CommentItemProps) {
  return (
    <div className="flex gap-3 py-4">
      <Avatar src={comment.user.avatar} alt={comment.user.username} size="md" />
      <div className="flex-1">
        <div className="flex items-center gap-2">
          <span className="font-medium">{comment.user.username}</span>
          <span className="text-xs text-muted-foreground">
            {formatRelativeTime(comment.createdAt)}
          </span>
        </div>
        <p className="mt-1 text-sm">{comment.content}</p>
        <div className="mt-2 flex items-center gap-4">
          <button
            onClick={() => onLike?.(comment.id)}
            className={cn(
              'flex items-center gap-1 text-sm transition-colors',
              comment.isLiked ? 'text-red-500' : 'text-muted-foreground hover:text-red-500'
            )}
          >
            <Heart className={cn('h-4 w-4', comment.isLiked && 'fill-current')} />
            {comment.likes > 0 && formatNumber(comment.likes)}
          </button>
          <button
            onClick={() => onReply?.(comment.id)}
            className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            <MessageCircle className="h-4 w-4" />
            回复
          </button>
        </div>

        {/* Replies */}
        {comment.replies && comment.replies.length > 0 && (
          <div className="mt-3 rounded-lg bg-muted/50 p-3 space-y-3">
            {comment.replies.map((reply) => (
              <div key={reply.id} className="flex gap-2">
                <Avatar src={reply.user.avatar} alt={reply.user.username} size="xs" />
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium">{reply.user.username}</span>
                    <span className="text-xs text-muted-foreground">
                      {formatRelativeTime(reply.createdAt)}
                    </span>
                  </div>
                  <p className="mt-0.5 text-sm">{reply.content}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

interface CommentSectionProps {
  comments: Comment[];
  total: number;
  onLoadMore?: () => void;
  onSubmit?: (content: string, parentId?: string) => void;
  onLike?: (commentId: string) => void;
  onReply?: (commentId: string) => void;
  placeholder?: string;
  className?: string;
}

export function CommentSection({
  comments,
  total,
  onLoadMore,
  onSubmit,
  onLike,
  onReply,
  placeholder = '发表你的看法...',
  className,
}: CommentSectionProps) {
  const { user, isAuthenticated } = useAuthStore();
  const [content, setContent] = useState('');
  const [replyingTo, setReplyingTo] = React.useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = React.useState(false);

  const handleSubmit = async () => {
    if (!content.trim() || !onSubmit) return;

    setIsSubmitting(true);
    try {
      await onSubmit(content.trim(), replyingTo || undefined);
      setContent('');
      setReplyingTo(null);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleReply = (commentId: string) => {
    setReplyingTo(commentId);
    // Focus on input
  };

  return (
    <div className={cn('space-y-4', className)}>
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold">评论 ({formatNumber(total)})</h3>
      </div>

      {/* Input */}
      {isAuthenticated && user ? (
        <div className="flex gap-3">
          <Avatar src={user.avatar} alt={user.username} size="md" />
          <div className="flex-1">
            <textarea
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder={placeholder}
              rows={3}
              className="w-full rounded-lg border bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary resize-none"
            />
            <div className="mt-2 flex justify-end">
              <Button onClick={handleSubmit} disabled={!content.trim() || isSubmitting} size="sm">
                {isSubmitting ? '发布中...' : '发布'}
              </Button>
            </div>
          </div>
        </div>
      ) : (
        <div className="rounded-lg bg-muted/50 p-4 text-center">
          <p className="text-muted-foreground">
            登录后参与评论
            <Button variant="link" className="ml-1" asChild>
              <a href="/login">登录</a>
            </Button>
          </p>
        </div>
      )}

      {/* Comments List */}
      <div className="divide-y">
        {comments.map((comment) => (
          <div key={comment.id}>
            <CommentItem
              comment={comment}
              onReply={handleReply}
              onLike={onLike}
            />
          </div>
        ))}
      </div>

      {/* Load More */}
      {onLoadMore && comments.length < total && (
        <div className="text-center">
          <Button variant="outline" onClick={onLoadMore}>
            加载更多评论
          </Button>
        </div>
      )}
    </div>
  );
}

// Helper hook
function useState<T>(initialValue: T): [T, React.Dispatch<React.SetStateAction<T>>] {
  return React.useState<T>(initialValue);
}
