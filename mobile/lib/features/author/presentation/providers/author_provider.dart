import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/book_model.dart';
import '../../../../core/models/user_model.dart';

// 作者模型
class Author {
  final String id;
  final String nickname;
  final String avatarUrl;
  final int level;
  final int totalWords;
  final int fans;
  
  Author({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
    required this.level,
    required this.totalWords,
    required this.fans,
  });
  
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      level: json['level'] ?? 1,
      totalWords: json['total_words'] ?? 0,
      fans: json['fans'] ?? 0,
    );
  }
}

// 作者状态
class AuthorState {
  final bool isLoading;
  final String? error;
  final Author? author;
  final List<Book> books;
  final int todayViews;
  final int todayNewFollowers;
  final double todayEarnings;
  final int totalViews;
  final int totalCollects;
  final int totalComments;
  final double totalEarnings;
  final double balance;
  
  AuthorState({
    this.isLoading = false,
    this.error,
    this.author,
    this.books = const [],
    this.todayViews = 0,
    this.todayNewFollowers = 0,
    this.todayEarnings = 0,
    this.totalViews = 0,
    this.totalCollects = 0,
    this.totalComments = 0,
    this.totalEarnings = 0,
    this.balance = 0,
  });
  
  AuthorState copyWith({
    bool? isLoading,
    String? error,
    Author? author,
    List<Book>? books,
    int? todayViews,
    int? todayNewFollowers,
    double? todayEarnings,
    int? totalViews,
    int? totalCollects,
    int? totalComments,
    double? totalEarnings,
    double? balance,
  }) {
    return AuthorState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      author: author ?? this.author,
      books: books ?? this.books,
      todayViews: todayViews ?? this.todayViews,
      todayNewFollowers: todayNewFollowers ?? this.todayNewFollowers,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      totalViews: totalViews ?? this.totalViews,
      totalCollects: totalCollects ?? this.totalCollects,
      totalComments: totalComments ?? this.totalComments,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      balance: balance ?? this.balance,
    );
  }
}

// 作者 Provider
final authorProvider = StateNotifierProvider<AuthorNotifier, AuthorState>((ref) {
  return AuthorNotifier();
});

class AuthorNotifier extends StateNotifier<AuthorState> {
  AuthorNotifier() : super(AuthorState()) {
    _init();
  }
  
  Future<void> _init() async {
    // 模拟加载作者数据
    await Future.delayed(const Duration(milliseconds: 500));
    
    state = state.copyWith(
      author: Author(
        id: 'author_1',
        nickname: '写作新手',
        avatarUrl: 'https://picsum.photos/seed/author/200/200',
        level: 3,
        totalWords: 500000,
        fans: 1000,
      ),
      books: _generateMockBooks(3),
      todayViews: 1256,
      todayNewFollowers: 35,
      todayEarnings: 23.50,
      totalViews: 500000,
      totalCollects: 5000,
      totalComments: 200,
      totalEarnings: 230.00,
      balance: 230.00,
    );
  }
  
  Future<void> loadAuthorData() async {
    await _init();
  }
  
  Future<void> createBook({
    required String title,
    required String category,
    required String description,
    required bool isVip,
  }) async {
    final newBook = Book(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      author: state.author?.nickname ?? '未知',
      coverUrl: 'https://picsum.photos/seed/newbook/200/300',
      description: description,
      category: category,
      chapterCount: 0,
      wordCount: 0,
      rating: 0,
      viewCount: 0,
      collectCount: 0,
      isVipOnly: isVip,
      isCompleted: false,
      publishDate: DateTime.now(),
      tags: [],
      language: 'zh',
    );
    
    state = state.copyWith(
      books: [...state.books, newBook],
    );
  }
  
  Future<void> updateBook(Book book) async {
    final updatedBooks = state.books.map((b) {
      if (b.id == book.id) {
        return book;
      }
      return b;
    }).toList();
    
    state = state.copyWith(books: updatedBooks);
  }
  
  Future<void> publishChapter({
    required String bookId,
    required String title,
    required String content,
    required bool isVip,
  }) async {
    final bookIndex = state.books.indexWhere((b) => b.id == bookId);
    if (bookIndex < 0) return;
    
    final book = state.books[bookIndex];
    final updatedBook = book.copyWith(
      chapterCount: book.chapterCount + 1,
      wordCount: book.wordCount + content.length,
    );
    
    final updatedBooks = List<Book>.from(state.books);
    updatedBooks[bookIndex] = updatedBook;
    
    state = state.copyWith(books: updatedBooks);
  }
  
  List<Book> _generateMockBooks(int count) {
    return List.generate(count, (index) {
      return Book(
        id: 'book_$index',
        title: ['逆天改命', '都市高手', '修仙之路'][index],
        author: state.author?.nickname ?? '作者',
        coverUrl: 'https://picsum.photos/seed/authorbook_$index/200/300',
        description: '精彩小说作品',
        category: ['玄幻', '都市', '仙侠'][index],
        chapterCount: 50 + index * 20,
        wordCount: 300000 + index * 100000,
        rating: 4.0 + (index * 0.2),
        viewCount: 100000 + index * 50000,
        collectCount: 5000 + index * 2000,
        isVipOnly: index % 2 == 0,
        isCompleted: index == 0,
        publishDate: DateTime.now().subtract(Duration(days: index * 30)),
        tags: ['热门', '推荐'],
        language: 'zh',
      );
    });
  }
}

// Book copyWith 扩展
extension BookCopyWith on Book {
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    String? description,
    String? category,
    int? chapterCount,
    int? wordCount,
    double? rating,
    int? viewCount,
    int? collectCount,
    bool? isVipOnly,
    bool? isCompleted,
    DateTime? publishDate,
    List<String>? tags,
    String? language,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      chapterCount: chapterCount ?? this.chapterCount,
      wordCount: wordCount ?? this.wordCount,
      rating: rating ?? this.rating,
      viewCount: viewCount ?? this.viewCount,
      collectCount: collectCount ?? this.collectCount,
      isVipOnly: isVipOnly ?? this.isVipOnly,
      isCompleted: isCompleted ?? this.isCompleted,
      publishDate: publishDate ?? this.publishDate,
      tags: tags ?? this.tags,
      language: language ?? this.language,
    );
  }
}
