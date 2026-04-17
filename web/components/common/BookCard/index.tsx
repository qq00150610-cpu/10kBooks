'use client';

import * as React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { cn } from '@/lib/utils';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { Star, Eye, BookOpen, Clock } from 'lucide-react';
import type { Book } from '@/lib/types';
import { formatNumber, getReadingTime } from '@/lib/utils';

interface BookCardProps {
  book: Book;
  variant?: 'vertical' | 'horizontal' | 'compact';
  className?: string;
}

export function BookCard({ book, variant = 'vertical', className }: BookCardProps) {
  if (variant === 'horizontal') {
    return (
      <Link href={`/book/${book.id}`}>
        <Card hover className={cn('flex gap-4 p-3', className)}>
          <div className="relative h-[120px] w-[80px] shrink-0 overflow-hidden rounded-lg">
            <Image
              src={book.cover}
              alt={book.title}
              fill
              className="object-cover"
            />
            {book.isVip && (
              <Badge className="absolute top-1 left-1" variant="premium">
                VIP
              </Badge>
            )}
          </div>
          <div className="flex flex-1 flex-col justify-between">
            <div>
              <h3 className="font-semibold line-clamp-1 hover:text-primary transition-colors">
                {book.title}
              </h3>
              <p className="text-sm text-muted-foreground">{book.author.name}</p>
              <p className="mt-1 text-sm text-muted-foreground line-clamp-2">
                {book.description}
              </p>
            </div>
            <div className="flex items-center gap-4 text-xs text-muted-foreground">
              <span className="flex items-center gap-1">
                <Eye className="h-3 w-3" />
                {formatNumber(book.viewCount)}
              </span>
              <span className="flex items-center gap-1">
                <Star className="h-3 w-3 text-amber-500" />
                {book.rating.toFixed(1)}
              </span>
              <span className="flex items-center gap-1">
                <BookOpen className="h-3 w-3" />
                {book.chapters.length}章
              </span>
            </div>
          </div>
        </Card>
      </Link>
    );
  }

  if (variant === 'compact') {
    return (
      <Link href={`/book/${book.id}`}>
        <div
          className={cn(
            'group flex gap-3 p-2 rounded-lg hover:bg-accent transition-colors cursor-pointer',
            className
          )}
        >
          <div className="relative h-16 w-12 shrink-0 overflow-hidden rounded">
            <Image src={book.cover} alt={book.title} fill className="object-cover" />
          </div>
          <div className="flex flex-1 flex-col justify-center">
            <h4 className="text-sm font-medium line-clamp-1 group-hover:text-primary transition-colors">
              {book.title}
            </h4>
            <p className="text-xs text-muted-foreground">{book.author.name}</p>
          </div>
        </div>
      </Link>
    );
  }

  // Vertical variant (default)
  return (
    <Link href={`/book/${book.id}`}>
      <Card hover className={cn('overflow-hidden p-0', className)}>
        <div className="relative aspect-[3/4] overflow-hidden">
          <Image src={book.cover} alt={book.title} fill className="object-cover" />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
          {book.isVip && (
            <Badge className="absolute top-2 right-2" variant="premium">
              VIP
            </Badge>
          )}
          <div className="absolute bottom-2 left-2 right-2">
            <h3 className="font-semibold text-white line-clamp-2 drop-shadow-md">
              {book.title}
            </h3>
          </div>
        </div>
        <div className="p-3">
          <div className="flex items-center gap-2">
            <Avatar src={book.author.avatar} alt={book.author.name} size="xs" />
            <span className="text-sm text-muted-foreground">{book.author.name}</span>
          </div>
          <div className="mt-2 flex items-center justify-between text-xs text-muted-foreground">
            <span className="flex items-center gap-1">
              <Eye className="h-3 w-3" />
              {formatNumber(book.viewCount)}
            </span>
            <span className="flex items-center gap-1">
              <Star className="h-3 w-3 text-amber-500" />
              {book.rating.toFixed(1)}
            </span>
          </div>
          <p className="mt-2 text-xs text-muted-foreground line-clamp-2">{book.description}</p>
        </div>
      </Card>
    </Link>
  );
}

interface BookListProps {
  books: Book[];
  variant?: 'vertical' | 'horizontal' | 'compact';
  className?: string;
}

export function BookList({ books, variant = 'vertical', className }: BookListProps) {
  if (variant === 'horizontal') {
    return (
      <div className={cn('space-y-3', className)}>
        {books.map((book) => (
          <BookCard key={book.id} book={book} variant="horizontal" />
        ))}
      </div>
    );
  }

  return (
    <div
      className={cn(
        'grid gap-4',
        variant === 'vertical' && 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6',
        className
      )}
    >
      {books.map((book) => (
        <BookCard key={book.id} book={book} variant={variant} />
      ))}
    </div>
  );
}
