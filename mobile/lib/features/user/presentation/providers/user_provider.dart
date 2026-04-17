import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/book_model.dart';

// 用户状态
class UserState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;
  final User? user;
  final List<Book> collectBooks;
  final List<Bookmark> bookmarks;
  final List<Note> notes;
  
  UserState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.error,
    this.user,
    this.collectBooks = const [],
    this.bookmarks = const [],
    this.notes = const [],
  });
  
  bool get isVip => user?.isVip ?? false;
  
  UserState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
    User? user,
    List<Book>? collectBooks,
    List<Bookmark>? bookmarks,
    List<Note>? notes,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error,
      user: user ?? this.user,
      collectBooks: collectBooks ?? this.collectBooks,
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
    );
  }
}

// 用户 Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState()) {
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    // 模拟加载用户数据
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 实际应该从本地存储读取
    state = state.copyWith(
      isLoggedIn: true,
      user: User(
        id: 'user_1',
        username: 'reader2024',
        nickname: '阅读爱好者',
        avatarUrl: 'https://picsum.photos/seed/user1/200/200',
        email: 'reader@10kbooks.com',
        phone: '138****8888',
        vipLevel: 1,
        vipExpireTime: DateTime.now().add(const Duration(days: 365)),
        coinBalance: 500,
        readTime: 168,
        bookCount: 25,
        followingCount: 128,
        followerCount: 256,
        bio: '热爱阅读，品味人生',
        isAuthor: false,
        registerTime: DateTime.now().subtract(const Duration(days: 365)),
        lastLoginTime: DateTime.now(),
      ),
    );
  }
  
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟登录
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        nickname: username,
        avatarUrl: 'https://picsum.photos/seed/$username/200/200',
        email: '$username@10kbooks.com',
        phone: '',
        vipLevel: 0,
        coinBalance: 0,
        readTime: 0,
        bookCount: 0,
        followingCount: 0,
        followerCount: 0,
        bio: '',
        isAuthor: false,
        registerTime: DateTime.now(),
        lastLoginTime: DateTime.now(),
      );
      
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> register({
    required String username,
    required String password,
    required String nickname,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        nickname: nickname,
        avatarUrl: 'https://picsum.photos/seed/$username/200/200',
        email: email ?? '',
        phone: '',
        vipLevel: 0,
        coinBalance: 100, // 新用户赠送书币
        readTime: 0,
        bookCount: 0,
        followingCount: 0,
        followerCount: 0,
        bio: '',
        isAuthor: false,
        registerTime: DateTime.now(),
        lastLoginTime: DateTime.now(),
      );
      
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void logout() {
    state = UserState();
  }
  
  Future<void> updateProfile({
    String? nickname,
    String? bio,
    String? avatarUrl,
  }) async {
    if (state.user == null) return;
    
    state = state.copyWith(
      user: state.user!.copyWith(
        nickname: nickname ?? state.user!.nickname,
        bio: bio ?? state.user!.bio,
        avatarUrl: avatarUrl ?? state.user!.avatarUrl,
      ),
    );
  }
  
  Future<void> recharge(int amount) async {
    if (state.user == null) return;
    
    // 模拟充值
    final coinAmount = amount * 10; // 1元 = 10书币
    state = state.copyWith(
      user: state.user!.copyWith(
        coinBalance: state.user!.coinBalance + coinAmount,
      ),
    );
  }
  
  Future<void> purchaseVip(int level) async {
    if (state.user == null) return;
    
    // 模拟购买 VIP
    state = state.copyWith(
      user: state.user!.copyWith(
        vipLevel: level,
        vipExpireTime: DateTime.now().add(const Duration(days: 365)),
      ),
    );
  }
  
  void collectBook(Book book) {
    if (!state.collectBooks.any((b) => b.id == book.id)) {
      state = state.copyWith(
        collectBooks: [...state.collectBooks, book],
        user: state.user?.copyWith(
          bookCount: (state.user?.bookCount ?? 0) + 1,
        ),
      );
    }
  }
  
  void uncollectBook(String bookId) {
    state = state.copyWith(
      collectBooks: state.collectBooks.where((b) => b.id != bookId).toList(),
      user: state.user?.copyWith(
        bookCount: (state.user?.bookCount ?? 1) - 1,
      ),
    );
  }
}
