import 'package:flutter/material.dart';

class AppConstants {
  // 应用信息
  static const String appName = '万卷书苑';
  static const String appNameEn = '10kBooks';
  static const String appVersion = '1.0.0';
  
  // API 配置
  static const String baseUrl = 'https://api.10kbooks.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // 分页配置
  static const int pageSize = 20;
  static const int maxPageSize = 100;
  
  // 缓存配置
  static const Duration cacheMaxAge = Duration(hours: 1);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // 阅读器配置
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 16.0;
  static const double fontSizeStep = 2.0;
  
  // 动画时长
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // 存储 Keys
  static const String userBoxKey = 'user_box';
  static const String bookBoxKey = 'book_box';
  static const String settingBoxKey = 'setting_box';
  static const String cacheBoxKey = 'cache_box';
  
  // 设置 Keys
  static const String themeMode = 'theme_mode';
  static const String fontSize = 'font_size';
  static const String readerTheme = 'reader_theme';
  static const String pageMode = 'page_mode';
  static const String autoBrightness = 'auto_brightness';
  
  // 书籍分类
  static const List<Map<String, dynamic>> bookCategories = [
    {'id': 'fiction', 'name': '小说', 'icon': 'novel'},
    {'id': 'romance', 'name': '言情', 'icon': 'romance'},
    {'id': 'fantasy', 'name': '玄幻', 'icon': 'fantasy'},
    {'id': 'urban', 'name': '都市', 'icon': 'urban'},
    {'id': 'sci-fi', 'name': '科幻', 'icon': 'sci-fi'},
    {'id': 'mystery', 'name': '悬疑', 'icon': 'mystery'},
    {'id': 'history', 'name': '历史', 'icon': 'history'},
    {'id': 'biography', 'name': '传记', 'icon': 'biography'},
    {'id': 'self-help', 'name': '自我提升', 'icon': 'self-help'},
    {'id': 'business', 'name': '商业', 'icon': 'business'},
    {'id': 'poetry', 'name': '诗歌', 'icon': 'poetry'},
    {'id': 'essay', 'name': '散文', 'icon': 'essay'},
  ];
  
  // 语言列表
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'zh', 'name': '简体中文'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
  ];
  
  // VIP 等级颜色
  static Color getVipColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFFF6B35);
      default:
        return Colors.grey;
    }
  }
  
  static String getVipName(int level) {
    switch (level) {
      case 1:
        return 'VIP会员';
      case 2:
        return '高级VIP';
      case 3:
        return '至尊VIP';
      default:
        return '普通用户';
    }
  }
}
