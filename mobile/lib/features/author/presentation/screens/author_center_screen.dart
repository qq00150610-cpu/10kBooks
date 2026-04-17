import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/author_provider.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../core/theme/app_theme.dart';

class AuthorCenterScreen extends ConsumerStatefulWidget {
  const AuthorCenterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthorCenterScreen> createState() => _AuthorCenterScreenState();
}

class _AuthorCenterScreenState extends ConsumerState<AuthorCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(authorProvider.notifier).loadAuthorData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('作者中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '作品管理'),
            Tab(text: '数据统计'),
            Tab(text: '收益中心'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: Column(
        children: [
          // 作者信息卡片
          _buildAuthorCard(state),

          // Tab 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWorksTab(state),
                _buildStatsTab(state),
                _buildEarningsTab(state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 创建新书
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('创建新书', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAuthorCard(AuthorState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(state.author?.avatarUrl ?? ''),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.author?.nickname ?? '作者',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildTag('原创作者'),
                    const SizedBox(width: 8),
                    _buildTag('Lv.${state.author?.level ?? 1}'),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('编辑资料'),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildWorksTab(AuthorState state) {
    if (state.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              '还没有作品',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '开始创作你的第一部作品吧',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('创建新书'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.books.length,
      itemBuilder: (context, index) {
        final book = state.books[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.push('/author/book/${book.id}'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerBox(width: 60, height: 80),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.book),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${book.chapterCount}章 · ${book.wordCount ~/ 10000}万字',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(
                              book.isCompleted ? '已完结' : '连载中',
                              book.isCompleted ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                              book.isVipOnly ? '付费' : '免费',
                              book.isVipOnly ? Colors.purple : Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsTab(AuthorState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日数据
          const Text(
            '今日数据',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('阅读', '${state.todayViews}', Icons.visibility)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('新增', '${state.todayNewFollowers}', Icons.person_add)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('收入', '${state.todayEarnings}元', Icons.monetization_on)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 累计数据
          const Text(
            '累计数据',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatItem('总阅读量', '${state.totalViews}'),
          _buildStatItem('总收藏', '${state.totalCollects}'),
          _buildStatItem('总评论', '${state.totalComments}'),
          _buildStatItem('总收益', '${state.totalEarnings}元'),
          
          const SizedBox(height: 24),
          
          // 排行榜
          const Text(
            '作品排行',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...state.books.take(3).asMap().entries.map((entry) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: [Colors.amber, Colors.grey, Colors.brown][entry.key],
                child: Text('${entry.key + 1}'),
              ),
              title: Text(entry.value.title),
              subtitle: Text('阅读 ${state.totalViews - entry.key * 10000}'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEarningsTab(AuthorState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 收益概览
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  '可提现余额',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '¥${state.balance}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state.balance > 0
                      ? () => _handleWithdraw()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                  ),
                  child: const Text('立即提现'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 收益明细
          const Text(
            '收益明细',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ListTile(
            leading: const Icon(Icons.book, color: AppTheme.primaryColor),
            title: const Text('订阅收入'),
            subtitle: const Text('VIP章节订阅分成'),
            trailing: const Text('¥128.50'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('打赏收入'),
            subtitle: const Text('读者打赏分成'),
            trailing: const Text('¥36.00'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.card_giftcard, color: Colors.red),
            title: const Text('礼物收入'),
            subtitle: const Text('礼物分成'),
            trailing: const Text('¥15.50'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.green),
            title: const Text('全勤奖励'),
            subtitle: const Text('本月全勤奖励'),
            trailing: const Text('¥50.00'),
          ),
          
          const SizedBox(height: 24),
          
          // 提现记录
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '提现记录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('查看全部'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildWithdrawItem('2024-01-15', '¥200.00', '已到账'),
          _buildWithdrawItem('2024-01-01', '¥150.00', '已到账'),
        ],
      ),
    );
  }

  Widget _buildWithdrawItem(String date, String amount, String status) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(date),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleWithdraw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提现'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('可提现金额：¥230.00'),
            SizedBox(height: 16),
            Text('请输入提现金额：'),
            SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '¥',
                hintText: '最低10元起提',
              ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('提现申请已提交')),
              );
            },
            child: const Text('确认提现'),
          ),
        ],
      ),
    );
  }
}
