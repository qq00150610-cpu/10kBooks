import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));
  
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // 添加 Token
      // final token = await getToken();
      // options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    },
    onResponse: (response, handler) {
      return handler.next(response);
    },
    onError: (error, handler) {
      // 统一错误处理
      return handler.next(error);
    },
  ));
  
  return dio;
});

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final bool success;
  
  ApiResponse({
    required this.code,
    required this.message,
    this.data,
    required this.success,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      success: json['success'] ?? false,
    );
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;
  
  ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });
  
  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

extension DioExtensions on Dio {
  Future<ApiResponse<T>> requestNetwork<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    required T Function(dynamic) fromJsonT,
  }) async {
    try {
      final response = await request<T>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: '网络连接超时，请检查网络设置',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          message: _handleStatusCode(error.response?.statusCode),
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: '请求已取消',
          statusCode: 0,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: '网络连接失败，请检查网络设置',
          statusCode: 0,
        );
      default:
        return ApiException(
          message: '网络异常，请稍后重试',
          statusCode: 0,
        );
    }
  }
  
  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '登录已过期，请重新登录';
      case 403:
        return '没有权限访问';
      case 404:
        return '请求的资源不存在';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';
      default:
        return '请求失败，请稍后重试';
    }
  }
}
