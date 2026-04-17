import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/book_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              // 顶部导航
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              // 轮播图
              SliverToBoxAdapter(
                child: _buildBanner(),
              ),
              // 分类导航
              SliverToBoxAdapter(
                child: _buildCategoryNav(),
              ),
              // 热门榜单
              SliverToBoxAdapter(
                child: _buildHotRank(),
              ),
              // 新书上架
              SliverToBoxAdapter(
                child: _buildNewBooks(),
              ),
              // 为你推荐
              SliverToBoxAdapter(
                child: _buildRecommend(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '万卷书苑',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const Spacer(),
          // 搜索按钮
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.grey600),
            onPressed: () {
              // 跳转到搜索页面
            },
          ),
          // 消息按钮
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.grey600),
            ),
            onPressed: () {
              // 跳转到消息页面
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    final bannersAsync = ref.watch(homeBannersProvider);

    return bannersAsync.when(
      data: (banners) => Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: PageView.builder(
          itemCount: banners.isEmpty ? 1 : banners.length,
          itemBuilder: (context, index) {
            if (banners.isEmpty) {
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book, size: 48, color: Colors.white54),
                      SizedBox(height: 8),
                      Text(
                        '万卷书苑',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final banner = banners[index];
            return GestureDetector(
              onTap: () {
                // 处理banner点击
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.grey200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppNetworkImage(
                    imageUrl: banner.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      loading: () => Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryNav() {
    final categoriesAsync = ref.watch(categoriesProvider);

    final defaultCategories = [
      {'icon': Icons.menu_book, 'name': '小说'},
      {'icon': Icons.psychology, 'name': '心理'},
      {'icon': Icons.science, 'name': '科幻'},
      {'icon': Icons.history_edu, 'name': '历史'},
      {'icon': Icons.business, 'name': '商业'},
      {'icon': Icons.emoji_emotions, 'name': '情感'},
      {'icon': Icons.computer, 'name': '科技'},
      {'icon': Icons.more_horiz, 'name': '更多'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: categoriesAsync.when(
        data: (categories) => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: categories.isEmpty ? defaultCategories.length : categories.length,
          itemBuilder: (context, index) {
            if (categories.isEmpty) {
              final cat = defaultCategories[index];
              return _buildCategoryItem(
                icon: cat['icon'] as IconData,
                name: cat['name'] as String,
              );
            }
            final category = categories[index];
            return _buildCategoryItem(
              icon: Icons.category,
              name: category.name,
              onTap: () {
                // 跳转到分类页面
              },
            );
          },
        ),
        loading: () => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: defaultCategories.length,
          itemBuilder: (context, index) {
            final cat = defaultCategories[index];
            return _buildCategoryItem(
              icon: cat['icon'] as IconData,
              name: cat['name'] as String,
            );
          },
        ),
        error: (_, __) => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: defaultCategories.length,
          itemBuilder: (context, index) {
            final cat = defaultCategories[index];
            return _buildCategoryItem(
              icon: cat['icon'] as IconData,
              name: cat['name'] as String,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String name,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHotRank() {
    final hotBooksAsync = ref.watch(homeHotBooksProvider);

    return Column(
      children: [
        const SectionHeader(
          title: '🔥 热门榜单',
          actionText: '查看更多',
        ),
        SizedBox(
          height: 180,
          child: hotBooksAsync.when(
            data: (books) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: BookCard(
                    book: books[index],
                    width: 100,
                    onTap: () {
                      // 跳转到书籍详情
                    },
                  ),
                );
              },
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: BookCardSkeleton(),
              ),
            ),
            error: (_, __) => const EmptyState(
              icon: Icons.error_outline,
              title: '加载失败',
              subtitle: '请检查网络连接',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewBooks() {
    final newBooksAsync = ref.watch(homeNewBooksProvider);

    return Column(
      children: [
        const SectionHeader(
          title: '📚 新书上架',
          actionText: '更多',
        ),
        SizedBox(
          height: 180,
          child: newBooksAsync.when(
            data: (books) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: BookCard(
                    book: books[index],
                    width: 100,
                    onTap: () {
                      // 跳转到书籍详情
                    },
                  ),
                );
              },
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: BookCardSkeleton(),
              ),
            ),
            error: (_, __) => const EmptyState(
              icon: Icons.error_outline,
              title: '加载失败',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommend() {
    final recommendBooksAsync = ref.watch(homeRecommendBooksProvider);

    return Column(
      children: [
        const SectionHeader(
          title: '⭐ 为你推荐',
        ),
        recommendBooksAsync.when(
          data: (books) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return BookGridItem(
                book: books[index],
                width: (MediaQuery.of(context).size.width - 40) / 3,
                onTap: () {
                  // 跳转到书籍详情
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const EmptyState(
            icon: Icons.error_outline,
            title: '加载失败',
          ),
        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    ref.invalidate(homeBannersProvider);
    ref.invalidate(homeHotBooksProvider);
    ref.invalidate(homeNewBooksProvider);
    ref.invalidate(homeRecommendBooksProvider);
    ref.invalidate(categoriesProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
