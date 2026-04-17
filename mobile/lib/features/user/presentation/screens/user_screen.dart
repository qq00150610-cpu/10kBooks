import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class UserScreen extends ConsumerWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 用户信息头部
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push('/settings'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                ),
                child: SafeArea(
                  child: state.isLoggedIn
                      ? _buildUserInfo(context, state)
                      : _buildLoginPrompt(context),
                ),
              ),
            ),
          ),
          
          // 功能菜单
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // VIP 会员卡片
                _buildVipCard(context, state),
                
                const SizedBox(height: 16),
                
                // 资产信息
                _buildAssetInfo(context, state),
                
                const SizedBox(height: 16),
                
                // 功能列表
                _buildFunctionList(context, state),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserInfo(BuildContext context, UserState state) {
    final user = state.user!;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/profile/${user.id}'),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage: NetworkImage(user.avatarUrl),
                      ),
                    ),
                    if (user.isVip)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.getVipColor(user.vipLevel),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'VIP${user.vipLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.bio.isNotEmpty ? user.bio : '这个人很懒，什么都没写',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip('关注', '${user.followingCount}'),
                        const SizedBox(width: 8),
                        _buildStatChip('粉丝', '${user.followerCount}'),
                        if (user.isAuthor) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '作者',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
  
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            '登录万卷书苑',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '畅享海量书籍，开启阅读之旅',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('登录'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => context.push('/register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: const Text('注册'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildVipCard(BuildContext context, UserState state) {
    final isVip = state.isLoggedIn && state.user!.isVip;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVip
              ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
              : [Colors.grey[400]!, Colors.grey[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVip ? 'VIP会员' : '开通VIP会员',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isVip
                      ? '尊贵会员，畅读全站'
                      : '畅读全站书籍，解锁更多特权',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/vip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isVip ? const Color(0xFFFFD700) : Colors.grey[700],
            ),
            child: Text(isVip ? '已开通' : '立即开通'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssetInfo(BuildContext context, UserState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAssetItem(
            context,
            icon: Icons.monetization_on,
            value: '${state.user?.coinBalance ?? 0}',
            label: '书币',
            color: Colors.amber,
          ),
          _buildAssetItem(
            context,
            icon: Icons.schedule,
            value: '${state.user?.readTime ?? 0}',
            label: '阅读时长',
            color: Colors.blue,
          ),
          _buildAssetItem(
            context,
            icon: Icons.book,
            value: '${state.user?.bookCount ?? 0}',
            label: '藏书',
            color: Colors.green,
          ),
          _buildAssetItem(
            context,
            icon: Icons.favorite,
            value: '${state.user?.collectCount ?? 0}',
            label: '收藏',
            color: Colors.red,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssetItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFunctionList(BuildContext context, UserState state) {
    final functions = [
      {'icon': Icons.history, 'name': '阅读历史', 'action': () {}},
      {'icon': Icons.bookmark, 'name': '我的书签', 'action': () {}},
      {'icon': Icons.note, 'name': '我的笔记', 'action': () {}},
      {'icon': Icons.download, 'name': '离线管理', 'action': () {}},
      {'icon': Icons.wallet, 'name': '我的钱包', 'action': () {}},
      {'icon': Icons.card_giftcard, 'name': '邀请好友', 'action': () {}},
      {'icon': Icons.headset, 'name': '联系客服', 'action': () {}},
      {'icon': Icons.help, 'name': '帮助中心', 'action': () {}},
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: functions.asMap().entries.map((entry) {
          final index = entry.key;
          final func = entry.value;
          
          return Column(
            children: [
              ListTile(
                leading: Icon(func['icon'] as IconData),
                title: Text(func['name'] as String),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: func['action'] as VoidCallback,
              ),
              if (index < functions.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}
