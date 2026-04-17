'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';

interface LoadingProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  variant?: 'spinner' | 'dots' | 'pulse' | 'bars';
  className?: string;
  text?: string;
}

const sizeClasses = {
  sm: 'h-4 w-4',
  md: 'h-8 w-8',
  lg: 'h-12 w-12',
  xl: 'h-16 w-16',
};

export function Loading({ size = 'md', variant = 'spinner', className, text }: LoadingProps) {
  const Spinner = () => (
    <svg
      className={cn('animate-spin', sizeClasses[size], className)}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle
        className="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="4"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      />
    </svg>
  );

  const Dots = () => (
    <div className={cn('flex gap-1', className)}>
      {[0, 1, 2].map((i) => (
        <div
          key={i}
          className={cn(
            'rounded-full bg-current animate-bounce',
            size === 'sm' && 'h-1 w-1',
            size === 'md' && 'h-2 w-2',
            size === 'lg' && 'h-3 w-3',
            size === 'xl' && 'h-4 w-4'
          )}
          style={{ animationDelay: `${i * 0.15}s` }}
        />
      ))}
    </div>
  );

  const Pulse = () => (
    <div className={cn('relative', sizeClasses[size], className)}>
      <div className="absolute inset-0 animate-ping rounded-full bg-current opacity-75" />
      <div className="relative rounded-full bg-current" />
    </div>
  );

  const Bars = () => (
    <div className={cn('flex items-end gap-0.5', className)}>
      {[0, 1, 2, 3, 4].map((i) => (
        <div
          key={i}
          className={cn(
            'w-1 bg-current animate-pulse rounded',
            size === 'sm' && 'h-2',
            size === 'md' && 'h-4',
            size === 'lg' && 'h-6',
            size === 'xl' && 'h-8'
          )}
          style={{ animationDelay: `${i * 0.1}s`, animationDuration: '0.6s' }}
        />
      ))}
    </div>
  );

  const variants = {
    spinner: <Spinner />,
    dots: <Dots />,
    pulse: <Pulse />,
    bars: <Bars />,
  };

  if (text) {
    return (
      <div className="flex flex-col items-center gap-2">
        {variants[variant]}
        <span className="text-sm text-muted-foreground">{text}</span>
      </div>
    );
  }

  return variants[variant];
}

export function PageLoader() {
  return (
    <div className="flex h-screen w-full items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <Loading size="lg" variant="spinner" />
        <p className="text-muted-foreground">加载中...</p>
      </div>
    </div>
  );
}

export function Skeleton({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn('animate-pulse rounded-md bg-muted', className)}
      {...props}
    />
  );
}

export function CardSkeleton() {
  return (
    <div className="space-y-3">
      <Skeleton className="h-[200px] w-full rounded-xl" />
      <div className="space-y-2">
        <Skeleton className="h-4 w-[80%]" />
        <Skeleton className="h-4 w-[60%]" />
      </div>
    </div>
  );
}

export function BookCardSkeleton() {
  return (
    <div className="flex gap-3">
      <Skeleton className="h-[120px] w-[80px] rounded-lg shrink-0" />
      <div className="flex-1 space-y-2">
        <Skeleton className="h-4 w-[70%]" />
        <Skeleton className="h-3 w-[40%]" />
        <Skeleton className="h-3 w-[90%]" />
      </div>
    </div>
  );
}
