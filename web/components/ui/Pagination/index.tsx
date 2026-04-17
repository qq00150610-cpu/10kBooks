'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { ChevronLeft, ChevronRight } from 'lucide-react';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  siblings?: number;
  showFirstLast?: boolean;
}

export function Pagination({
  currentPage,
  totalPages,
  onPageChange,
  siblings = 1,
  showFirstLast = true,
}: PaginationProps) {
  const range = (start: number, end: number) => {
    return Array.from({ length: end - start + 1 }, (_, i) => start + i);
  };

  const paginationNumbers = () => {
    const totalPageNumbers = siblings * 2 + 5;

    if (totalPages <= totalPageNumbers) {
      return range(1, totalPages);
    }

    const leftSiblingIndex = Math.max(currentPage - siblings, 1);
    const rightSiblingIndex = Math.min(currentPage + siblings, totalPages);

    const showLeftDots = leftSiblingIndex > 3;
    const showRightDots = rightSiblingIndex < totalPages - 2;

    if (!showLeftDots && showRightDots) {
      const leftRange = range(1, 4 + siblings * 2);
      return [...leftRange, '...', totalPages];
    }

    if (showLeftDots && !showRightDots) {
      const rightRange = range(totalPages - (3 + siblings * 2), totalPages);
      return [1, '...', ...rightRange];
    }

    if (showLeftDots && showRightDots) {
      const middleRange = range(leftSiblingIndex, rightSiblingIndex);
      return [1, '...', ...middleRange, '...', totalPages];
    }
  };

  return (
    <nav className="flex items-center justify-center gap-1">
      {showFirstLast && (
        <button
          onClick={() => onPageChange(1)}
          disabled={currentPage === 1}
          className={cn(
            'rounded-lg p-2 hover:bg-accent transition-colors disabled:opacity-50 disabled:cursor-not-allowed'
          )}
        >
          <ChevronLeft className="h-4 w-4" />
          <ChevronLeft className="h-4 w-4 -ml-2" />
        </button>
      )}

      <button
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
        className={cn(
          'rounded-lg p-2 hover:bg-accent transition-colors disabled:opacity-50 disabled:cursor-not-allowed'
        )}
      >
        <ChevronLeft className="h-4 w-4" />
      </button>

      <div className="flex items-center gap-1">
        {paginationNumbers()?.map((page, index) =>
          typeof page === 'number' ? (
            <button
              key={page}
              onClick={() => onPageChange(page)}
              className={cn(
                'h-10 min-w-[40px] rounded-lg px-3 font-medium transition-colors',
                currentPage === page
                  ? 'bg-primary text-primary-foreground'
                  : 'hover:bg-accent hover:text-accent-foreground'
              )}
            >
              {page}
            </button>
          ) : (
            <span key={`dots-${index}`} className="px-2">
              ...
            </span>
          )
        )}
      </div>

      <button
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage === totalPages}
        className={cn(
          'rounded-lg p-2 hover:bg-accent transition-colors disabled:opacity-50 disabled:cursor-not-allowed'
        )}
      >
        <ChevronRight className="h-4 w-4" />
      </button>

      {showFirstLast && (
        <button
          onClick={() => onPageChange(totalPages)}
          disabled={currentPage === totalPages}
          className={cn(
            'rounded-lg p-2 hover:bg-accent transition-colors disabled:opacity-50 disabled:cursor-not-allowed'
          )}
        >
          <ChevronRight className="h-4 w-4" />
          <ChevronRight className="h-4 w-4 -ml-2" />
        </button>
      )}
    </nav>
  );
}
