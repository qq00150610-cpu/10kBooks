import 'package:dio/dio.dart';
import 'dio_client.dart';

enum ApiEndpoint {
  // 首页
  homeBanners,
  homeHotBooks,
  homeNewBooks,
  homeRecommendBooks,
  
  // 书城
  categories,
  booksByCategory,
  bookDetail,
  bookChapters,
  bookContent,
  searchBooks,
  
  // 用户
  login,
  register,
  logout,
  userInfo,
  updateUserInfo,
  refreshToken,
  
  // 书架
  myBooks,
  addToBookshelf,
  removeFromBookshelf,
  readProgress,
  updateReadProgress,
  
  // 阅读
  bookmarks,
  addBookmark,
  removeBookmark,
  notes,
  addNote,
  updateNote,
  deleteNote,
  
  // VIP
  vipInfo,
  vipProducts,
  createOrder,
  
  // 作者
  authorBooks,
  authorStats,
  authorEarnings,
  createBook,
  updateBook,
  createChapter,
  updateChapter,
  
  // 社交
  feed,
  userPosts,
  postDetail,
  createPost,
  likePost,
  unlikePost,
  comments,
  addComment,
  deleteComment,
  followUser,
  unfollowUser,
  followers,
  followings,
}

extension ApiEndpointExtension on ApiEndpoint {
  String get path {
    switch (this) {
      case ApiEndpoint.homeBanners:
        return '/api/v1/home/banners';
      case ApiEndpoint.homeHotBooks:
        return '/api/v1/home/hot-books';
      case ApiEndpoint.homeNewBooks:
        return '/api/v1/home/new-books';
      case ApiEndpoint.homeRecommendBooks:
        return '/api/v1/home/recommend-books';
      case ApiEndpoint.categories:
        return '/api/v1/categories';
      case ApiEndpoint.booksByCategory:
        return '/api/v1/books/category';
      case ApiEndpoint.bookDetail:
        return '/api/v1/books';
      case ApiEndpoint.bookChapters:
        return '/api/v1/books/chapters';
      case ApiEndpoint.bookContent:
        return '/api/v1/chapters/content';
      case ApiEndpoint.searchBooks:
        return '/api/v1/books/search';
      case ApiEndpoint.login:
        return '/api/v1/auth/login';
      case ApiEndpoint.register:
        return '/api/v1/auth/register';
      case ApiEndpoint.logout:
        return '/api/v1/auth/logout';
      case ApiEndpoint.userInfo:
        return '/api/v1/user';
      case ApiEndpoint.updateUserInfo:
        return '/api/v1/user';
      case ApiEndpoint.refreshToken:
        return '/api/v1/auth/refresh';
      case ApiEndpoint.myBooks:
        return '/api/v1/bookshelf';
      case ApiEndpoint.addToBookshelf:
        return '/api/v1/bookshelf';
      case ApiEndpoint.removeFromBookshelf:
        return '/api/v1/bookshelf';
      case ApiEndpoint.readProgress:
        return '/api/v1/progress';
      case ApiEndpoint.updateReadProgress:
        return '/api/v1/progress';
      case ApiEndpoint.bookmarks:
        return '/api/v1/bookmarks';
      case ApiEndpoint.addBookmark:
        return '/api/v1/bookmarks';
      case ApiEndpoint.removeBookmark:
        return '/api/v1/bookmarks';
      case ApiEndpoint.notes:
        return '/api/v1/notes';
      case ApiEndpoint.addNote:
        return '/api/v1/notes';
      case ApiEndpoint.updateNote:
        return '/api/v1/notes';
      case ApiEndpoint.deleteNote:
        return '/api/v1/notes';
      case ApiEndpoint.vipInfo:
        return '/api/v1/vip/info';
      case ApiEndpoint.vipProducts:
        return '/api/v1/vip/products';
      case ApiEndpoint.createOrder:
        return '/api/v1/orders';
      case ApiEndpoint.authorBooks:
        return '/api/v1/author/books';
      case ApiEndpoint.authorStats:
        return '/api/v1/author/stats';
      case ApiEndpoint.authorEarnings:
        return '/api/v1/author/earnings';
      case ApiEndpoint.createBook:
        return '/api/v1/author/books';
      case ApiEndpoint.updateBook:
        return '/api/v1/author/books';
      case ApiEndpoint.createChapter:
        return '/api/v1/author/chapters';
      case ApiEndpoint.updateChapter:
        return '/api/v1/author/chapters';
      case ApiEndpoint.feed:
        return '/api/v1/feed';
      case ApiEndpoint.userPosts:
        return '/api/v1/users/posts';
      case ApiEndpoint.postDetail:
        return '/api/v1/posts';
      case ApiEndpoint.createPost:
        return '/api/v1/posts';
      case ApiEndpoint.likePost:
        return '/api/v1/posts/like';
      case ApiEndpoint.unlikePost:
        return '/api/v1/posts/unlike';
      case ApiEndpoint.comments:
        return '/api/v1/comments';
      case ApiEndpoint.addComment:
        return '/api/v1/comments';
      case ApiEndpoint.deleteComment:
        return '/api/v1/comments';
      case ApiEndpoint.followUser:
        return '/api/v1/users/follow';
      case ApiEndpoint.unfollowUser:
        return '/api/v1/users/unfollow';
      case ApiEndpoint.followers:
        return '/api/v1/users/followers';
      case ApiEndpoint.followings:
        return '/api/v1/users/followings';
    }
  }
}

class ApiService {
  final DioClient _client;

  ApiService(this._client);

  Future<Response<T>> get<T>(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _client.get<T>(
      endpoint.path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    ApiEndpoint endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _client.post<T>(
      endpoint.path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    ApiEndpoint endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _client.put<T>(
      endpoint.path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    ApiEndpoint endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _client.delete<T>(
      endpoint.path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
