# 构建指南

## iOS 构建指南

### 环境准备

1. **安装 Xcode**
   - 访问 Mac App Store 下载安装 Xcode 14+
   - 安装完成后打开一次，接受协议

2. **安装 Flutter**
   ```bash
   # 使用 Homebrew
   brew install flutter
   
   # 或下载安装包
   # https://flutter.dev/docs/get-started/install/macos
   ```

3. **配置 iOS 模拟器**
   ```bash
   # 查看可用模拟器
   xcrun simctl list devices
   
   # 启动模拟器
   open -a Simulator
   ```

### 构建步骤

#### 方式一：使用命令行

```bash
# 进入项目目录
cd 10kBooks项目/mobile

# 获取依赖
flutter pub get

# 运行 iOS 模拟器构建
flutter build ios --simulator --no-codesign

# 或构建 Debug 版本
flutter build ios --debug
```

#### 方式二：使用 Xcode

1. 打开项目
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. 选择目标设备和配置
   - Product > Scheme > Runner
   - Product > Destination > 选择设备

3. 构建项目
   - Product > Build (Cmd + B)
   - 或 Product > Run (Cmd + R)

4. 安装到设备
   - Window > Devices and Simulators
   - 选择设备，点击 "+" 安装

### 发布 App Store

1. **创建 App Store Connect 应用**
   - 访问 https://appstoreconnect.apple.com
   - 创建新应用，填写信息

2. **配置应用**
   - 上传应用图标 (1024x1024)
   - 填写应用描述、截图
   - 配置年龄评级

3. **构建 Archive**
   ```bash
   flutter build ios --release
   ```

4. **使用 Xcode 上传**
   - Product > Archive
   - 选择分发方式 (App Store / Ad Hoc)
   - 选择证书和描述文件
   - 上传到 App Store Connect

5. **提交审核**
   - App Store Connect > 选择应用
   - 点击 "添加构建版本"
   - 填写版本信息
   - 提交审核

### 常见问题

**Q: CocoaPods 安装失败？**
```bash
cd ios
pod install --repo-update
```

**Q: 证书签名问题？**
- 检查 Apple Developer 账号状态
- 更新 Xcode 中的签名证书
- 确保 Bundle Identifier 唯一

**Q: 架构不支持错误？**
- iOS 模拟器仅支持 x86_64 和 arm64
- 真机仅支持 arm64

---

## Android 构建指南

### 环境准备

1. **安装 Android Studio**
   - 下载地址: https://developer.android.com/studio
   - 安装 Android SDK、Build-Tools

2. **配置环境变量**
   ```bash
   export ANDROID_HOME=~/Android/Sdk
   export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
   ```

3. **安装 Flutter**
   ```bash
   # 使用 Homebrew
   brew install flutter
   
   # 或下载安装包
   # https://flutter.dev/docs/get-started/install/macos
   ```

### 构建步骤

#### 方式一：使用命令行

```bash
# 进入项目目录
cd 10kBooks项目/mobile

# 获取依赖
flutter pub get

# 构建 Debug APK
flutter build apk --debug

# 构建 Release APK
flutter build apk --release

# 构建 App Bundle (用于 Google Play)
flutter build appbundle --release
```

#### 方式二：使用 Android Studio

1. 打开项目
   - File > Open
   - 选择 android 目录

2. 配置签名
   - File > Project Structure
   - 选择 Signing
   - 添加 release 签名配置

3. 构建
   - Build > Build APK(s) > Build APK(s)
   - 或 Build > Generate Signed Bundle / APK

### 发布 Google Play

1. **创建开发者账号**
   - 访问 https://play.google.com/console
   - 支付注册费用 ($25)

2. **准备应用**
   - 应用图标 (512x512)
   - 屏幕截图 (不同尺寸)
   - 隐私政策 URL

3. **构建 AAB**
   ```bash
   flutter build appbundle --release
   ```

4. **上传**
   - Google Play Console > 选择应用
   - Production > Create Release
   - 上传 .aab 文件

5. **配置商店信息**
   - 填写描述、分类、评级
   - 设置价格和分发国家

6. **提交审核**
   - 审核通常需要 1-3 天

### 常见问题

**Q: Gradle 构建失败？**
```bash
cd android
./gradlew clean
./gradlew --stop
cd ..
flutter clean
flutter pub get
```

**Q: SDK 版本不兼容？**
- 修改 `android/app/build.gradle`
- 确保 compileSdk 和 targetSdk 版本正确

**Q: 签名配置错误？**
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

---

## 性能优化

### iOS 优化

1. **启用 Bitcode**
   - Xcode Build Settings > Enable Bitcode > Yes

2. **优化图片**
   - 使用 Asset Catalogs
   - 启用 App Thinning

3. **减少包体积**
   - 使用 Release 模式构建
   - 移除未使用的代码

### Android 优化

1. **启用 R8**
   - `minifyEnabled true`
   - `shrinkResources true`

2. **优化 APK**
   ```bash
   # 查看 APK 内容
   unzip -l build/app/outputs/flutter-apk/app-release.apk
   
   # 分析依赖
   ./gradlew dependencies
   ```

3. **多架构支持**
   - 仅包含需要的 ABI
   ```gradle
   ndk {
       abiFilters 'armeabi-v7a', 'arm64-v8a'
   }
   ```

---

## 持续集成

### GitHub Actions

```yaml
# .github/workflows/build.yml
name: Build

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [macos-latest, ubuntu-latest]
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - run: flutter pub get
      - run: flutter analyze
      
      - name: Build iOS
        if: matrix.os == 'macos-latest'
        run: flutter build ios --release --no-codesign
      
      - name: Build Android
        if: matrix.os == 'ubuntu-latest'
        run: flutter build apk --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-${{ matrix.os }}
          path: build/
```

---

## 联系方式

如有问题，请联系:
- 邮箱: support@10kbooks.com
- 网站: https://www.10kbooks.com
