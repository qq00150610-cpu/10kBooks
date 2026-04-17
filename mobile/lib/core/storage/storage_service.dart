import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static bool _initialized = false;

  StorageService._internal();

  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);

    // 打开所有Box
    await Future.wait([
      Hive.openBox(AppConstants.hiveBoxUser),
      Hive.openBox(AppConstants.hiveBoxBook),
      Hive.openBox(AppConstants.hiveBoxProgress),
      Hive.openBox(AppConstants.hiveBoxDownload),
      Hive.openBox(AppConstants.hiveBoxSettings),
    ]);

    _initialized = true;
  }

  Box get userBox => Hive.box(AppConstants.hiveBoxUser);
  Box get bookBox => Hive.box(AppConstants.hiveBoxBook);
  Box get progressBox => Hive.box(AppConstants.hiveBoxProgress);
  Box get downloadBox => Hive.box(AppConstants.hiveBoxDownload);
  Box get settingsBox => Hive.box(AppConstants.hiveBoxSettings);

  // User Box 操作
  Future<void> saveUserId(String userId) async {
    await userBox.put(AppConstants.userIdKey, userId);
  }

  String? getUserId() {
    return userBox.get(AppConstants.userIdKey);
  }

  Future<void> saveToken(String token) async {
    await userBox.put(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return userBox.get(AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await userBox.put(AppConstants.refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return userBox.get(AppConstants.refreshTokenKey);
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await userBox.put('user_data', data);
  }

  Map<String, dynamic>? getUserData() {
    final data = userBox.get('user_data');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await userBox.clear();
  }

  bool get isLoggedIn => getToken() != null;

  // Settings Box 操作
  Future<void> saveThemeMode(String mode) async {
    await settingsBox.put(AppConstants.themeKey, mode);
  }

  String getThemeMode() {
    return settingsBox.get(AppConstants.themeKey, defaultValue: 'system');
  }

  Future<void> saveLanguage(String language) async {
    await settingsBox.put(AppConstants.languageKey, language);
  }

  String getLanguage() {
    return settingsBox.get(AppConstants.languageKey, defaultValue: 'zh');
  }

  Future<void> saveReaderSettings(Map<String, dynamic> settings) async {
    await settingsBox.put(AppConstants.readerSettingsKey, settings);
  }

  Map<String, dynamic> getReaderSettings() {
    final settings = settingsBox.get(AppConstants.readerSettingsKey);
    if (settings != null) {
      return Map<String, dynamic>.from(settings);
    }
    return {
      'fontSize': AppConstants.defaultFontSize,
      'lineHeight': AppConstants.defaultLineHeight,
      'theme': 'light',
      'fontFamily': 'NotoSansSC',
    };
  }

  // Book Box 操作
  Future<void> saveBookInfo(String bookId, Map<String, dynamic> bookInfo) async {
    await bookBox.put(bookId, bookInfo);
  }

  Map<String, dynamic>? getBookInfo(String bookId) {
    final data = bookBox.get(bookId);
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Progress Box 操作
  Future<void> saveReadProgress(String bookId, Map<String, dynamic> progress) async {
    await progressBox.put(bookId, progress);
  }

  Map<String, dynamic>? getReadProgress(String bookId) {
    final data = progressBox.get(bookId);
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Download Box 操作
  Future<void> saveDownloadInfo(String bookId, Map<String, dynamic> info) async {
    await downloadBox.put(bookId, info);
  }

  Map<String, dynamic>? getDownloadInfo(String bookId) {
    final data = downloadBox.get(bookId);
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  List<String> getDownloadedBookIds() {
    return downloadBox.keys.cast<String>().toList();
  }

  Future<void> removeDownloadInfo(String bookId) async {
    await downloadBox.delete(bookId);
  }

  // 清除所有数据
  Future<void> clearAll() async {
    await userBox.clear();
    await bookBox.clear();
    await progressBox.clear();
    await downloadBox.clear();
  }

  // 关闭所有Box
  Future<void> close() async {
    await Hive.close();
  }
}
