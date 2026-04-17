import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class VipScreen extends ConsumerWidget {
  const VipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProvider);
    final user = state.user;
    final isVip = user?.isVip ?? false;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // VIP 头部
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.diamond,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isVip
                            ? 'VIP会员'
                            : '开通VIP会员',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isVip
                            ? '尊贵身份，畅读全站'
                            : '解锁全部特权，开启阅读新体验',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      if (isVip && user?.vipExpireTime != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '有效期至：${_formatDate(user!.vipExpireTime!)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // VIP 特权
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '会员特权',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                _buildPrivilegeGrid(),
                
                const SizedBox(height: 24),
                
                // VIP 套餐
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '选择套餐',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildVipPackages(context, ref, user?.vipLevel ?? 0),
                
                const SizedBox(height: 24),
                
                // 常见问题
                _buildFAQ(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrivilegeGrid() {
    final privileges = [
      {'icon': Icons.auto_stories, 'title': '畅读全站', 'desc': '解锁全部书籍'},
      {'icon': Icons.flash_on, 'title': '免广告', 'desc': '清爽阅读体验'},
      {'icon': Icons.cloud_download, 'title': '高速下载', 'desc': '加速离线阅读'},
      {'icon': Icons.attach_money, 'title': '专属折扣', 'desc': '书币充值优惠'},
      {'icon': Icons.stars, 'title': '专属标识', 'desc': '尊贵VIP身份'},
      {'icon': Icons.headset, 'title': '优先客服', 'desc': '专属客服通道'},
      {'icon': Icons.workspace_premium, 'title': '免费阅读', 'desc': 'VIP专属免费书'},
      {'icon': Icons.card_giftcard, 'title': '生日礼包', 'desc': '生日惊喜好礼'},
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: privileges.length,
      itemBuilder: (context, index) {
        final privilege = privileges[index];
        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                privilege['icon'] as IconData,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              privilege['title'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              privilege['desc'] as String,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildVipPackages(BuildContext context, WidgetRef ref, int currentLevel) {
    final packages = [
      {
        'level': 1,
        'name': 'VIP会员',
        'price': '¥68',
        'original': '¥128',
        'duration': '年',
        'perMonth': '5.7元/月',
        'features': ['畅读全站', '免广告', '高速下载'],
        'hot': false,
      },
      {
        'level': 2,
        'name': '高级VIP',
        'price': '¥128',
        'original': '¥298',
        'duration': '年',
        'perMonth': '10.7元/月',
        'features': ['VIP全部特权', '专属客服', '7折书币'],
        'hot': true,
      },
      {
        'level': 3,
        'name': '至尊VIP',
        'price': '¥298',
        'original': '¥598',
        'duration': '年',
        'perMonth': '24.9元/月',
        'features': ['高级VIP特权', '终身免费', '专属顾问'],
        'hot': false,
      },
    ];
    
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          final isSelected = currentLevel >= (package['level'] as int);
          
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: package['hot'] == true
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (package['hot'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '热门',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  package['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.getVipColor(package['level'] as int),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package['price'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '/${package['duration']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  package['perMonth'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 12),
                ...((package['features'] as List<String>).map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          f,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                })),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handlePurchase(context, ref, package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.grey
                          : AppConstants.getVipColor(package['level'] as int),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      isSelected ? '已开通' : '立即开通',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFAQ() {
    final faqs = [
      {'q': 'VIP会员可以退款吗？', 'a': 'VIP会员购买后不支持退款，请谨慎购买。'},
      {'q': '如何取消自动续费？', 'a': '可在设置-会员管理中取消自动续费。'},
      {'q': 'VIP会员可以多设备使用吗？', 'a': '同一账号可在多个设备登录使用。'},
    ];
    
    return ExpansionPanelList.radio(
      elevation: 1,
      children: faqs.map((faq) {
        return ExpansionPanelRadio(
          value: faq,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(faq['q'] as String),
            );
          },
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['a'] as String,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  void _handlePurchase(BuildContext context, WidgetRef ref, dynamic package) {
    // 模拟购买
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认购买'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('套餐：${package['name']}'),
            Text('价格：${package['price']}'),
            const SizedBox(height: 8),
            const Text(
              '即将购买，确认支付？',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userProvider.notifier)
                  .purchaseVip(package['level'] as int);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('购买成功！'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('确认支付'),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
