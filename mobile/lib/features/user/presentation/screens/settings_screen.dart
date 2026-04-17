import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 阅读设置
          _buildSectionHeader('阅读设置'),
          _buildSettingsTile(
            icon: Icons.auto_stories,
            title: '默认字体大小',
            subtitle: '中（16号）',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.format_list_numbered,
            title: '翻页模式',
            subtitle: '滑动',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.brightness_6,
            title: '自动亮度',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          _buildSettingsTile(
            icon: Icons.timer,
            title: '自动滚屏',
            subtitle: '关闭',
            onTap: () {},
          ),
          
          const Divider(),
          
          // 通知设置
          _buildSectionHeader('通知设置'),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: '推送通知',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          _buildSettingsTile(
            icon: Icons.mail,
            title: '邮件通知',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          _buildSettingsTile(
            icon: Icons.new_releases,
            title: '新书提醒',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          
          const Divider(),
          
          // 存储设置
          _buildSectionHeader('存储设置'),
          _buildSettingsTile(
            icon: Icons.storage,
            title: '缓存管理',
            subtitle: '已使用 256 MB',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.wifi,
            title: '仅WiFi下载',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          _buildSettingsTile(
            icon: Icons.delete_sweep,
            title: '自动清理',
            subtitle: '每周',
            onTap: () {},
          ),
          
          const Divider(),
          
          // 账号设置
          _buildSectionHeader('账号设置'),
          _buildSettingsTile(
            icon: Icons.person,
            title: '个人资料',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.lock,
            title: '修改密码',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.phone,
            title: '绑定手机',
            subtitle: '138****8888',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.email,
            title: '绑定邮箱',
            onTap: () {},
          ),
          
          const Divider(),
          
          // 其他设置
          _buildSectionHeader('其他'),
          _buildSettingsTile(
            icon: Icons.language,
            title: '语言',
            subtitle: '简体中文',
            onTap: () => _showLanguageDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.palette,
            title: '主题',
            subtitle: '跟随系统',
            onTap: () => _showThemeDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.help,
            title: '帮助中心',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: '关于我们',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: '隐私政策',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: '用户协议',
            onTap: () {},
          ),
          
          const Divider(),
          
          // 退出登录
          _buildSettingsTile(
            icon: Icons.logout,
            title: '退出登录',
            titleColor: Colors.red,
            onTap: () => _handleLogout(context, ref),
          ),
          
          const SizedBox(height: 32),
          
          // 版本信息
          Center(
            child: Text(
              '万卷书苑 v1.0.0',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
  
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('简体中文'),
              value: 'zh',
              groupValue: 'zh',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: 'zh',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('日本語'),
              value: 'ja',
              groupValue: 'zh',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('한국어'),
              value: 'ko',
              groupValue: 'zh',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('跟随系统'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('浅色模式'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile(
              title: const Text('深色模式'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '万卷书苑',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.auto_stories,
        size: 50,
        color: AppTheme.primaryColor,
      ),
      children: const [
        Text('万卷书苑 - 多语言在线阅读平台'),
        SizedBox(height: 8),
        Text('支持中、英、日、韩等多种语言'),
        SizedBox(height: 8),
        Text('海量书籍，优质阅读体验'),
      ],
    );
  }
  
  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userProvider.notifier).logout();
              Navigator.pop(context);
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
