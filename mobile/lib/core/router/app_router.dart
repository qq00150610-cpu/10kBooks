import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/bookstore/presentation/screens/bookstore_screen.dart';
import '../../features/bookshelf/presentation/screens/bookshelf_screen.dart';
import '../../features/user/presentation/screens/user_screen.dart';
import '../../features/reader/presentation/screens/reader_screen.dart';
import '../../features/user/presentation/screens/login_screen.dart';
import '../../features/user/presentation/screens/register_screen.dart';
import '../../features/user/presentation/screens/vip_screen.dart';
import '../../features/user/presentation/screens/settings_screen.dart';
import '../../features/author/presentation/screens/author_center_screen.dart';
import '../../features/author/presentation/screens/author_book_edit_screen.dart';
import '../../features/social/presentation/screens/social_screen.dart';
import '../../features/social/presentation/screens/user_profile_screen.dart';
import '../widgets/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // 主页面（底部导航）
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/bookstore',
            name: 'bookstore',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookstoreScreen(),
            ),
          ),
          GoRoute(
            path: '/bookshelf',
            name: 'bookshelf',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookshelfScreen(),
            ),
          ),
          GoRoute(
            path: '/user',
            name: 'user',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UserScreen(),
            ),
          ),
        ],
      ),
      
      // 阅读器
      GoRoute(
        path: '/reader/:bookId',
        name: 'reader',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          final chapterId = state.queryParameters['chapterId'];
          return ReaderScreen(bookId: bookId, chapterId: chapterId);
        },
      ),
      
      // 书籍详情
      GoRoute(
        path: '/book/:bookId',
        name: 'bookDetail',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return BookDetailScreen(bookId: bookId);
        },
      ),
      
      // 登录
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 注册
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // VIP会员
      GoRoute(
        path: '/vip',
        name: 'vip',
        builder: (context, state) => const VipScreen(),
      ),
      
      // 设置
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // 作者中心
      GoRoute(
        path: '/author',
        name: 'author',
        builder: (context, state) => const AuthorCenterScreen(),
      ),
      
      // 作者书籍编辑
      GoRoute(
        path: '/author/book/:bookId',
        name: 'authorBookEdit',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return AuthorBookEditScreen(bookId: bookId);
        },
      ),
      
      // 社交
      GoRoute(
        path: '/social',
        name: 'social',
        builder: (context, state) => const SocialScreen(),
      ),
      
      // 个人主页
      GoRoute(
        path: '/profile/:userId',
        name: 'profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserProfileScreen(userId: userId);
        },
      ),
      
      // 搜索结果
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          final query = state.queryParameters['q'];
          return SearchResultScreen(query: query ?? '');
        },
      ),
      
      // 分类书籍列表
      GoRoute(
        path: '/category/:categoryId',
        name: 'category',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final categoryName = state.queryParameters['name'];
          return CategoryBooksScreen(
            categoryId: categoryId,
            categoryName: categoryName ?? '分类',
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '页面不存在',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.uri.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
});

// 占位组件（避免循环引用）
class BookDetailScreen extends StatelessWidget {
  final String bookId;
  const BookDetailScreen({Key? key, required this.bookId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('书籍详情')),
    body: Center(child: Text('Book ID: $bookId')),
  );
}

class SearchResultScreen extends StatelessWidget {
  final String query;
  const SearchResultScreen({Key? key, required this.query}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('搜索: $query')),
    body: Center(child: Text('Search: $query')),
  );
}

class CategoryBooksScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  const CategoryBooksScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(categoryName)),
    body: Center(child: Text('Category: $categoryName')),
  );
}
