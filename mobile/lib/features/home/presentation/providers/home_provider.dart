import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/book_model.dart';

// 首页状态
class HomeState {
  final bool isLoading;
  final String? error;
  final List<Book> bannerBooks;
  final List<Book> hotBooks;
  final List<Book> newBooks;
  final List<Book> recommendedBooks;
  final List<Book> forYouBooks;
  
  HomeState({
    this.isLoading = false,
    this.error,
    this.bannerBooks = const [],
    this.hotBooks = const [],
    this.newBooks = const [],
    this.recommendedBooks = const [],
    this.forYouBooks = const [],
  });
  
  HomeState copyWith({
    bool? isLoading,
    String? error,
    List<Book>? bannerBooks,
    List<Book>? hotBooks,
    List<Book>? newBooks,
    List<Book>? recommendedBooks,
    List<Book>? forYouBooks,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      bannerBooks: bannerBooks ?? this.bannerBooks,
      hotBooks: hotBooks ?? this.hotBooks,
      newBooks: newBooks ?? this.newBooks,
      recommendedBooks: recommendedBooks ?? this.recommendedBooks,
      forYouBooks: forYouBooks ?? this.forYouBooks,
    );
  }
}

// 首页 Provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState());
  
  Future<void> loadHomeData() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 模拟加载数据
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟数据
      final bannerBooks = _generateMockBooks(5);
      final hotBooks = _generateMockBooks(10);
      final newBooks = _generateMockBooks(8);
      final recommendedBooks = _generateMockBooks(6);
      final forYouBooks = _generateMockBooks(10);
      
      state = state.copyWith(
        isLoading: false,
        bannerBooks: bannerBooks,
        hotBooks: hotBooks,
        newBooks: newBooks,
        recommendedBooks: recommendedBooks,
        forYouBooks: forYouBooks,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> refresh() async {
    await loadHomeData();
  }
  
  List<Book> _generateMockBooks(int count) {
    final categories = ['小说', '言情', '玄幻', '都市', '科幻', '悬疑', '历史'];
    final titles = [
      '逆天改命', '总裁的替身娇妻', '仙武帝尊', '都市全能高手',
      '星际探险', '暗夜追踪', '大唐双龙传', '朱元璋传',
      '三体', '活着', '平凡的世界', '围城'
    ];
    final authors = [
      '天蚕土豆', '顾漫', '我吃西红柿', '鱼人二代',
      '刘慈欣', '余华', '莫言', '钱钟书'
    ];
    
    return List.generate(count, (index) {
      return Book(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}_$index',
        title: titles[index % titles.length],
        author: authors[index % authors.length],
        coverUrl: 'https://picsum.photos/seed/${index + 1}/200/300',
        description: '这是一本精彩的书籍，讲述了...',
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
