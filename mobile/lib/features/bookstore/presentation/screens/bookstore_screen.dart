import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/bookstore_provider.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../core/theme/app_theme.dart';

class BookstoreScreen extends ConsumerStatefulWidget {
  const BookstoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookstoreScreen> createState() => _BookstoreScreenState();
}

class _BookstoreScreenState extends ConsumerState<BookstoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(bookstoreProvider.notifier).loadCategories();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookstoreProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('书城'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '分类'),
            Tab(text: '排行'),
            Tab(text: '完本'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 分类页面
          _buildCategoryTab(state),
          // 排行榜页面
          _buildRankingTab(state),
          // 完本页面
          _buildCompletedTab(state),
        ],
      ),
    );
  }
  
  Widget _buildCategoryTab(BookstoreState state) {
    if (state.isLoading && state.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Row(
      children: [
        // 左侧分类导航
        Container(
          width: 100,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[100],
          child: ListView.builder(
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final isSelected = state.selectedCategory == category['id'];
              
              return ListTile(
                title: Text(
                  category['name'],
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                onTap: () {
                  ref.read(bookstoreProvider.notifier)
                      .selectCategory(category['id']);
                },
              );
            },
          ),
        ),
        
        // 右侧书籍列表
        Expanded(
          child: state.selectedBooks.isEmpty
              ? const Center(child: Text('暂无书籍'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: state.selectedBooks.length,
                  itemBuilder: (context, index) {
                    final book = state.selectedBooks[index];
                    return GestureDetector(
                      onTap: () => context.push('/book/${book.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: book.coverUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) =>
                                    const ShimmerBox(),
                                errorWidget: (context, url, error) =>
                                    Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book.title,
                            maxLines: 2,
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
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildRankingTab(BookstoreState state) {
    final rankingTypes = ['热度', '收藏', '评分', '月票'];
    
    return Column(
      children: [
        // 排行榜类型切换
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: rankingTypes.map((type) {
              final isSelected = state.rankingType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(bookstoreProvider.notifier)
                        .setRankingType(type);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        // 排行榜列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.rankingBooks.length,
            itemBuilder: (context, index) {
              final book = state.rankingBooks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: book.coverUrl,
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ShimmerBox(width: 50, height: 70),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.book),
                          ),
                        ),
                      ),
                      if (index < 3)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: [
                                Colors.amber,
                                Colors.grey[400]!,
                                Colors.brown[300]!
                              ][index],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              '${index + 1}',
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
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      Text(
                        '${(book.viewCount / 10000).toStringAsFixed(1)}万',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/book/${book.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompletedTab(BookstoreState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: state.completedBooks.length,
      itemBuilder: (context, index) {
        final book = state.completedBooks[index];
        return GestureDetector(
          onTap: () => context.push('/book/${book.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => const ShimmerBox(),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.book),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '完本',
                          style: TextStyle(
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
              const SizedBox(height: 8),
              Text(
                book.title,
                maxLines: 2,
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
        );
      },
    );
  }
  
  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: '搜索书名、作者...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.pop(context);
                          context.push('/search?q=$value');
                        }
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _buildSearchHistory(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchHistory() {
    final history = ['斗破苍穹', '完美世界', '凡人修仙传'];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '搜索历史',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: history.map((keyword) {
            return GestureDetector(
              onTap: () {
                _searchController.text = keyword;
                context.push('/search?q=$keyword');
                Navigator.pop(context);
              },
              child: Chip(
                label: Text(keyword),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {},
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          '热门搜索',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            '元尊',
            '雪中悍刀行',
            '庆余年',
            '全职高手',
            '择天记',
            '大主宰',
          ].map((keyword) {
            return GestureDetector(
              onTap: () {
                _searchController.text = keyword;
                context.push('/search?q=$keyword');
                Navigator.pop(context);
              },
              child: Chip(
                label: Text(keyword),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
