import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/storage_service.dart';
import '../models/models.dart';
import 'app_providers.dart';

// 用户状态
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  UserState({this.user, this.isLoading = false, this.error});

  UserState copyWith({User? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 用户状态管理
class UserNotifier extends StateNotifier<UserState> {
  final ApiService _api;
  final StorageService _storage;

  UserNotifier(this._api, this._storage) : super(UserState()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (_storage.isLoggedIn) {
      state = state.copyWith(isLoading: true);
      try {
        final response = await _api.get(ApiEndpoint.userInfo);
        final user = User.fromJson(response.data['data']);
        state = state.copyWith(user: user, isLoading: false);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<bool> login(String account, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(
        ApiEndpoint.login,
        data: {'account': account, 'password': password},
      );
      final tokens = AuthTokens.fromJson(response.data['data']);
      await _storage.saveToken(tokens.accessToken);
      await _storage.saveRefreshToken(tokens.refreshToken);
      
      final userResponse = await _api.get(ApiEndpoint.userInfo);
      final user = User.fromJson(userResponse['data']);
      state = state.copyWith(user: user, isLoading: false);
      DioClient.instance.setAuthToken(tokens.accessToken);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String nickname, String email, String password, {String? inviteCode}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.post(
        ApiEndpoint.register,
        data: {
          'nickname': nickname,
          'email': email,
          'password': password,
          'invite_code': inviteCode,
        },
      );
      // 注册后自动登录
      return await login(email, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoint.logout);
    } catch (_) {}
    await _storage.clearUserData();
    DioClient.instance.removeAuthToken();
    state = UserState();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.put(ApiEndpoint.updateUserInfo, data: data);
      final user = User.fromJson(response.data['data']);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final api = ref.read(apiServiceProvider);
  final storage = StorageService.instance;
  return UserNotifier(api, storage);
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).user != null;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userProvider).user;
});

// VIP Provider
final vipInfoProvider = FutureProvider<VipInfo?>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.vipInfo);
  final data = response.data['data'];
  return data != null ? VipInfo.fromJson(data) : null;
});

final vipProductsProvider = FutureProvider<List<VipProduct>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.vipProducts);
  final data = response.data['data'] as List;
  return data.map((e) => VipProduct.fromJson(e)).toList();
});

// 其他用户信息
final otherUserProvider = FutureProvider.family<User?, String>((ref, userId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get(ApiEndpoint.userInfo, queryParameters: {'user_id': userId});
  final data = response.data['data'];
  return data != null ? User.fromJson(data) : null;
});
