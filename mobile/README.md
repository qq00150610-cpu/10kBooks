# 万卷书苑 / 10kBooks

> 多语言在线阅读平台 - Flutter 跨平台移动应用

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green)
![License](https://img.shields.io/badge/License-MIT-orange)

## 📚 项目简介

万卷书苑（10kBooks）是一款功能完备的多语言在线阅读平台，支持中、英、日、韩等多种语言的海量书籍阅读。应用采用 Flutter 3.x 开发，同时支持 iOS 和 Android 双平台。

## ✨ 核心功能

### 1. 首页模块
- 推荐书籍轮播展示
- 热门榜单排行
- 新书上架推荐
- 分类导航快捷入口

### 2. 书城模块
- 多分类书籍浏览
- 智能搜索功能
- 筛选排序功能
- 书籍详情展示

### 3. 书架模块
- 我的书籍管理
- 阅读进度追踪
- 离线下载功能
- 批量管理模式

### 4. 阅读器模块
- 流畅阅读体验
- 仿真翻页动画
- 多主题切换
- 字体大小调节
- 书签笔记功能
- 夜间阅读模式
- 沉浸式阅读
- AI 辅助阅读

### 5. 用户模块
- 登录注册系统
- 个人中心管理
- VIP 会员服务
- 充值消费系统
- 设置中心

### 6. 作者模块
- 作者主页展示
- 书籍创作管理
- 章节编辑发布
- 数据统计分析
- 收益提现系统

### 7. 社交模块
- 书友圈动态
- 个人主页展示
- 关注互动系统
- 评论点赞功能

## 🛠 技术栈

### 核心框架
- **Flutter 3.x** - Google 跨平台 UI 框架
- **Dart 3.x** - 编程语言

### 状态管理
- **Riverpod** - 现代化响应式状态管理

### 网络请求
- **Dio** - 强大的 HTTP 客户端

### 本地存储
- **Hive** - 高性能 NoSQL 数据库
- **SharedPreferences** - 轻量级键值存储

### 其他依赖
- **cached_network_image** - 图片缓存
- **flutter_swiper** - 轮播组件
- **shimmer** - 骨架屏效果
- **go_router** - 路由管理
- **path_provider** - 文件路径获取
- **permission_handler** - 权限管理
- **url_launcher** - URL 启动器

## 📁 项目结构

```
10kBooks项目/mobile/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── core/                     # 核心模块
│   │   ├── constants/            # 常量定义
│   │   ├── theme/                # 主题配置
│   │   ├── utils/                # 工具类
│   │   ├── network/              # 网络层
│   │   ├── storage/              # 存储层
│   │   ├── models/               # 数据模型
│   │   ├── widgets/              # 通用组件
│   │   └── router/              # 路由配置
│   └── features/                 # 功能模块
│       ├── home/                # 首页
│       ├── bookstore/           # 书城
│       ├── bookshelf/           # 书架
│       ├── reader/              # 阅读器
│       ├── user/                # 用户
│       ├── author/              # 作者
│       └── social/              # 社交
├── android/                     # Android 配置
├── ios/                         # iOS 配置
├── assets/                     # 静态资源
└── pubspec.yaml                # 依赖配置
```

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode

### 安装步骤

```bash
# 1. 克隆项目
git clone https://github.com/your-repo/10kbooks.git
cd 10kbooks项目/mobile

# 2. 安装依赖
flutter pub get

# 3. 创建资源目录
mkdir -p assets/{images,icons,fonts,books,i18n}

# 4. 运行应用
flutter run
```

### iOS 构建

```bash
# 检查 iOS 配置
cd ios
pod install
cd ..

# 构建 iOS
flutter build ios --release

# 或使用 Xcode
open ios/Runner.xcworkspace
```

### Android 构建

```bash
# 构建 Debug APK
flutter build apk --debug

# 构建 Release APK
flutter build apk --release

# 构建 Bundle
flutter build appbundle --release
```

## 📖 使用说明

### 页面导航

应用采用底部 Tab 导航 + 路由跳转的混合导航模式：

| Tab | 路径 | 功能 |
|-----|------|------|
| 首页 | `/home` | 推荐内容展示 |
| 书城 | `/bookstore` | 书籍浏览搜索 |
| 书架 | `/bookshelf` | 个人书籍管理 |
| 我的 | `/user` | 用户中心 |

### 阅读器使用

1. 点击书籍进入阅读器
2. 点击屏幕中央显示/隐藏控制栏
3. 左右滑动或点击边缘翻页
4. 底部工具栏可调节字体、主题、亮度
5. 长按文字可添加书签和笔记

### 作者功能

1. 在「我的」页面进入作者中心
2. 创建新书籍，设置基本信息
3. 发布章节，管理作品
4. 查看数据统计和收益

## 🎨 自定义配置

### 主题配置

在 `lib/core/theme/app_theme.dart` 中修改：

```dart
static const Color primaryColor = Color(0xFFE53935); // 主色调
static const Color secondaryColor = Color(0xFFFF7043); // 辅助色
```

### 阅读器主题

支持自定义阅读器配色：

```dart
static const List<Color> readerThemes = [
  Color(0xFFFFF8E1), // 羊皮纸
  Color(0xFFE8F5E9), // 护眼绿
  Color(0xFFE3F2FD), // 淡蓝
  Color(0xFFFCE4EC), // 粉色
  Color(0xFFFFFFFF), // 纯白
  Color(0xFF263238), // 夜间
];
```

## 🔧 开发指南

### 添加新页面

1. 在 `lib/features/{module}/presentation/screens/` 创建页面
2. 在 `lib/features/{module}/presentation/providers/` 创建 Provider
3. 在 `lib/core/router/app_router.dart` 添加路由

### 添加新功能模块

```dart
// 1. 创建模块目录结构
lib/features/
  └── new_module/
      ├── data/
      ├── domain/
      └── presentation/
          ├── screens/
          ├── widgets/
          └── providers/
```

### 状态管理示例

```dart
// 定义状态
class MyState {
  final bool isLoading;
  final List<Item> items;
  
  MyState({this.isLoading = false, this.items = const []});
}

// 创建 Provider
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});

class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState());
  
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    // 加载数据
    state = state.copyWith(isLoading: false, items: [...]);
  }
}
```

## 📱 构建输出

### Android
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

### iOS
- Debug: `build/ios/iphoneos/Runner.app`
- Release: `build/ios/iphonesimulator/Runner.app` 或 IPA 包

## 🐛 常见问题

### Q: 依赖安装失败？

```bash
flutter pub cache repair
flutter pub get
```

### Q: Android 构建失败？

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### Q: iOS 构建失败？

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter build ios --release
```

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系方式

- 邮箱: support@10kbooks.com
- 网站: https://www.10kbooks.com

---

**© 2024 万卷书苑 All Rights Reserved.**
