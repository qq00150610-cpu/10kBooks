'use client';

import * as React from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { useAuthStore } from '@/lib/store';

const LANGUAGES = [
  { code: 'zh', name: '中文', flag: '🇨🇳' },
  { code: 'en', name: 'English', flag: '🇺🇸' },
];

interface LanguageSwitcherProps {
  variant?: 'dropdown' | 'buttons';
  className?: string;
}

export function LanguageSwitcher({ variant = 'dropdown', className }: LanguageSwitcherProps) {
  const router = useRouter();
  const pathname = usePathname();
  const [currentLocale, setCurrentLocale] = React.useState('zh');
  const [isOpen, setIsOpen] = React.useState(false);

  React.useEffect(() => {
    const match = pathname.match(/^\/(zh|en)/);
    if (match) {
      setCurrentLocale(match[1]);
    }
  }, [pathname]);

  const handleSwitch = (locale: string) => {
    const newPath = pathname.replace(/^\/(zh|en)/, `/${locale}`);
    router.push(newPath);
    setIsOpen(false);
  };

  const currentLang = LANGUAGES.find((l) => l.code === currentLocale) || LANGUAGES[0];

  if (variant === 'buttons') {
    return (
      <div className={cn('flex gap-2', className)}>
        {LANGUAGES.map((lang) => (
          <button
            key={lang.code}
            onClick={() => handleSwitch(lang.code)}
            className={cn(
              'flex items-center gap-1 rounded-lg px-3 py-1.5 text-sm transition-colors',
              currentLocale === lang.code
                ? 'bg-primary text-primary-foreground'
                : 'bg-muted hover:bg-accent'
            )}
          >
            <span>{lang.flag}</span>
            <span>{lang.name}</span>
          </button>
        ))}
      </div>
    );
  }

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={cn(
          'flex items-center gap-2 rounded-lg px-3 py-2 text-sm transition-colors hover:bg-accent',
          className
        )}
      >
        <span>{currentLang.flag}</span>
        <span>{currentLang.name}</span>
      </button>

      {isOpen && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setIsOpen(false)} />
          <div className="absolute right-0 top-full z-50 mt-2 min-w-[140px] overflow-hidden rounded-lg border bg-popover shadow-lg">
            {LANGUAGES.map((lang) => (
              <button
                key={lang.code}
                onClick={() => handleSwitch(lang.code)}
                className={cn(
                  'flex w-full items-center gap-2 px-4 py-2 text-sm transition-colors hover:bg-accent',
                  currentLocale === lang.code && 'bg-accent'
                )}
              >
                <span>{lang.flag}</span>
                <span>{lang.name}</span>
              </button>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
