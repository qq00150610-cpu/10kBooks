import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/book_widgets.dart';

class BookstorePage extends ConsumerStatefulWidget {
  const BookstorePage({super.key});

  @override
  ConsumerState<BookstorePage> createState() => _BookstorePageState();
}

class _BookstorePageState extends ConsumerState<BookstorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategoryId = '';
  String _sortBy = 'hot';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书城'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '分类'),
            Tab(text: '排行榜'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryView(),
          _buildRankView(),
        ],
      ),
    );
  }

  Widget _buildCategoryView() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => CustomScrollView(
        slivers: [
          // 分类标签
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        category: Category(
                          id: '',
                          name: '全部',
                          icon: 'all',
                          bookCount: 0,
                          sort: 0,
                        ),
                        isSelected: _selectedCategoryId.isEmpty,
                        onTap: () => _selectCategory(''),
                      ),
                    );
                  }
                  final category = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      category: category,
                      isSelected: _selectedCategoryId == category.id,
                      onTap: () => _selectCategory(category.id),
                    ),
                  );
                },
              ),
            ),
          ),
          // 筛选排序
          SliverToBoxAdapter(
            child: _buildSortBar(),
          ),
          // 书籍列表
          _buildBookGrid(),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyState(
        icon: Icons.error_outline,
        title: '加载失败',
        subtitle: '请检查网络连接',
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildSortChip('热门', 'hot', _sortBy == 'hot'),
          const SizedBox(width: 8),
          _buildSortChip('最新', 'new', _sortBy == 'new'),
          const SizedBox(width: 8),
          _buildSortChip('评分', 'rating', _sortBy == 'rating'),
          const SizedBox(width: 8),
          _buildSortChip('字数', 'words', _sortBy == 'words'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list, size: 20),
            onPressed: _showFilterSheet,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primary : AppColors.grey600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBookGrid() {
    final booksAsync = _selectedCategoryId.isEmpty
        ? ref.watch(homeRecommendBooksProvider)
        : ref.watch(booksByCategoryProvider(_selectedCategoryId));

    return booksAsync.when(
      data: (books) => SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.55,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return BookGridItem(
                book: books[index],
                width: (MediaQuery.of(context).size.width - 44) / 3,
                onTap: () {
                  // 跳转到书籍详情
                },
              );
            },
            childCount: books.length,
          ),
        ),
      ),
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.error_outline,
          title: '加载失败',
        ),
      ),
    );
  }

  Widget _buildRankView() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '总榜'),
              Tab(text: '月票榜'),
              Tab(text: '新书榜'),
              Tab(text: '热搜榜'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRankList('total'),
                _buildRankList('monthly'),
                _buildRankList('new'),
                _buildRankList('hot'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankList(String type) {
    final hotBooksAsync = ref.watch(homeHotBooksProvider);

    return hotBooksAsync.when(
      data: (books) => ListView.separated(
        itemCount: books.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return HotRankItem(
            book: books[index],
            rank: index + 1,
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
    );
  }

  void _selectCategory(String categoryId) {
    setState(() => _selectedCategoryId = categoryId);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('筛选', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // 重置筛选
                  },
                  child: const Text('重置'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('题材', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['全部', '玄幻', '都市', '科幻', '历史', '武侠'].map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: false,
                  onSelected: (_) {},
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('状态', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['全部', '连载中', '已完结'].map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: false,
                  onSelected: (_) {},
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('价格', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['全部', '免费', '付费'].map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: false,
                  onSelected: (_) {},
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showSearch(
      context: context,
      delegate: BookSearchDelegate(ref),
    );
  }
}

class BookSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  BookSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('请输入搜索关键词'),
      );
    }

    final searchAsync = ref.watch(searchProvider(query));

    return searchAsync.when(
      data: (books) => ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return BookListTile(
            book: books[index],
            onTap: () {
              close(context, books[index].id);
            },
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('搜索失败')),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildHotSearch();
    }
    return buildResults(context);
  }

  Widget _buildHotSearch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '热门搜索',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '斗破苍穹',
              '完美世界',
              '庆余年',
              '全职高手',
              '凡人修仙传',
              '雪中悍刀行',
            ].map((keyword) {
              return GestureDetector(
                onTap: () {
                  query = keyword;
                  showResults(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(keyword),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
