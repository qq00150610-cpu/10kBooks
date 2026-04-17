import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiveStorage {
  static late Box _userBox;
  static late Box _bookBox;
  static late Box _settingBox;
  static late Box _cacheBox;
  static late SharedPreferences _prefs;
  
  static Future<void> init() async {
    // 初始化 Hive
    await Hive.initFlutter();
    
    // 打开各个盒子
    _userBox = await Hive.openBox('user_box');
    _bookBox = await Hive.openBox('book_box');
    _settingBox = await Hive.openBox('setting_box');
    _cacheBox = await Hive.openBox('cache_box');
    
    // 初始化 SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }
  
  // User Box
  static Box get userBox => _userBox;
  
  // Book Box
  static Box get bookBox => _bookBox;
  
  // Setting Box
  static Box get settingBox => _settingBox;
  
  // Cache Box
  static Box get cacheBox => _cacheBox;
  
  // SharedPreferences
  static SharedPreferences get prefs => _prefs;
  
  // 通用方法
  static Future<void> put(String boxName, String key, dynamic value) async {
    final box = _getBox(boxName);
    await box.put(key, value);
  }
  
  static dynamic get(String boxName, String key, {dynamic defaultValue}) {
    final box = _getBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }
  
  static Future<void> delete(String boxName, String key) async {
    final box = _getBox(boxName);
    await box.delete(key);
  }
  
  static Future<void> clear(String boxName) async {
    final box = _getBox(boxName);
    await box.clear();
  }
  
  static Box _getBox(String name) {
    switch (name) {
      case 'user':
        return _userBox;
      case 'book':
        return _bookBox;
      case 'setting':
        return _settingBox;
      case 'cache':
        return _cacheBox;
      default:
        return _settingBox;
    }
  }
  
  // SharedPreferences 方法
  static Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }
  
  static String? getString(String key) {
    return _prefs.getString(key);
  }
  
  static Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }
  
  static int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  static Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }
  
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  static Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }
  
  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }
  
  static Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }
  
  // 清除所有数据
  static Future<void> clearAll() async {
    await _userBox.clear();
    await _bookBox.clear();
    await _settingBox.clear();
    await _cacheBox.clear();
    await _prefs.clear();
  }
}
