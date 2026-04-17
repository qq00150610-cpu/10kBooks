import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/book_model.dart';

// 阅读器主题
class ReaderTheme {
  final Color backgroundColor;
  final Color textColor;
  
  const ReaderTheme({
    required this.backgroundColor,
    required this.textColor,
  });
  
  static const ReaderTheme defaultTheme = ReaderTheme(
    backgroundColor: Color(0xFFFFF8E1),
    textColor: Color(0xFF5D4037),
  );
}

// 阅读器状态
class ReaderState {
  final bool isLoading;
  final String? error;
  final Book? book;
  final List<Chapter> chapters;
  final Chapter? currentChapter;
  final int currentChapterIndex;
  final int totalChapters;
  final ReaderTheme readerTheme;
  final double fontSize;
  final double lineHeight;
  final double brightness;
  final bool autoBrightness;
  final String pageMode;
  final List<Bookmark> bookmarks;
  final ScrollController scrollController;
  
  ReaderState({
    this.isLoading = false,
    this.error,
    this.book,
    this.chapters = const [],
    this.currentChapter,
    this.currentChapterIndex = 1,
    this.totalChapters = 0,
    this.readerTheme = ReaderTheme.defaultTheme,
    this.fontSize = 16,
    this.lineHeight = 1.8,
    this.brightness = 0.5,
    this.autoBrightness = false,
    this.pageMode = 'scroll',
    this.bookmarks = const [],
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController();
  
  ReaderState copyWith({
    bool? isLoading,
    String? error,
    Book? book,
    List<Chapter>? chapters,
    Chapter? currentChapter,
    int? currentChapterIndex,
    int? totalChapters,
    ReaderTheme? readerTheme,
    double? fontSize,
    double? lineHeight,
    double? brightness,
    bool? autoBrightness,
    String? pageMode,
    List<Bookmark>? bookmarks,
    ScrollController? scrollController,
  }) {
    return ReaderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      book: book ?? this.book,
      chapters: chapters ?? this.chapters,
      currentChapter: currentChapter ?? this.currentChapter,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      totalChapters: totalChapters ?? this.totalChapters,
      readerTheme: readerTheme ?? this.readerTheme,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      brightness: brightness ?? this.brightness,
      autoBrightness: autoBrightness ?? this.autoBrightness,
      pageMode: pageMode ?? this.pageMode,
      bookmarks: bookmarks ?? this.bookmarks,
      scrollController: scrollController ?? this.scrollController,
    );
  }
}

// 阅读器 Provider
final readerProvider = StateNotifierProvider<ReaderNotifier, ReaderState>((ref) {
  return ReaderNotifier();
});

class ReaderNotifier extends StateNotifier<ReaderState> {
  ReaderNotifier() : super(ReaderState());
  
  Future<void> loadBook(String bookId) async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 模拟书籍数据
      final book = Book(
        id: bookId,
        title: '逆天改命',
        author: '天蚕土豆',
        coverUrl: 'https://picsum.photos/seed/$bookId/200/300',
        description: '热血玄幻小说',
        category: '玄幻',
        chapterCount: 500,
        wordCount: 1000000,
        rating: 4.5,
        viewCount: 10000000,
        collectCount: 500000,
        isVipOnly: false,
        isCompleted: false,
        publishDate: DateTime.now(),
        tags: ['玄幻', '热血'],
        language: 'zh',
      );
      
      final chapters = _generateMockChapters(bookId, 500);
      
      state = state.copyWith(
        isLoading: false,
        book: book,
        chapters: chapters,
        totalChapters: chapters.length,
        currentChapter: chapters.isNotEmpty ? chapters[0] : null,
        currentChapterIndex: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void goToChapter(int index) {
    if (index < 1 || index > state.totalChapters) return;
    
    final chapter = state.chapters.firstWhere(
      (c) => c.index == index,
      orElse: () => state.chapters.first,
    );
    
    state = state.copyWith(
      currentChapter: chapter,
      currentChapterIndex: index,
    );
    
    // 滚动到顶部
    state.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  
  void nextChapter() {
    if (state.currentChapterIndex < state.totalChapters) {
      goToChapter(state.currentChapterIndex + 1);
    }
  }
  
  void prevChapter() {
    if (state.currentChapterIndex > 1) {
      goToChapter(state.currentChapterIndex - 1);
    }
  }
  
  void setFontSize(double size) {
    if (size >= 12 && size <= 32) {
      state = state.copyWith(fontSize: size);
    }
  }
  
  void setLineHeight(double height) {
    if (height >= 1.2 && height <= 2.0) {
      state = state.copyWith(lineHeight: height);
    }
  }
  
  void setBrightness(double brightness) {
    if (brightness >= 0 && brightness <= 1) {
      state = state.copyWith(brightness: brightness);
    }
  }
  
  void setAutoBrightness(bool auto) {
    state = state.copyWith(autoBrightness: auto);
  }
  
  void setReaderTheme(Color backgroundColor, Color textColor) {
    state = state.copyWith(
      readerTheme: ReaderTheme(
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
    );
  }
  
  void togglePageMode() {
    state = state.copyWith(
      pageMode: state.pageMode == 'scroll' ? 'cover' : 'scroll',
    );
  }
  
  void addBookmark(String note) {
    if (state.currentChapter == null || state.book == null) return;
    
    final bookmark = Bookmark(
      id: 'bookmark_${DateTime.now().millisecondsSinceEpoch}',
      bookId: state.book!.id,
      chapterId: state.currentChapter!.id,
      chapterTitle: state.currentChapter!.title,
      position: 0,
      note: note,
      createTime: DateTime.now(),
    );
    
    state = state.copyWith(
      bookmarks: [...state.bookmarks, bookmark],
    );
  }
  
  void removeBookmark(String bookmarkId) {
    state = state.copyWith(
      bookmarks: state.bookmarks.where((b) => b.id != bookmarkId).toList(),
    );
  }
  
  void downloadChapter() {
    // 实现下载逻辑
  }
  
  List<Chapter> _generateMockChapters(String bookId, int count) {
    return List.generate(count, (index) {
      return Chapter(
        id: 'chapter_${bookId}_$index',
        bookId: bookId,
        index: index + 1,
        title: '第${_toChineseNumber(index + 1)}章',
        wordCount: 3000 + (index * 100),
        isVip: index > 50 && index % 10 == 0,
        publishDate: DateTime.now().subtract(Duration(days: count - index)),
        content: '', // 内容在阅读器中动态生成
      );
    });
  }
  
  String _toChineseNumber(int number) {
    const units = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    
    if (number <= 10) {
      return units[number];
    } else if (number < 20) {
      return '十${units[number - 10]}';
    } else if (number < 100) {
      final tens = number ~/ 10;
      final ones = number % 10;
      return '${units[tens]}十${ones > 0 ? units[ones] : ''}';
    } else {
      return '$number';
    }
  }
}
