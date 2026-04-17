# Android 构建指南

## 📋 环境要求

- macOS / Linux / Windows
- Flutter SDK 3.0+
- Android Studio 2022.0+ 或命令行工具
- Android SDK API 21+ (Android 5.0)
- Java JDK 11+

## 🛠 准备工作

### 1. 安装 Flutter

```bash
# macOS/Linux
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x-stable.tar.xz | tar xJ

# Windows
# 下载并解压 flutter_windows_3.x-stable.zip
```

### 2. 配置 Android SDK

```bash
# 设置 ANDROID_HOME 环境变量
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# macOS (添加到 ~/.bash_profile 或 ~/.zshrc)
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.bash_profile
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools' >> ~/.bash_profile
source ~/.bash_profile
```

### 3. 接受 Android 许可协议

```bash
flutter doctor --android-licenses
# 或
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
```

### 4. 配置 Gradle 镜像 (可选，中国用户)

修改 `android/build.gradle`:

```groovy
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        google()
        mavenCentral()
    }
}
```

## 📱 项目配置

### 应用信息

修改 `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        applicationId "com.10kbooks.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 应用名称

修改 `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="万卷书苑"
    ...>
```

### 签名配置

创建签名配置 `android/key.properties`:

```properties
storePassword=你的密码
keyPassword=你的密码
keyAlias=keyalias
storeFile=key.jks
```

修改 `android/app/build.gradle`:

```groovy
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 🚀 构建步骤

### 方式一：Flutter CLI

```bash
cd 10kBooks项目/mobile

# 获取依赖
flutter pub get

# 运行应用（开发模式）
flutter run

# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

### 方式二：Gradle 命令行

```bash
cd android

# 查看可用任务
./gradlew tasks

# 构建 Debug APK
./gradlew assembleDebug

# 构建 Release APK
./gradlew assembleRelease

# 清理构建
./gradlew clean

# 构建并安装到连接设备
./gradlew installRelease
```

### 方式三：Android Studio

1. 打开 `android` 目录作为项目
2. 等待 Gradle 同步完成
3. 选择构建变体 (Debug/Release)
4. 点击 Run 或 Build APK

## 📦 发布 Google Play

### 1. 创建应用

1. 访问 [Google Play Console](https://play.google.com/console)
2. 创建新应用
3. 填写应用信息
4. 上传应用图标和截图

### 2. 配置 Play App Signing

首次发布需要配置 Play App Signing：

1. 选择"让 Google 管理密钥"
2. 或上传自己的密钥

### 3. 构建 App Bundle

```bash
# 构建 Release App Bundle
flutter build appbundle --release

# 或 Gradle
cd android
./gradlew bundleRelease
```

### 4. 上传 Play Console

1. 进入"生产" > "创建版本"
2. 上传 `.aab` 文件
3. 填写版本信息和发布说明
4. 提交审核

## ⚙️ Android 权限配置

在 `android/app/src/main/AndroidManifest.xml` 中配置:

```xml
<!-- 网络权限 -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- 存储权限 (Android 10 以前) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- 存储权限 (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>

<!-- 相机权限 -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- 位置权限 (可选) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- 通知权限 (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Android 13 运行时权限处理

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // 存储权限
  if (await Permission.storage.request().isDenied) {
    // 处理拒绝
  }
  
  // 通知权限
  if (await Permission.notification.request().isDenied) {
    // 处理拒绝
  }
}
```

## 🔧 常见问题

### 1. Gradle 构建失败

```bash
# 清理缓存
flutter clean
rm -rf ~/.gradle/caches

# 重新构建
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk --release
```

### 2. 网络问题导致依赖下载慢

修改 `android/build.gradle` 配置镜像:

```groovy
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
    }
}
```

### 3. Java 版本问题

```bash
# 检查 Java 版本
java -version

# Flutter 3.x 需要 JDK 11
# 设置 JAVA_HOME
export JAVA_HOME=/path/to/jdk-11
```

### 4. SDK 版本不匹配

```
Execution failed for task ':app:processDebugResources'.
> Android resource compilation failed
```

解决方案：更新 Android SDK Build-Tools

```bash
# 或在 Android Studio 中
# Tools > SDK Manager > SDK Tools > Android SDK Build-Tools
```

### 5. 内存不足

修改 `android/gradle.properties`:

```properties
org.gradle.jvmargs=-Xmx2048m -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
org.gradle.caching=true
```

## 📊 构建产物

### 位置

- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

### 构建大小优化

1. **启用 R8 压缩**

```groovy
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

2. **配置混淆规则** `android/app/proguard-rules.pro`:

```proguard
# 保留 Flutter 相关的类
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }

# 保留 JSON 序列化
-keepattributes *Annotation*
-keepattributes Signature
-keep class com.google.gson.** { *; }

# 保留数据模型
-keep class com.tenkbooks.app.data.models.** { *; }
```

3. **移除未使用资源**

```bash
flutter build apk --release --target-platform android-arm64
```

## 📋 检查清单

发布前检查:

- [ ] 更新版本号 (versionCode, versionName)
- [ ] 更新应用名称和图标
- [ ] 配置签名信息
- [ ] 测试 Debug 和 Release 版本
- [ ] 配置应用权限说明
- [ ] 填写应用描述和截图
- [ ] 测试隐私政策合规性
