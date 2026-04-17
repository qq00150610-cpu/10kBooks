'use client';

import * as React from 'react';
import { useParams, useRouter } from 'next/navigation';
import { Modal } from '@/components/ui/Modal';
import { Button } from '@/components/ui/Button';
import { ReaderSettings } from '@/components/reader/ReaderToolbar';
import { ChapterList } from '@/components/reader/ChapterList';
import { CommentSection } from '@/components/common/CommentSection';
import { Badge } from '@/components/ui/Badge';
import { useReaderStore } from '@/lib/store';
import {
  Bookmark,
  ChevronLeft,
  ChevronRight,
  Home,
  List,
  MessageCircle,
  Moon,
  Sun,
  Settings,
  Share2,
} from 'lucide-react';
import type { Chapter, Comment } from '@/lib/types';

// Mock data
const MOCK_CHAPTERS: Chapter[] = Array.from({ length: 150 }, (_, i) => ({
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
}));

const MOCK_CONTENT = `
夜幕降临，星辰点缀天际。

叶尘站在悬崖边，俯瞰着脚下的万丈深渊。三千年前，他被人陷害，陨落于此。

如今，他重生归来，誓要讨回公道。

"这一世，我不会再让任何人伤害我在乎的人。"

他握紧拳头，眼中闪过一抹坚定。

就在这时，一道光芒从天而降，落在他面前。光芒散去，露出一位白发老者的身影。

"叶尘，你可知道，你即将踏上的，是一条怎样的道路？"

老者问道。

叶尘沉默片刻，然后说道："无论怎样的道路，我都要走下去。因为，这是我唯一的选择。"

老者微微一笑："好，既然你有此决心，我便将《九转仙诀》传授于你。"

说着，他伸出手指，在叶尘眉心轻轻一点。

刹那间，无数的信息涌入叶尘脑海。那是修炼的功法，是仙界的奥秘，是三千年前的记忆。

"记住，九转仙诀，共分九重。第一重，炼体；第二重，凝气；第三重，筑基……"

老者的声音渐渐远去。

当叶尘再次睁开眼睛时，发现自己已经身处一片陌生的地方。四周是茂密的森林，空气中弥漫着淡淡的灵气。

"这里，就是修仙界吗？"

他喃喃自语。

叶尘深吸一口气，感受着体内流淌的力量。虽然还很微弱，但确实存在。

"从现在开始，我要开始修炼了。"

他找到一处隐蔽的山洞，盘膝而坐，开始按照《九转仙诀》的功法运转体内的力量。

灵气从四面八方汇聚而来，缓缓流入他的身体。

修炼无岁月。

不知过了多久，叶尘感觉到体内的力量终于稳定下来。虽然只是刚刚入门，但相比之前的凡人，已经有了天壤之别。

"第一重，炼体，终于完成了。"

他睁开眼睛，眼中闪过一抹喜悦。

就在这时，山洞外传来一阵喧哗声。

"快看，那里有灵气波动！"

"难道有人在这里修炼？"

叶尘眉头一皱，站起身来。

只见山洞外站着几个年轻的修士，他们身上穿着统一的服饰，看起来像是某个门派的人。

"这位朋友，我们是天剑宗的弟子。请问你是……"

为首的一名修士开口问道。

叶尘淡淡说道："在下叶尘，只是一个散修而已。"

几名修士对视一眼，眼中闪过一丝疑惑。散修？在这种地方修炼的散修？

"既然是同道中人，不如随我们一起前往天剑宗？"

为首的修士邀请道。

叶尘想了想，点了点头。反正他现在也不知道该去哪里，不如先去天剑宗看看。

就这样，叶尘跟着几名天剑宗的弟子，踏上了前往天剑宗的道路。

他不知道的是，这一步，将彻底改变他的命运。

天剑宗，位于玄天山脉深处，是附近最大的修仙门派。门派中弟子众多，高手如云。

叶尘跟随几名弟子来到天剑宗山门之前，只见山门高耸入云，两侧刻着一副对联：

"剑指苍穹，斩尽天下不平事。"
"心怀正义，守护苍生万万年。"

"这里就是天剑宗了。"

为首的弟子说道。

叶尘抬头望去，心中涌起一股豪情。

"总有一天，我也要站在这个世界的巅峰。"

他暗暗发誓。

而此刻，他不知道的是，一双眼睛正在暗处注视着他。

那是一个身穿黑袍的老者，他的眼中闪烁着阴冷的光芒。

"叶尘？三千年前那个叛徒的徒弟？"

他喃喃自语。

"没想到，你居然还活着。"

"既然如此，那就让我送你一程吧。"

说完，他的身影消失在了黑暗中。

叶尘似乎感觉到了什么，回头望去，却什么也没有看到。

"怎么了？"

为首的弟子问道。

"没什么。"

叶尘摇了摇头，收回目光。

但他的心中，却涌起一股莫名的不安。

总觉得，有什么危险，正在靠近。
`.trim();

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
    targetType: 'chapter',
    targetId: 'chapter-1',
    content: '这段描写太精彩了！主角重生的设定很有看点！',
    likes: 234,
    isLiked: false,
    createdAt: '2024-01-15T10:00:00Z',
    updatedAt: '2024-01-15T10:00:00Z',
  },
];

export default function ReaderPage() {
  const params = useParams();
  const router = useRouter();
  const { bookId, chapterId } = params as { bookId: string; chapterId: string };
  
  const {
    settings,
    updateSettings,
    isToolbarVisible,
    toggleToolbar,
    bookmarks,
    addBookmark,
  } = useReaderStore();

  const [isChapterListOpen, setIsChapterListOpen] = React.useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = React.useState(false);
  const [isCommentOpen, setIsCommentOpen] = React.useState(false);
  const [currentChapterIndex, setCurrentChapterIndex] = React.useState(() => {
    const index = MOCK_CHAPTERS.findIndex((c) => c.id === chapterId);
    return index >= 0 ? index : 0;
  });

  const currentChapter = MOCK_CHAPTERS[currentChapterIndex];
  const isBookmarked = bookmarks.some(
    (b) => b.bookId === bookId && b.chapterId === currentChapter?.id
  );

  const handlePreviousChapter = () => {
    if (currentChapterIndex > 0) {
      const newChapter = MOCK_CHAPTERS[currentChapterIndex - 1];
      router.push(`/read/${bookId}/${newChapter.id}`);
      setCurrentChapterIndex(currentChapterIndex - 1);
    }
  };

  const handleNextChapter = () => {
    if (currentChapterIndex < MOCK_CHAPTERS.length - 1) {
      const newChapter = MOCK_CHAPTERS[currentChapterIndex + 1];
      router.push(`/read/${bookId}/${newChapter.id}`);
      setCurrentChapterIndex(currentChapterIndex + 1);
    }
  };

  const handleToggleBookmark = () => {
    if (!currentChapter) return;

    if (isBookmarked) {
      const bookmark = bookmarks.find(
        (b) => b.bookId === bookId && b.chapterId === currentChapter.id
      );
      if (bookmark) {
        // removeBookmark(bookmark.id);
      }
    } else {
      addBookmark({
        id: `bookmark-${Date.now()}`,
        userId: '',
        bookId,
        chapterId: currentChapter.id,
        position: 0,
        createdAt: new Date().toISOString(),
      });
    }
  };

  const handleChapterSelect = (chapter: Chapter) => {
    router.push(`/read/${bookId}/${chapter.id}`);
    setCurrentChapterIndex(MOCK_CHAPTERS.findIndex((c) => c.id === chapter.id));
    setIsChapterListOpen(false);
  };

  // Theme classes
  const themeClasses = {
    paper: 'bg-[#f5f5f0] text-[#333]',
    sepia: 'bg-[#f4ecd8] text-[#5b4636]',
    night: 'bg-[#1a1a2e] text-[#c4c4c4]',
    dark: 'bg-[#0f0f0f] text-[#e0e0e0]',
  };

  return (
    <div className="min-h-screen">
      {/* Top Bar */}
      <div
        className={`fixed top-0 left-0 right-0 z-50 bg-background/95 backdrop-blur border-b transition-transform duration-300 ${
          isToolbarVisible ? 'translate-y-0' : '-translate-y-full'
        }`}
      >
        <div className="flex h-14 items-center justify-between px-4">
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="icon" asChild>
              <a href="/">
                <Home className="h-5 w-5" />
              </a>
            </Button>
            <div className="hidden sm:block">
              <h1 className="font-medium line-clamp-1">仙武帝尊</h1>
              <p className="text-xs text-muted-foreground">{currentChapter?.title}</p>
            </div>
          </div>

          <div className="flex items-center gap-1">
            <Button
              variant="ghost"
              size="icon"
              onClick={handleToggleBookmark}
              className={isBookmarked ? 'text-amber-500' : ''}
            >
              <Bookmark className={`h-5 w-5 ${isBookmarked ? 'fill-current' : ''}`} />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setIsCommentOpen(true)}
            >
              <MessageCircle className="h-5 w-5" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setIsChapterListOpen(true)}
            >
              <List className="h-5 w-5" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              onClick={() =>
                updateSettings({
                  theme: settings.theme === 'night' || settings.theme === 'dark' ? 'paper' : 'night',
                })
              }
            >
              {settings.theme === 'night' || settings.theme === 'dark' ? (
                <Sun className="h-5 w-5" />
              ) : (
                <Moon className="h-5 w-5" />
              )}
            </Button>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setIsSettingsOpen(true)}
            >
              <Settings className="h-5 w-5" />
            </Button>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="h-1 bg-muted">
          <div
            className="h-full bg-primary transition-all duration-300"
            style={{
              width: `${((currentChapterIndex + 1) / MOCK_CHAPTERS.length) * 100}%`,
            }}
          />
        </div>
      </div>

      {/* Content */}
      <div
        className={`min-h-screen pt-16 pb-20 px-4 md:px-[15%] lg:px-[20%] overflow-y-auto transition-colors ${themeClasses[settings.theme]}`}
        style={{
          fontSize: `${settings.fontSize}px`,
          lineHeight: settings.lineHeight,
        }}
        onClick={() => toggleToolbar()}
      >
        <article className="max-w-3xl mx-auto py-8">
          {/* Chapter Title */}
          <h1 className="text-2xl font-bold mb-8 text-center">
            第{currentChapter?.number}章 {currentChapter?.title}
          </h1>

          {/* Chapter Content */}
          <div
            className="whitespace-pre-wrap leading-relaxed"
            style={{ lineHeight: settings.lineHeight }}
          >
            {MOCK_CONTENT.split('\n\n').map((paragraph, index) => (
              <p key={index} className="mb-4">
                {paragraph}
              </p>
            ))}
          </div>

          {/* Watermark */}
          <div className="mt-12 pt-8 border-t border-current/10">
            <p className="text-xs text-center opacity-30">
              万卷书苑 10kBooks · 尊重原创 · 请勿盗版
            </p>
          </div>
        </article>
      </div>

      {/* Bottom Navigation */}
      <div
        className={`fixed bottom-0 left-0 right-0 z-50 bg-background/95 backdrop-blur border-t transition-transform duration-300 ${
          isToolbarVisible ? 'translate-y-0' : 'translate-y-full'
        }`}
      >
        <div className="flex h-14 items-center justify-between px-4">
          <Button
            variant="outline"
            size="sm"
            onClick={handlePreviousChapter}
            disabled={currentChapterIndex <= 0}
          >
            <ChevronLeft className="h-4 w-4 mr-1" />
            上一章
          </Button>

          <div className="flex items-center gap-2">
            <span className="text-sm text-muted-foreground">
              {currentChapterIndex + 1} / {MOCK_CHAPTERS.length}
            </span>
          </div>

          <Button
            variant="outline"
            size="sm"
            onClick={handleNextChapter}
            disabled={currentChapterIndex >= MOCK_CHAPTERS.length - 1}
          >
            下一章
            <ChevronRight className="h-4 w-4 ml-1" />
          </Button>
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
          chapters={MOCK_CHAPTERS}
          currentChapterId={currentChapter?.id}
          bookId={bookId}
          freeChapterCount={30}
          onChapterClick={handleChapterSelect}
        />
      </Modal>

      {/* Settings Modal */}
      <ReaderSettings
        isOpen={isSettingsOpen}
        onClose={() => setIsSettingsOpen(false)}
      />

      {/* Comment Modal */}
      <Modal
        isOpen={isCommentOpen}
        onClose={() => setIsCommentOpen(false)}
        title="本章评论"
        size="md"
      >
        <CommentSection
          comments={MOCK_COMMENTS}
          total={MOCK_COMMENTS.length}
          placeholder="发表你对本章的看法..."
        />
      </Modal>
    </div>
  );
}
