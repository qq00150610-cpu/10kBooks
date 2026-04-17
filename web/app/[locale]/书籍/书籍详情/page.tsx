'use client';

import * as React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useParams, useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Card, CardContent } from '@/components/ui/Card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { Avatar } from '@/components/ui/Avatar';
import { Modal } from '@/components/ui/Modal';
import { BookCard } from '@/components/common/BookCard';
import { Rating } from '@/components/common/Rating';
import { CommentSection } from '@/components/common/CommentSection';
import { ChapterList } from '@/components/reader/ChapterList';
import { useAuthStore, useBookshelfStore } from '@/lib/store';
import {
  Star,
  Eye,
  BookOpen,
  Users,
  Calendar,
  ChevronDown,
  ChevronUp,
  Share2,
  Bookmark,
  Heart,
  MessageCircle,
  Crown,
  Play,
  Lock,
} from 'lucide-react';
import { formatNumber, formatDate, getReadingTime, cn } from '@/lib/utils';
import type { Book, Chapter, Comment } from '@/lib/types';

// Mock data
const MOCK_BOOK: Book = {
  id: '1',
  title: '仙武帝尊',
  cover: 'https://picsum.photos/seed/book1/300/400',
  author: {
    id: '1',
    name: '火星引力',
    avatar: 'https://picsum.photos/seed/author1/100/100',
  },
  category: '玄幻',
  subCategory: '东方玄幻',
  tags: ['东方玄幻', '热血', '修炼', '逆袭'],
  description: `三千年前，他被人陷害，生死之际，却意外获得绝世功法《九转仙诀》。

修炼路上，他历经磨难，从一个废物少爷成长为一代仙帝。

然而，仙界大战爆发，他陨落于仙魔之战。

三千年后，他重生于凡间，以凡人之躯，逆天改命，重新踏上修仙之路。

这一世，他誓要登临绝顶，成为真正的武帝！`,
  status: 'completed',
  wordCount: 8560000,
  viewCount: 125600000,
  likeCount: 890000,
  commentCount: 45600,
  subscribeCount: 125000,
  rating: 4.8,
  ratingCount: 89000,
  chapters: Array.from({ length: 150 }, (_, i) => ({
    id: `chapter-${i + 1}`,
    bookId: '1',
    title: `第${i + 1}章 ${['逆天改命', '初入仙门', '风云际会', '惊天秘密', '绝地反击'][i % 5]}`,
    number: i + 1,
    content: '',
    wordCount: 3000 + Math.floor(Math.random() * 2000),
    viewCount: Math.floor(Math.random() * 10000),
    likeCount: Math.floor(Math.random() * 500),
    isVip: i >= 30,
    isPaid: i >= 30,
    price: 10,
    status: 'published' as const,
    createdAt: '2020-01-01',
    updatedAt: '2024-01-15',
    publishedAt: '2020-01-01',
  })),
  createdAt: '2020-01-01',
  updatedAt: '2024-01-15',
  isVip: false,
  isPaid: false,
  freeChapterCount: 30,
};

const MOCK_COMMENTS: Comment[] = [
  {
    id: '1',
    userId: '1',
    user: {
      id: '1',
      username: '书虫小明',
      email: 'xiaoming@example.com',
      avatar: 'https://picsum.photos/seed/user1/100/100',
      role: 'user',
      vipLevel: 1,
      createdAt: '2023-01-01',
      stats: { followers: 100, following: 50, books: 0, chapters: 0 },
    },
    targetType: 'book',
    targetId: '1',
    content: '太好看了！主角逆袭的过程太燃了，每天追更新追得停不下来！',
    likes: 1234,
    isLiked: false,
    createdAt: '2024-01-10T10:00:00Z',
    updatedAt: '2024-01-10T10:00:00Z',
  },
  {
    id: '2',
    userId: '2',
    user: {
      id: '2',
      username: '阅读达人',
      email: 'reader@example.com',
      avatar: 'https://picsum.photos/seed/user2/100/100',
      role: 'user',
      vipLevel: 2,
      createdAt: '2023-02-01',
      stats: { followers: 500, following: 100, books: 0, chapters: 0 },
    },
    targetType: 'book',
    targetId: '1',
    content: '这本小说的世界观构建得很完整，人物塑造也很立体。强烈推荐！',
    likes: 567,
    isLiked: true,
    createdAt: '2024-01-09T15:30:00Z',
    updatedAt: '2024-01-09T15:30:00Z',
  },
];

export default function BookDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { user, isAuthenticated } = useAuthStore();
  const { books: bookshelfBooks, addBook, removeBook, isBookInShelf } = useBookshelfStore();

  const [isDescriptionExpanded, setIsDescriptionExpanded] = React.useState(false);
  const [isChapterListOpen, setIsChapterListOpen] = React.useState(false);
  const [isSubscribed, setIsSubscribed] = React.useState(false);
  const [isLiked, setIsLiked] = React.useState(false);

  const book = MOCK_BOOK;
  const inBookshelf = isBookInShelf(book.id);

  const handleReadChapter = (chapter?: Chapter) => {
    const targetChapter = chapter || book.chapters[0];
    router.push(`/read/${book.id}/${targetChapter.id}`);
  };

  const handleToggleBookmark = () => {
    if (inBookshelf) {
      removeBook(book.id);
    } else {
      addBook(book.id);
    }
  };

  const handleToggleLike = () => {
    setIsLiked(!isLiked);
  };

  const handleSubscribe = () => {
    setIsSubscribed(!isSubscribed);
  };

  return (
    <div className="min-h-screen bg-muted/30">
      {/* Hero Section */}
      <div className="relative bg-gradient-to-b from-primary/20 to-background">
        <div className="container mx-auto px-4 py-8">
          <div className="flex flex-col md:flex-row gap-8">
            {/* Cover */}
            <div className="shrink-0 mx-auto md:mx-0">
              <div className="relative w-48 aspect-[3/4] rounded-xl overflow-hidden shadow-2xl">
                <Image
                  src={book.cover}
                  alt={book.title}
                  fill
                  className="object-cover"
                />
                {book.isVip && (
                  <Badge className="absolute top-3 left-3" variant="premium">
                    VIP
                  </Badge>
                )}
              </div>
            </div>

            {/* Info */}
            <div className="flex-1">
              <div className="flex items-start justify-between">
                <div>
                  <h1 className="text-3xl font-bold">{book.title}</h1>
                  <div className="flex items-center gap-4 mt-2">
                    <Link
                      href={`/author/${book.author.id}`}
                      className="flex items-center gap-2 hover:text-primary transition-colors"
                    >
                      <Avatar src={book.author.avatar} alt={book.author.name} size="sm" />
                      <span>{book.author.name}</span>
                    </Link>
                    <Badge>{book.category}</Badge>
                    <Badge variant={book.status === 'completed' ? 'success' : 'default'}>
                      {book.status === 'completed' ? '已完结' : '连载中'}
                    </Badge>
                  </div>
                </div>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => {
                    // Share logic
                  }}
                >
                  <Share2 className="h-5 w-5" />
                </Button>
              </div>

              {/* Stats */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
                <div className="text-center p-3 bg-background/50 rounded-lg">
                  <p className="text-2xl font-bold text-primary">{book.rating.toFixed(1)}</p>
                  <p className="text-xs text-muted-foreground">评分</p>
                </div>
                <div className="text-center p-3 bg-background/50 rounded-lg">
                  <p className="text-2xl font-bold">{formatNumber(book.viewCount)}</p>
                  <p className="text-xs text-muted-foreground">浏览</p>
                </div>
                <div className="text-center p-3 bg-background/50 rounded-lg">
                  <p className="text-2xl font-bold">{formatNumber(book.subscribeCount)}</p>
                  <p className="text-xs text-muted-foreground">订阅</p>
                </div>
                <div className="text-center p-3 bg-background/50 rounded-lg">
                  <p className="text-2xl font-bold">{book.chapters.length}</p>
                  <p className="text-xs text-muted-foreground">章节</p>
                </div>
              </div>

              {/* Tags */}
              <div className="flex flex-wrap gap-2 mt-4">
                {book.tags.map((tag) => (
                  <Badge key={tag} variant="outline">
                    {tag}
                  </Badge>
                ))}
              </div>

              {/* Description */}
              <div className="mt-6">
                <p
                  className={cn(
                    'text-muted-foreground leading-relaxed',
                    !isDescriptionExpanded && 'line-clamp-3'
                  )}
                >
                  {book.description}
                </p>
                <button
                  onClick={() => setIsDescriptionExpanded(!isDescriptionExpanded)}
                  className="flex items-center gap-1 mt-2 text-sm text-primary hover:underline"
                >
                  {isDescriptionExpanded ? (
                    <>
                      收起
                      <ChevronUp className="h-4 w-4" />
                    </>
                  ) : (
                    <>
                     展开全部
                      <ChevronDown className="h-4 w-4" />
                    </>
                  )}
                </button>
              </div>

              {/* Actions */}
              <div className="flex flex-wrap gap-3 mt-6">
                <Button size="lg" onClick={() => handleReadChapter()} className="flex-1 sm:flex-none">
                  <Play className="h-5 w-5 mr-2" />
                  开始阅读
                </Button>
                <Button
                  size="lg"
                  variant="outline"
                  onClick={handleToggleBookmark}
                  className={cn(inBookshelf && 'text-primary border-primary')}
                >
                  <Bookmark className={cn('h-5 w-5 mr-2', inBookshelf && 'fill-current')} />
                  {inBookshelf ? '已加入书架' : '加入书架'}
                </Button>
                <Button
                  size="lg"
                  variant="outline"
                  onClick={handleSubscribe}
                  className={cn(isSubscribed && 'text-red-500 border-red-500')}
                >
                  <Heart className={cn('h-5 w-5 mr-2', isSubscribed && 'fill-current')} />
                  {isSubscribed ? '已收藏' : '收藏'}
                </Button>
              </div>

              {/* Free Chapters Info */}
              <Card className="mt-4 bg-primary/5 border-primary/20">
                <CardContent className="p-4">
                  <p className="text-sm">
                    <span className="text-primary font-medium">{book.freeChapterCount}</span> 章免费阅读
                    {book.chapters.length > book.freeChapterCount && (
                      <span className="text-muted-foreground ml-2">
                        VIP会员可阅读全部章节
                      </span>
                    )}
                  </p>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Column */}
          <div className="lg:col-span-2 space-y-6">
            <Tabs defaultValue="chapters">
              <TabsList className="w-full justify-start">
                <TabsTrigger value="chapters">目录</TabsTrigger>
                <TabsTrigger value="comments">评论</TabsTrigger>
                <TabsTrigger value="recommendations">相关推荐</TabsTrigger>
              </TabsList>

              <TabsContent value="chapters" className="mt-4">
                <div className="flex items-center justify-between mb-4">
                  <p className="text-sm text-muted-foreground">
                    共 {book.chapters.length} 章
                  </p>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setIsChapterListOpen(true)}
                  >
                    <BookOpen className="h-4 w-4 mr-2" />
                    目录
                  </Button>
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                  {book.chapters.slice(0, 12).map((chapter) => (
                    <button
                      key={chapter.id}
                      onClick={() => handleReadChapter(chapter)}
                      className={cn(
                        'text-left p-3 rounded-lg border transition-colors hover:border-primary/50 hover:bg-primary/5',
                        chapter.isVip && 'opacity-70'
                      )}
                    >
                      <p className="text-sm font-medium line-clamp-1">
                        第{chapter.number}章
                      </p>
                      <p className="text-xs text-muted-foreground line-clamp-1">
                        {chapter.title}
                      </p>
                      {chapter.isVip && (
                        <Lock className="h-3 w-3 text-muted-foreground mt-1" />
                      )}
                    </button>
                  ))}
                </div>
                {book.chapters.length > 12 && (
                  <div className="text-center mt-4">
                    <Button variant="outline" onClick={() => setIsChapterListOpen(true)}>
                      查看全部 {book.chapters.length} 章
                    </Button>
                  </div>
                )}
              </TabsContent>

              <TabsContent value="comments" className="mt-4">
                <CommentSection
                  comments={MOCK_COMMENTS}
                  total={book.commentCount}
                />
              </TabsContent>

              <TabsContent value="recommendations" className="mt-4">
                <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4">
                  {[1, 2, 3, 4, 5, 6].map((i) => (
                    <BookCard
                      key={i}
                      book={{
                        ...book,
                        id: `recommend-${i}`,
                        title: `推荐书籍${i}`,
                        cover: `https://picsum.photos/seed/recommend${i}/300/400`,
                      }}
                    />
                  ))}
                </div>
              </TabsContent>
            </Tabs>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Author Card */}
            <Card>
              <CardHeader>
                <CardTitle className="text-base">作者简介</CardTitle>
              </CardHeader>
              <CardContent>
                <Link
                  href={`/author/${book.author.id}`}
                  className="flex items-center gap-3 hover:text-primary transition-colors"
                >
                  <Avatar
                    src={book.author.avatar}
                    alt={book.author.name}
                    size="lg"
                  />
                  <div>
                    <p className="font-medium">{book.author.name}</p>
                    <p className="text-sm text-muted-foreground">签约作者</p>
                  </div>
                </Link>
                <div className="grid grid-cols-2 gap-4 mt-4 text-center">
                  <div>
                    <p className="font-bold">5</p>
                    <p className="text-xs text-muted-foreground">作品数</p>
                  </div>
                  <div>
                    <p className="font-bold">2.5亿</p>
                    <p className="text-xs text-muted-foreground">总字数</p>
                  </div>
                </div>
                <Button variant="outline" className="w-full mt-4" asChild>
                  <Link href={`/author/${book.author.id}`}>进入作者主页</Link>
                </Button>
              </CardContent>
            </Card>

            {/* Latest Chapters */}
            <Card>
              <CardHeader>
                <CardTitle className="text-base flex items-center justify-between">
                  最新章节
                  <Button variant="ghost" size="sm" asChild>
                    <Link href={`/book/${book.id}/chapters`}>更多</Link>
                  </Button>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {book.chapters.slice(-5).reverse().map((chapter) => (
                  <button
                    key={chapter.id}
                    onClick={() => handleReadChapter(chapter)}
                    className="flex w-full items-center justify-between text-left hover:text-primary transition-colors"
                  >
                    <span className="text-sm line-clamp-1">{chapter.title}</span>
                    <span className="text-xs text-muted-foreground ml-2 shrink-0">
                      {formatDate(chapter.updatedAt, 'MM-DD')}
                    </span>
                  </button>
                ))}
              </CardContent>
            </Card>

            {/* Book Stats */}
            <Card>
              <CardHeader>
                <CardTitle className="text-base">数据统计</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">总字数</span>
                  <span>{(book.wordCount / 10000).toFixed(0)}万</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">阅读人数</span>
                  <span>{formatNumber(book.viewCount)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">收藏人数</span>
                  <span>{formatNumber(book.subscribeCount)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">更新周期</span>
                  <span>每日更新</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>

      {/* Chapter List Modal */}
      <Modal
        isOpen={isChapterListOpen}
        onClose={() => setIsChapterListOpen(false)}
        title="目录"
        size="lg"
      >
        <ChapterList
          chapters={book.chapters}
          bookId={book.id}
          freeChapterCount={book.freeChapterCount}
          onChapterClick={(chapter) => {
            setIsChapterListOpen(false);
            handleReadChapter(chapter);
          }}
        />
      </Modal>
    </div>
  );
}
