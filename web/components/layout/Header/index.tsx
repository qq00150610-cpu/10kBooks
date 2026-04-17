'use client';

import * as React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Dropdown, DropdownItem, DropdownSeparator } from '@/components/ui/Dropdown';
import { useAuthStore } from '@/lib/store';
import {
  Search,
  BookOpen,
  User,
  LogOut,
  Settings,
  Crown,
  ChevronDown,
  Menu,
  X,
  Home,
  Compass,
  Users,
  BookMarked,
  PenTool,
} from 'lucide-react';

const NAV_ITEMS = [
  { href: '/', label: '首页', icon: Home },
  { href: '/rankings', label: '排行榜', icon: Compass },
  { href: '/category', label: '分类', icon: BookOpen },
  { href: '/community', label: '书友圈', icon: Users },
];

interface HeaderProps {
  locale?: string;
}

export function Header({ locale = 'zh' }: HeaderProps) {
  const pathname = usePathname();
  const { user, isAuthenticated, logout } = useAuthStore();
  const [isMenuOpen, setIsMenuOpen] = React.useState(false);
  const [isSearchOpen, setIsSearchOpen] = React.useState(false);
  const [searchQuery, setSearchQuery] = React.useState('');

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      window.location.href = `/${locale}/search?q=${encodeURIComponent(searchQuery)}`;
    }
  };

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        {/* Logo */}
        <Link href={`/${locale}`} className="flex items-center gap-2">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-secondary text-white">
            <BookMarked className="h-6 w-6" />
          </div>
          <span className="hidden text-xl font-bold sm:block gradient-text">万卷书苑</span>
        </Link>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center gap-6">
          {NAV_ITEMS.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-2 text-sm font-medium transition-colors hover:text-primary',
                  isActive ? 'text-primary' : 'text-muted-foreground'
                )}
              >
                <Icon className="h-4 w-4" />
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Right Section */}
        <div className="flex items-center gap-3">
          {/* Search Button */}
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setIsSearchOpen(!isSearchOpen)}
            className="hidden sm:flex"
          >
            <Search className="h-5 w-5" />
          </Button>

          {/* Mobile Search Toggle */}
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setIsSearchOpen(!isSearchOpen)}
            className="sm:hidden"
          >
            <Search className="h-5 w-5" />
          </Button>

          {isAuthenticated && user ? (
            <Dropdown
              trigger={
                <button className="flex items-center gap-2 rounded-full p-1 hover:bg-accent transition-colors">
                  <Avatar
                    src={user.avatar}
                    alt={user.username}
                    size="sm"
                    status={user.role === 'online' ? 'online' : undefined}
                  />
                  <ChevronDown className="h-4 w-4 text-muted-foreground" />
                </button>
              }
              align="right"
            >
              <div className="px-3 py-2">
                <p className="font-medium">{user.username}</p>
                <p className="text-xs text-muted-foreground">{user.email}</p>
              </div>
              <DropdownSeparator />
              <DropdownItem icon={<User className="h-4 w-4" />} href={`/${locale}/profile`}>
                个人中心
              </DropdownItem>
              <DropdownItem icon={<BookMarked className="h-4 w-4" />} href={`/${locale}/bookshelf`}>
                我的书架
              </DropdownItem>
              {user.role === 'author' && (
                <DropdownItem icon={<PenTool className="h-4 w-4" />} href={`/${locale}/author`}>
                  作者中心
                </DropdownItem>
              )}
              {user.role === 'admin' && (
                <DropdownItem icon={<Settings className="h-4 w-4" />} href={`/${locale}/admin`}>
                  管理后台
                </DropdownItem>
              )}
              <DropdownSeparator />
              <DropdownItem
                icon={<Crown className="h-4 w-4" />}
                href={`/${locale}/vip`}
                className="text-amber-600"
              >
                会员中心
              </DropdownItem>
              <DropdownItem icon={<Settings className="h-4 w-4" />} href={`/${locale}/settings`}>
                设置
              </DropdownItem>
              <DropdownSeparator />
              <DropdownItem icon={<LogOut className="h-4 w-4" />} onClick={logout} danger>
                退出登录
              </DropdownItem>
            </Dropdown>
          ) : (
            <div className="flex items-center gap-2">
              <Button variant="ghost" asChild>
                <Link href={`/${locale}/login`}>登录</Link>
              </Button>
              <Button variant="default" asChild className="hidden sm:flex">
                <Link href={`/${locale}/register`}>注册</Link>
              </Button>
            </div>
          )}

          {/* Mobile Menu Toggle */}
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            className="md:hidden"
          >
            {isMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </Button>
        </div>
      </div>

      {/* Search Bar */}
      {isSearchOpen && (
        <div className="border-t p-4 animate-in slide-in-from-top duration-200">
          <form onSubmit={handleSearch} className="container mx-auto">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-muted-foreground" />
              <input
                type="text"
                placeholder="搜索书名、作者..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full rounded-lg border bg-background py-2.5 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                autoFocus
              />
            </div>
          </form>
        </div>
      )}

      {/* Mobile Menu */}
      {isMenuOpen && (
        <div className="border-t md:hidden animate-in slide-in-from-top duration-200">
          <nav className="container mx-auto p-4 space-y-2">
            {NAV_ITEMS.map((item) => {
              const Icon = item.icon;
              const isActive = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                    isActive
                      ? 'bg-primary text-primary-foreground'
                      : 'hover:bg-accent hover:text-accent-foreground'
                  )}
                  onClick={() => setIsMenuOpen(false)}
                >
                  <Icon className="h-5 w-5" />
                  {item.label}
                </Link>
              );
            })}
          </nav>
        </div>
      )}
    </header>
  );
}
