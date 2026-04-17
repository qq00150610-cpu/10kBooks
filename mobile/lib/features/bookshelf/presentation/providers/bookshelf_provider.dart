import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/book_model.dart';

// 书架状态
class BookshelfState {
  final bool isLoading;
  final String? error;
  final List<Book> myBooks;
  final List<Book> cachedBooks;
  final Map<String, double> readingProgress;
  final Set<String> selectedBooks;
  final String sortType;
  final int todayReadTime;
  final int totalReadTime;
  
  BookshelfState({
    this.isLoading = false,
    this.error,
    this.myBooks = const [],
    this.cachedBooks = const [],
    this.readingProgress = const {},
    this.selectedBooks = const {},
    this.sortType = 'recent',
    this.todayReadTime = 30,
    this.totalReadTime = 168,
  });
  
  BookshelfState copyWith({
    bool? isLoading,
    String? error,
    List<Book>? myBooks,
    List<Book>? cachedBooks,
    Map<String, double>? readingProgress,
    Set<String>? selectedBooks,
    String? sortType,
    int? todayReadTime,
    int? totalReadTime,
  }) {
    return BookshelfState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      myBooks: myBooks ?? this.myBooks,
      cachedBooks: cachedBooks ?? this.cachedBooks,
      readingProgress: readingProgress ?? this.readingProgress,
      selectedBooks: selectedBooks ?? this.selectedBooks,
      sortType: sortType ?? this.sortType,
      todayReadTime: todayReadTime ?? this.todayReadTime,
      totalReadTime: totalReadTime ?? this.totalReadTime,
    );
  }
}

// 书架 Provider
final bookshelfProvider =
    StateNotifierProvider<BookshelfNotifier, BookshelfState>((ref) {
  return BookshelfNotifier();
});

class BookshelfNotifier extends StateNotifier<BookshelfState> {
  BookshelfNotifier() : super(BookshelfState());
  
  Future<void> loadBookshelf() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final myBooks = _generateMockBooks(12);
      final cachedBooks = _generateMockBooks(5, isCached: true);
      
      // 模拟阅读进度
      final progress = <String, double>{};
      for (final book in myBooks) {
        progress[book.id] = (book.hashCode % 100) / 100;
      }
      
      state = state.copyWith(
        isLoading: false,
        myBooks: myBooks,
        cachedBooks: cachedBooks,
        readingProgress: progress,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void toggleBookSelection(String bookId) {
    final newSelection = Set<String>.from(state.selectedBooks);
    if (newSelection.contains(bookId)) {
      newSelection.remove(bookId);
    } else {
      newSelection.add(bookId);
    }
    state = state.copyWith(selectedBooks: newSelection);
  }
  
  void selectAll() {
    if (state.selectedBooks.length == state.myBooks.length) {
      state = state.copyWith(selectedBooks: {});
    } else {
      state = state.copyWith(
        selectedBooks: state.myBooks.map((b) => b.id).toSet(),
      );
    }
  }
  
  void deleteSelectedBooks() {
    final newBooks = state.myBooks
        .where((b) => !state.selectedBooks.contains(b.id))
        .toList();
    state = state.copyWith(
      myBooks: newBooks,
      selectedBooks: {},
    );
  }
  
  void removeCachedBook(String bookId) {
    final newCached = state.cachedBooks
        .where((b) => b.id != bookId)
        .toList();
    state = state.copyWith(cachedBooks: newCached);
  }
  
  void setSortType(String type) {
    state = state.copyWith(sortType: type);
    _sortBooks();
  }
  
  void _sortBooks() {
    final books = List<Book>.from(state.myBooks);
    
    switch (state.sortType) {
      case 'recent':
        // 按最近阅读排序（模拟）
        break;
      case 'title':
        books.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'added':
        // 按加入时间排序（模拟）
        break;
      case 'progress':
        books.sort((a, b) {
          final progressA = state.readingProgress[a.id] ?? 0;
          final progressB = state.readingProgress[b.id] ?? 0;
          return progressB.compareTo(progressA);
        });
        break;
    }
    
    state = state.copyWith(myBooks: books);
  }
  
  Future<void> downloadBook(String bookId) async {
    final book = state.myBooks.firstWhere((b) => b.id == bookId);
    if (!state.cachedBooks.any((b) => b.id == bookId)) {
      state = state.copyWith(
        cachedBooks: [...state.cachedBooks, book],
      );
    }
  }
  
  List<Book> _generateMockBooks(int count, {bool isCached = false}) {
    final categories = ['小说', '言情', '玄幻', '都市', '科幻', '悬疑'];
    final titles = [
      '逆天改命', '总裁的替身娇妻', '仙武帝尊', '都市全能高手',
      '星际探险', '暗夜追踪', '大唐双龙传', '朱元璋传',
      '三体', '活着', '平凡的世界', '围城', '元尊', '完美世界',
      '凡人修仙传', '庆余年', '全职高手', '雪中悍刀行',
    ];
    final authors = [
      '天蚕土豆', '顾漫', '我吃西红柿', '鱼人二代',
      '刘慈欣', '余华', '莫言', '钱钟书',
    ];
    
    return List.generate(count, (index) {
      return Book(
        id: isCached ? 'cached_$index' : 'mybook_$index',
        title: titles[index % titles.length],
        author: authors[index % authors.length],
        coverUrl: 'https://picsum.photos/seed/mybook_$index/200/300',
        description: '这是一本精彩的${categories[index % categories.length]}作品...',
        category: categories[index % categories.length],
        chapterCount: 100 + index * 10,
        wordCount: 500000 + index * 100000,
        rating: 4.0 + (index % 10) * 0.1,
        viewCount: 1000000 + index * 100000,
        collectCount: 10000 + index * 1000,
        isVipOnly: index % 3 == 0,
        isCompleted: index % 2 == 0,
        publishDate: DateTime.now().subtract(Duration(days: index * 7)),
        tags: ['热门', '推荐'],
        language: 'zh',
      );
    });
  }
}
