import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/book_widgets.dart';

class AuthorPage extends ConsumerWidget {
  const AuthorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(authorBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('作者中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthorStatsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAuthorHeader(),
          _buildQuickActions(context),
          Expanded(
            child: booksAsync.when(
              data: (books) => _buildBookList(context, books),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const EmptyState(
                icon: Icons.error_outline,
                title: '加载失败',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateBookPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('创建新书'),
      ),
    );
  }

  Widget _buildAuthorHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      '笔名作者',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.verified, color: Colors.amber, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '创作你的故事',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.account_balance_wallet,
              title: '收益概览',
              subtitle: '¥0.00',
              color: AppColors.success,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EarningsPage()),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              icon: Icons.analytics,
              title: '数据统计',
              subtitle: '查看详情',
              color: AppColors.info,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthorStatsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(BuildContext context, List<Book> books) {
    if (books.isEmpty) {
      return const EmptyState(
        icon: Icons.menu_book_outlined,
        title: '暂无作品',
        subtitle: '开始创作你的第一本书吧',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookItem(context, book);
      },
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthorBookDetailPage(book: book),
            ),
          );
        },
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              BookCover(
                coverUrl: book.cover,
                width: 60,
                height: 80,
                isVip: book.isVip,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.wordCountFormatted} | ${book.chapterCount}章 | ${book.statusText}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(Icons.visibility, book.viewCount.toString()),
                        const SizedBox(width: 12),
                        _buildStatChip(Icons.subscriptions, book.subscribeCount.toString()),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.grey400),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(color: AppColors.grey500),
        ),
      ],
    );
  }
}

class AuthorBookDetailPage extends StatelessWidget {
  final Book book;

  const AuthorBookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateBookPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
            title: '基本信息',
            children: [
              _buildInfoRow('状态', book.statusText),
              _buildInfoRow('字数', book.wordCountFormatted),
              _buildInfoRow('章节数', '${book.chapterCount}'),
              _buildInfoRow('订阅', '${book.subscribeCount}'),
            ],
          ),
          _buildSection(
            title: '最近章节',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('查看全部'),
            ),
            children: List.generate(3, (index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text('第${index + 1}章'),
                subtitle: Text('2024-01-01'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {},
                ),
              );
            }),
          ),
          _buildSection(
            title: '数据趋势',
            children: [
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics, size: 48, color: AppColors.grey300),
                      const SizedBox(height: 8),
                      Text(
                        '暂无数据',
                        style: TextStyle(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateChapterPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    List<Widget> children = const [],
    Widget? trailing,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.h5,
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
        if (child != null)
          child
        else
          ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.grey600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class AuthorStatsPage extends StatelessWidget {
  const AuthorStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTimeFilter(),
          const SizedBox(height: 16),
          _buildOverviewCard(),
          const SizedBox(height: 16),
          _buildTrendChart(),
          const SizedBox(height: 16),
          _buildRankList(),
        ],
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Row(
      children: [
        _buildFilterChip('今日', true),
        const SizedBox(width: 8),
        _buildFilterChip('本周', false),
        const SizedBox(width: 8),
        _buildFilterChip('本月', false),
        const SizedBox(width: 8),
        _buildFilterChip('全部', false),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.grey600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '总收益',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text(
                '0.00',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('阅读量', '0'),
              const SizedBox(width: 24),
              _buildStatItem('订阅数', '0'),
              const SizedBox(width: 24),
              _buildStatItem('新增章节', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('趋势图', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Center(
              child: Text(
                '暂无数据',
                style: TextStyle(color: AppColors.grey400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('热门章节', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.tagHot,
              child: Text('1', style: TextStyle(color: Colors.white)),
            ),
            title: const Text('第1章'),
            subtitle: const Text('阅读: 0'),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.tagRecommend,
              child: Text('2', style: TextStyle(color: Colors.white)),
            ),
            title: const Text('第2章'),
            subtitle: const Text('阅读: 0'),
          ),
        ],
      ),
    );
  }
}

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收益中心'),
      ),
      body: ListView(
        children: [
          _buildBalanceCard(),
          _buildEarningsList(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
        ),
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '可提现余额',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                '0.00',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '待结算: ¥0.00',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '累计收益: ¥0.00',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
                child: const Text('立即提现'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('收益明细', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_money, color: AppColors.success),
              ),
              title: const Text('订阅分成'),
              subtitle: Text('2024-01-01'),
              trailing: const Text(
                '+¥0.00',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CreateBookPage extends StatelessWidget {
  const CreateBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建新书'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '书名',
                hintText: '请输入书名',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '简介',
                hintText: '请输入书籍简介',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '分类',
                suffixIcon: Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '标签',
                hintText: '请输入标签，多个标签用逗号分隔',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('创建'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateChapterPage extends StatelessWidget {
  const CreateChapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布章节'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '章节标题',
                hintText: '请输入章节标题',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 20,
              decoration: const InputDecoration(
                labelText: '章节内容',
                hintText: '请输入章节内容',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('设为VIP章节'),
              subtitle: const Text('VIP用户免费阅读'),
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('发布'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 临时使用 Get 的 context
class Get {
  static BuildContext? _context;
  static BuildContext? get context => _context;
  static void setContext(BuildContext ctx) => _context = ctx;
}
