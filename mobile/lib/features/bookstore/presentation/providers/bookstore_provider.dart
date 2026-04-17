import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/book_model.dart';

// 书城状态
class BookstoreState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final List<Book> selectedBooks;
  final List<Book> rankingBooks;
  final List<Book> completedBooks;
  final String rankingType;
  final int currentPage;
  final bool hasMore;
  
  BookstoreState({
    this.isLoading = false,
    this.error,
    this.categories = const [],
    this.selectedCategory = '',
    this.selectedBooks = const [],
    this.rankingBooks = const [],
    this.completedBooks = const [],
    this.rankingType = '热度',
    this.currentPage = 1,
    this.hasMore = true,
  });
  
  BookstoreState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? categories,
    String? selectedCategory,
    List<Book>? selectedBooks,
    List<Book>? rankingBooks,
    List<Book>? completedBooks,
    String? rankingType,
    int? currentPage,
    bool? hasMore,
  }) {
    return BookstoreState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedBooks: selectedBooks ?? this.selectedBooks,
      rankingBooks: rankingBooks ?? this.rankingBooks,
      completedBooks: completedBooks ?? this.completedBooks,
      rankingType: rankingType ?? this.rankingType,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// 书城 Provider
final bookstoreProvider =
    StateNotifierProvider<BookstoreNotifier, BookstoreState>((ref) {
  return BookstoreNotifier();
});

class BookstoreNotifier extends StateNotifier<BookstoreState> {
  BookstoreNotifier() : super(BookstoreState());
  
  Future<void> loadCategories() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final categories = [
        {'id': 'fiction', 'name': '小说'},
        {'id': 'romance', 'name': '言情'},
        {'id': 'fantasy', 'name': '玄幻'},
        {'id': 'urban', 'name': '都市'},
        {'id': 'sci-fi', 'name': '科幻'},
        {'id': 'mystery', 'name': '悬疑'},
        {'id': 'history', 'name': '历史'},
        {'id': 'biography', 'name': '传记'},
        {'id': 'self-help', 'name': '自我提升'},
        {'id': 'business', 'name': '商业'},
      ];
      
      state = state.copyWith(
        isLoading: false,
        categories: categories,
        selectedCategory: categories.isNotEmpty ? categories[0]['id'] : '',
      );
      
      // 加载选中分类的书籍
      if (categories.isNotEmpty) {
        await loadBooksByCategory(categories[0]['id']);
      }
      
      // 加载排行榜
      await loadRankingBooks();
      
      // 加载完本
      await loadCompletedBooks();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> selectCategory(String categoryId) async {
    if (state.selectedCategory == categoryId) return;
    
    state = state.copyWith(selectedCategory: categoryId);
    await loadBooksByCategory(categoryId);
  }
  
  Future<void> loadBooksByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final books = _generateMockBooks(categoryId, 18);
      
      state = state.copyWith(
        isLoading: false,
        selectedBooks: books,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<void> setRankingType(String type) async {
    if (state.rankingType == type) return;
    
    state = state.copyWith(rankingType: type, isLoading: true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final books = _generateMockBooks('ranking', 20);
      
      state = state.copyWith(
        isLoading: false,
        rankingBooks: books,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<void> loadRankingBooks() async {
    try {
      final books = _generateMockBooks('ranking', 20);
      state = state.copyWith(rankingBooks: books);
    } catch (e) {
      // 忽略错误
    }
  }
  
  Future<void> loadCompletedBooks() async {
    try {
      final books = _generateMockBooks('completed', 30);
      state = state.copyWith(completedBooks: books);
    } catch (e) {
      // 忽略错误
    }
  }
  
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final newBooks = _generateMockBooks(
        state.selectedCategory,
        10,
        offset: state.selectedBooks.length,
      );
      
      state = state.copyWith(
        isLoading: false,
        selectedBooks: [...state.selectedBooks, ...newBooks],
        currentPage: state.currentPage + 1,
        hasMore: newBooks.length >= 10,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  List<Book> _generateMockBooks(String categoryId, int count, {int offset = 0}) {
    final categories = ['小说', '言情', '玄幻', '都市', '科幻', '悬疑', '历史'];
    final titles = [
      '逆天改命', '总裁的替身娇妻', '仙武帝尊', '都市全能高手',
      '星际探险', '暗夜追踪', '大唐双龙传', '朱元璋传',
      '三体', '活着', '平凡的世界', '围城', '斗破苍穹', '完美世界',
      '凡人修仙传', '庆余年', '全职高手', '雪中悍刀行', '择天记', '大主宰',
      '元尊', '万古最强宗', '无敌剑域', '太古神王', '修罗武神',
    ];
    final authors = [
      '天蚕土豆', '顾漫', '我吃西红柿', '鱼人二代',
      '刘慈欣', '余华', '莫言', '钱钟书', '辰东', '耳根',
      '猫腻', '蝴蝶蓝', '烽火戏诸侯', '鹅是老周', '梦入神机',
    ];
    
    return List.generate(count, (index) {
      final i = index + offset;
      return Book(
        id: 'book_${categoryId}_$i',
        title: titles[i % titles.length],
        author: authors[i % authors.length],
        coverUrl: 'https://picsum.photos/seed/${categoryId}_$i/200/300',
        description: '这是一本精彩的${categories[i % categories.length]}作品...',
        category: categories[i % categories.length],
        chapterCount: 100 + i * 10,
        wordCount: 500000 + i * 100000,
        rating: 4.0 + (i % 10) * 0.1,
        viewCount: 1000000 + i * 100000,
        collectCount: 10000 + i * 1000,
        isVipOnly: i % 3 == 0,
        isCompleted: categoryId == 'completed' || i % 5 == 0,
        publishDate: DateTime.now().subtract(Duration(days: i * 7)),
        tags: ['热门', '推荐'],
        language: 'zh',
      );
    });
  }
}
