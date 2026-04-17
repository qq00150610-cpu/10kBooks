import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_service.dart';
import '../../core/network/dio_client.dart';
import '../models/models.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(DioClient.instance);
});

// 首页数据 Provider
final homeBannersProvider = FutureProvider<List<Banner>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.homeBanners);
  final data = response.data['data'] as List;
  return data.map((e) => Banner.fromJson(e)).toList();
});

final homeHotBooksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.homeHotBooks, queryParameters: {'limit': 10});
  final data = response.data['data'] as List;
  return data.map((e) => Book.fromJson(e)).toList();
});

final homeNewBooksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.homeNewBooks, queryParameters: {'limit': 20});
  final data = response.data['data'] as List;
  return data.map((e) => Book.fromJson(e)).toList();
});

final homeRecommendBooksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.homeRecommendBooks, queryParameters: {'limit': 10});
  final data = response.data['data'] as List;
  return data.map((e) => Book.fromJson(e)).toList();
});

// 书城数据 Provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.categories);
  final data = response.data['data'] as List;
  return data.map((e) => Category.fromJson(e)).toList();
});

final booksByCategoryProvider = FutureProvider.family<List<Book>, String>((ref, categoryId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(
    ApiEndpoint.booksByCategory,
    queryParameters: {'category_id': categoryId, 'limit': 20},
  );
  final data = response.data['data'] as List;
  return data.map((e) => Book.fromJson(e)).toList();
});

final bookDetailProvider = FutureProvider.family<Book, String>((ref, bookId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.bookDetail, queryParameters: {'id': bookId});
  return Book.fromJson(response.data['data']);
});

final bookChaptersProvider = FutureProvider.family<List<Chapter>, String>((ref, bookId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.bookChapters, queryParameters: {'book_id': bookId});
  final data = response.data['data'] as List;
  return data.map((e) => Chapter.fromJson(e)).toList();
});

final chapterContentProvider = FutureProvider.family<ChapterContent, String>((ref, chapterId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.bookContent, queryParameters: {'id': chapterId});
  return ChapterContent.fromJson(response.data['data']);
});

// 搜索 Provider
final searchProvider = FutureProvider.family<List<Book>, String>((ref, keyword) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.searchBooks, queryParameters: {'q': keyword});
  final data = response.data['data'] as List;
  return data.map((e) => Book.fromJson(e)).toList();
});

// 书架 Provider
final myBooksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.myBooks);
  final data = response.data['data'] as List;
  return data.map((e) => Book.fromJson(e)).toList();
});

final readProgressProvider = FutureProvider.family<ReadProgress?, String>((ref, bookId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.readProgress, queryParameters: {'book_id': bookId});
  final data = response.data['data'];
  return data != null ? ReadProgress.fromJson(data) : null;
});

// 社交 Provider
final feedProvider = FutureProvider<List<Post>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.feed);
  final data = response.data['data'] as List;
  return data.map((e) => Post.fromJson(e)).toList();
});

final userPostsProvider = FutureProvider.family<List<Post>, String>((ref, userId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.userPosts, queryParameters: {'user_id': userId});
  final data = response.data['data'] as List;
  return data.map((e) => Post.fromJson(e)).toList();
});

final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, targetId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.comments, queryParameters: {'target_id': targetId});
  final data = response.data['data'] as List;
  return data.map((e) => Comment.fromJson(e)).toList();
});

// 作者 Provider
final authorBooksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.authorBooks);
  final data = response.data['data'] as List;
  return data.map((e) => Book.fromJson(e)).toList();
});

final authorStatsProvider = FutureProvider<AuthorStats>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.authorStats);
  return AuthorStats.fromJson(response.data['data']);
});

final authorEarningsProvider = FutureProvider<AuthorEarnings>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.authorEarnings);
  return AuthorEarnings.fromJson(response.data['data']);
});
