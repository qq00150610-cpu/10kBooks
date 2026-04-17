'use client';

import * as React from 'react';
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { Pagination } from '@/components/ui/Pagination';
import { useAuthStore } from '@/lib/store';
import {
  Bookmark,
  Trash2,
  Edit3,
  Clock,
  Plus,
} from 'lucide-react';
import { formatDate, cn } from '@/lib/utils';

const MOCK_BOOKMARKS = [
  {
    id: '1',
    book: {
      id: '1',
      title: '仙武帝尊',
      cover: 'https://picsum.photos/seed/book1/300/400',
    },
    chapter: { id: 'ch-1', title: '第51章 逆天改命', number: 51 },
    content: '这一世，他誓要登临绝顶，成为真正的武帝！',
    note: '这句话太燃了！',
    createdAt: '2024-01-21T10:30:00Z',
  },
  {
    id: '2',
    book: {
      id: '2',
      title: '都市逍遥医神',
      cover: 'https://picsum.photos/seed/book2/300/400',
    },
    chapter: { id: 'ch-2', title: '第120章 神医出手', number: 120 },
    content: '一代神医重生都市，左手惊天医术，右手霸道都市。',
    note: '',
    createdAt: '2024-01-20T15:20:00Z',
  },
  {
    id: '3',
    book: {
      id: '3',
      title: '庆余年',
      cover: 'https://picsum.photos/seed/book3/300/400',
    },
    chapter: { id: 'ch-3', title: '第89章 范闲的抉择', number: 89 },
    content: '积善之家，必有余庆，留余庆，留余庆，忽遇恩人...',
    note: '开篇名句',
    createdAt: '2024-01-19T20:00:00Z',
  },
];

export default function BookmarksPage() {
  const { isAuthenticated } = useAuthStore();
  const [bookmarks, setBookmarks] = React.useState(MOCK_BOOKMARKS);
  const [currentPage, setCurrentPage] = React.useState(1);

  const handleDelete = (id: string) => {
    setBookmarks(bookmarks.filter((b) => b.id !== id));
  };

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <Bookmark className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
          <p className="text-muted-foreground mb-4">登录后查看我的书签</p>
          <Button asChild>
            <Link href="/login">去登录</Link>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-muted/30">
      <div className="container mx-auto px-4 py-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold">我的书签</h1>
            <p className="text-sm text-muted-foreground">共 {bookmarks.length} 条书签</p>
          </div>
        </div>

        {bookmarks.length === 0 ? (
          <Card>
            <CardContent className="py-16 text-center">
              <Bookmark className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
              <h3 className="text-lg font-medium mb-2">暂无书签</h3>
              <p className="text-muted-foreground mb-4">在阅读时添加书签，方便下次继续</p>
              <Button asChild>
                <Link href="/category">浏览书籍</Link>
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-4">
            {bookmarks.map((bookmark) => (
              <Card key={bookmark.id} hover>
                <CardContent className="p-4">
                  <div className="flex gap-4">
                    <Link href={`/book/${bookmark.book.id}`}>
                      <div className="relative w-16 h-24 rounded-lg overflow-hidden shrink-0">
                        <img
                          src={bookmark.book.cover}
                          alt={bookmark.book.title}
                          className="w-full h-full object-cover"
                        />
                      </div>
                    </Link>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between">
                        <div>
                          <Link
                            href={`/book/${bookmark.book.id}`}
                            className="font-semibold hover:text-primary transition-colors"
                          >
                            {bookmark.book.title}
                          </Link>
                          <p className="text-sm text-muted-foreground mt-1">
                            {bookmark.chapter.title}
                          </p>
                        </div>
                        <div className="flex gap-1">
                          <Button variant="ghost" size="icon" asChild>
                            <Link href={`/read/${bookmark.book.id}/${bookmark.chapter.id}`}>
                              <Edit3 className="h-4 w-4" />
                            </Link>
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleDelete(bookmark.id)}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </div>

                      {/* Bookmark Content */}
                      <div className="mt-3 p-3 bg-muted/50 rounded-lg">
                        <p className="text-sm italic line-clamp-2">
                          "{bookmark.content}"
                        </p>
                        {bookmark.note && (
                          <p className="text-sm text-primary mt-2">
                            笔记: {bookmark.note}
                          </p>
                        )}
                      </div>

                      <div className="mt-3 flex items-center justify-between">
                        <span className="text-xs text-muted-foreground flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          {formatDate(bookmark.createdAt)}
                        </span>
                        <Button size="sm" asChild>
                          <Link href={`/read/${bookmark.book.id}/${bookmark.chapter.id}`}>
                            继续阅读
                          </Link>
                        </Button>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {bookmarks.length > 10 && (
          <div className="mt-8 flex justify-center">
            <Pagination
              currentPage={currentPage}
              totalPages={Math.ceil(bookmarks.length / 10)}
              onPageChange={setCurrentPage}
            />
          </div>
        )}
      </div>
    </div>
  );
}
