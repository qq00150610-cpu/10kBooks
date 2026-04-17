# iOS 构建指南

## 📋 环境要求

- macOS 12.0+ (Monterey 或更高版本)
- Xcode 14.0+
- Flutter SDK 3.0+
- CocoaPods 1.12+

## 🛠 准备工作

### 1. 安装 Flutter (如尚未安装)

```bash
# 使用 Homebrew
brew install flutter

# 或下载安装包
# https://docs.flutter.dev/get-started/install/macos
```

### 2. 检查环境

```bash
flutter doctor
flutter doctor -v
```

### 3. 配置 iOS 开发环境

```bash
# 确保 Xcode 命令行工具已安装
xcode-select --install

# 接受 Xcode 许可协议
sudo xcodebuild -license accept
```

## 📱 项目配置

### Bundle Identifier

修改 `ios/Runner.xcodeproj/project.pbxproj`:

```
PRODUCT_BUNDLE_IDENTIFIER = com.10kbooks.app;
```

### 应用名称

修改 `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>万卷书苑</string>
```

### 最低 iOS 版本

在 `ios/Podfile` 中设置:

```ruby
platform :ios, '12.0'
```

## 🚀 构建步骤

### 方式一：Flutter CLI

```bash
# 进入项目目录
cd 10kBooks项目/mobile

# 获取依赖
flutter pub get

# 运行应用（开发模式）
flutter run

# 构建 Debug 版本
flutter build ios --debug

# 构建 Release 版本
flutter build ios --release
```

### 方式二：Xcode

1. 打开 `ios/Runner.xcworkspace` (注意不是 .xcodeproj)
2. 选择目标设备 (iPhone 模拟器或真机)
3. 选择构建配置:
   - Debug: 开发调试
   - Release: 发布版本
4. 点击 `Product > Build` 或快捷键 `Cmd + B`
5. 等待构建完成，点击 `Run` 安装运行

### 方式三：命令行构建

```bash
cd ios

# 构建 Debug 版本
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 14 Pro' \
  build

# 构建 Release 版本
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  CODE_SIGN_IDENTITY="iPhone Distribution" \
  PROVISIONING_PROFILE="你的描述文件UUID" \
  build
```

## 📦 发布 App Store

### 1. 创建 App Store Connect 应用

1. 访问 [App Store Connect](https://appstoreconnect.apple.com)
2. 创建新应用，填写应用信息
3. 记录 Bundle ID

### 2. 配置签名

1. 在 Apple Developer 网站创建 App ID
2. 创建发布证书
3. 创建发布描述文件
4. 在 Xcode 中配置签名

### 3. 构建发布版本

```bash
# 创建归档
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive \
  archive

# 导出 IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/ipa
```

### 4. 创建 ExportOptions.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>signingCertificate</key>
    <string>iPhone Distribution</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>teamID</key>
    <string>你的团队ID</string>
</dict>
</plist>
```

### 5. 上传到 App Store

使用 Xcode 或 Transporter 应用上传 IPA

## ⚙️ iOS 权限配置

在 `ios/Runner/Info.plist` 中配置:

```xml
<!-- 网络权限 -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- 相册权限 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以更换头像</string>

<!-- 相机权限 -->
<key>NSCameraUsageDescription</key>
<string>需要使用相机拍照</string>

<!-- 位置权限(可选) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要获取位置信息</string>
```

## 🔧 常见问题

### 1. 构建失败：Code Signing

```
error: No valid signing identities (i.e. certificate and private key pair) found
```

解决方案：
- 检查证书是否过期
- 检查描述文件是否有效
- 确保 Xcode 中选对了 Team

### 2. CocoaPods 安装失败

```bash
cd ios
pod install --repo-update
```

### 3. Flutter iOS 构建慢

```bash
# 清理缓存
flutter clean
rm -rf ~/Library/Developer/Xcode/DerivedData

# 重新获取依赖
flutter pub get
cd ios && pod install && cd ..
```

### 4. 模拟器构建报错

确保使用 `-sdk iphonesimulator` 参数

## 📊 构建验证

### 检查构建产物

```bash
# Debug 构建产物位置
~/Library/Developer/Xcode/DerivedData/

# Release 构建产物
build/ios/iphoneos/Runner.app
```

### 构建大小优化

1. 使用 `flutter build ios --release`
2. 移除未使用的资源文件
3. 配置 Bitcode (可选)
4. 使用 App Thinning
