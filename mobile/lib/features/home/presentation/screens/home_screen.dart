import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../providers/home_provider.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 加载首页数据
    Future.microtask(() {
      ref.read(homeProvider.notifier).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部导航栏
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppTheme.primaryColor,
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '万卷书苑',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.white),
                              onPressed: () => context.push('/search'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '发现你的阅读世界',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 内容区域
          if (homeState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            // 轮播推荐
            if (homeState.bannerBooks.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildBanner(homeState),
              ),
            
            // 分类导航
            SliverToBoxAdapter(
              child: _buildCategoryNav(context),
            ),
            
            // 热门榜单
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: '🔥 热门榜单',
                moreText: '查看全部',
                onMore: () {},
                child: _buildHotList(homeState),
              ),
            ),
            
            // 新书上架
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: '📚 新书上架',
                moreText: '更多新书',
                onMore: () {},
                child: _buildNewBooks(homeState),
              ),
            ),
            
            // 精品推荐
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: '⭐ 精品推荐',
                moreText: '换一批',
                onMore: () {},
                child: _buildRecommendedBooks(homeState),
              ),
            ),
            
            // 猜你喜欢
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: '💡 猜你喜欢',
                moreText: '',
                onMore: () {},
                child: _buildForYouBooks(homeState),
              ),
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ],
      ),
    );
  }
  
  Widget _buildBanner(HomeState state) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Swiper(
          itemBuilder: (context, index) {
            final book = state.bannerBooks[index];
            return GestureDetector(
              onTap: () => context.push('/book/${book.id}'),
              child: CachedNetworkImage(
                imageUrl: book.coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerBox(),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.book, size: 50),
                ),
              ),
            );
          },
          itemCount: state.bannerBooks.length,
          autoplay: true,
          pagination: const SwiperPagination(
            alignment: Alignment.bottomCenter,
            builder: DotSwiperPaginationBuilder(
              activeColor: AppTheme.primaryColor,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryNav(BuildContext context) {
    final categories = [
      {'icon': Icons.auto_stories, 'name': '小说', 'color': Colors.blue},
      {'icon': Icons.favorite, 'name': '言情', 'color': Colors.pink},
      {'icon': Icons.auto_awesome, 'name': '玄幻', 'color': Colors.purple},
      {'icon': Icons.location_city, 'name': '都市', 'color': Colors.green},
      {'icon': Icons.rocket_launch, 'name': '科幻', 'color': Colors.orange},
      {'icon': Icons.search, 'name': '悬疑', 'color': Colors.brown},
      {'icon': Icons.history_edu, 'name': '历史', 'color': Colors.teal},
      {'icon': Icons.library_books, 'name': '更多', 'color': Colors.grey},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => context.push('/category/${category['name']}'),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String moreText,
    required VoidCallback onMore,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (moreText.isNotEmpty)
                  TextButton(
                    onPressed: onMore,
                    child: Row(
                      children: [
                        Text(moreText),
                        const Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
  
  Widget _buildHotList(HomeState state) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.hotBooks.length,
        itemBuilder: (context, index) {
          final book = state.hotBooks[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/book/${book.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: book.coverUrl,
                          width: 100,
                          height: 130,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ShimmerBox(),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.book),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'TOP ${index + 1}',
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
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNewBooks(HomeState state) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.newBooks.length,
        itemBuilder: (context, index) {
          final book = state.newBooks[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/book/${book.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      width: 140,
                      height: 150,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerBox(),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.book),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRecommendedBooks(HomeState state) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.recommendedBooks.length,
        itemBuilder: (context, index) {
          final book = state.recommendedBooks[index];
          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () => context.push('/book/${book.id}'),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      width: 90,
                      height: 130,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerBox(),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${book.wordCount ~/ 10000}万字',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            book.category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildForYouBooks(HomeState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: state.forYouBooks.take(5).map((book) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerBox(),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.book),
                  ),
                ),
              ),
              title: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${book.author} · ${book.category}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: ElevatedButton(
                onPressed: () => context.push('/reader/${book.id}'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('阅读'),
              ),
              onTap: () => context.push('/book/${book.id}'),
            ),
          );
        }).toList(),
      ),
    );
  }
}
