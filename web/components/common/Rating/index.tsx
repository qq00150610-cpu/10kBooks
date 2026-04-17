'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { Star } from 'lucide-react';

interface RatingProps {
  value: number;
  max?: number;
  size?: 'sm' | 'md' | 'lg';
  readonly?: boolean;
  showValue?: boolean;
  allowHalf?: boolean;
  onChange?: (value: number) => void;
  className?: string;
}

const sizeClasses = {
  sm: 'h-4 w-4',
  md: 'h-5 w-5',
  lg: 'h-6 w-6',
};

export function Rating({
  value,
  max = 5,
  size = 'md',
  readonly = false,
  showValue = false,
  allowHalf = true,
  onChange,
  className,
}: RatingProps) {
  const [hoverValue, setHoverValue] = React.useState<number | null>(null);

  const displayValue = hoverValue ?? value;

  const handleClick = (newValue: number) => {
    if (!readonly && onChange) {
      onChange(newValue);
    }
  };

  const handleMouseMove = (e: React.MouseEvent<SVGSVGElement>, index: number) => {
    if (readonly) return;
    
    const rect = e.currentTarget.getBoundingClientRect();
    const isHalf = allowHalf && e.clientX - rect.left < rect.width / 2;
    setHoverValue(index + (isHalf ? 0.5 : 1));
  };

  const handleMouseLeave = () => {
    setHoverValue(null);
  };

  return (
    <div className={cn('flex items-center gap-1', className)}>
      <div className="flex">
        {Array.from({ length: max }).map((_, index) => {
          const fillPercentage =
            displayValue >= index + 1
              ? 100
              : displayValue > index
              ? (displayValue - index) * 100
              : 0;

          return (
            <svg
              key={index}
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              className={cn(
                sizeClasses[size],
                !readonly && 'cursor-pointer transition-transform hover:scale-110'
              )}
              onClick={() => handleClick(index + 1)}
              onMouseMove={(e) => handleMouseMove(e, index)}
              onMouseLeave={handleMouseLeave}
            >
              <defs>
                <linearGradient id={`star-fill-${index}`}>
                  <stop offset={`${fillPercentage}%`} stopColor="#f59e0b" />
                  <stop offset={`${fillPercentage}%`} stopColor="#d1d5db" />
                </linearGradient>
              </defs>
              <Star
                className="h-full w-full"
                fill={`url(#star-fill-${index})`}
                stroke="#f59e0b"
                strokeWidth={1}
              />
            </svg>
          );
        })}
      </div>
      {showValue && (
        <span className="ml-1 text-sm font-medium text-muted-foreground">
          {value.toFixed(1)}
        </span>
      )}
    </div>
  );
}

interface RatingStatsProps {
  stats: {
    5: number;
    4: number;
    3: number;
    2: number;
    1: number;
  };
  average: number;
  total: number;
  className?: string;
}

export function RatingStats({ stats, average, total, className }: RatingStatsProps) {
  const percentages = Object.entries(stats).map(([key, value]) => ({
    stars: parseInt(key),
    count: value,
    percentage: total > 0 ? Math.round((value / total) * 100) : 0,
  })).reverse();

  return (
    <div className={cn('space-y-3', className)}>
      <div className="flex items-center gap-4">
        <div className="text-4xl font-bold">{average.toFixed(1)}</div>
        <div className="flex flex-col gap-1">
          <Rating value={average} readonly showValue={false} />
          <p className="text-sm text-muted-foreground">{total} 人评分</p>
        </div>
      </div>
      <div className="space-y-1">
        {percentages.map(({ stars, percentage }) => (
          <div key={stars} className="flex items-center gap-2 text-sm">
            <span className="w-8">{stars} 星</span>
            <div className="h-2 flex-1 overflow-hidden rounded-full bg-muted">
              <div
                className="h-full bg-amber-500 transition-all duration-500"
                style={{ width: `${percentage}%` }}
              />
            </div>
            <span className="w-10 text-right text-muted-foreground">{percentage}%</span>
          </div>
        ))}
      </div>
    </div>
  );
}
