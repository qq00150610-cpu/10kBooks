import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/bookshelf_provider.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../core/theme/app_theme.dart';

class BookshelfScreen extends ConsumerStatefulWidget {
  const BookshelfScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends ConsumerState<BookshelfScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(bookshelfProvider.notifier).loadBookshelf();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookshelfProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的书架'),
        actions: [
          if (state.myBooks.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              child: Text(_isEditMode ? '完成' : '编辑'),
            ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '在读'),
            Tab(text: '已购'),
            Tab(text: '缓存'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReadingTab(state),
          _buildPurchasedTab(state),
          _buildCachedTab(state),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bookstore'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildReadingTab(BookshelfState state) {
    if (state.isLoading && state.myBooks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.myBooks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.book_outlined,
        title: '书架空空如也',
        subtitle: '快去书城看看有什么好看的书吧',
        buttonText: '去书城',
        onPressed: () => context.go('/bookstore'),
      );
    }
    
    return Column(
      children: [
        // 阅读统计
        _buildReadingStats(state),
        
        // 书籍列表
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
            itemCount: state.myBooks.length,
            itemBuilder: (context, index) {
              final book = state.myBooks[index];
              final progress = state.readingProgress[book.id] ?? 0.0;
              final isSelected = state.selectedBooks.contains(book.id);
              
              return GestureDetector(
                onTap: () {
                  if (_isEditMode) {
                    ref.read(bookshelfProvider.notifier)
                        .toggleBookSelection(book.id);
                  } else {
                    context.push('/reader/${book.id}');
                  }
                },
                onLongPress: () {
                  if (!_isEditMode) {
                    setState(() {
                      _isEditMode = true;
                    });
                    ref.read(bookshelfProvider.notifier)
                        .toggleBookSelection(book.id);
                  }
                },
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
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
                                // 阅读进度
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(8),
                                      ),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            bottom: Radius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (_isEditMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // 批量操作栏
        if (_isEditMode) _buildBatchActions(state),
      ],
    );
  }
  
  Widget _buildPurchasedTab(BookstoreState state) {
    final purchasedBooks = ref.watch(bookshelfProvider).myBooks
        .where((book) => book.isVipOnly)
        .toList();
    
    if (purchasedBooks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: '暂无已购书籍',
        subtitle: '购买VIP会员或单章解锁更多内容',
        buttonText: '了解更多',
        onPressed: () => context.push('/vip'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purchasedBooks.length,
      itemBuilder: (context, index) {
        final book = purchasedBooks[index];
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
                placeholder: (context, url) => const ShimmerBox(width: 50, height: 70),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.book),
                ),
              ),
            ),
            title: Text(book.title),
            subtitle: Text('已解锁全本'),
            trailing: ElevatedButton(
              onPressed: () => context.push('/reader/${book.id}'),
              child: const Text('阅读'),
            ),
            onTap: () => context.push('/book/${book.id}'),
          ),
        );
      },
    );
  }
  
  Widget _buildCachedTab(BookshelfState state) {
    final cachedBooks = ref.watch(bookshelfProvider).cachedBooks;
    
    if (cachedBooks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.download_outlined,
        title: '暂无缓存书籍',
        subtitle: '下载书籍以便离线阅读',
        buttonText: '管理缓存',
        onPressed: () {},
      );
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已缓存 ${cachedBooks.length} 本书籍',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('清理全部'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cachedBooks.length,
            itemBuilder: (context, index) {
              final book = cachedBooks[index];
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
                      placeholder: (context, url) => const ShimmerBox(width: 50, height: 70),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.book),
                      ),
                    ),
                  ),
                  title: Text(book.title),
                  subtitle: Text('${book.chapterCount} 章已缓存'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(bookshelfProvider.notifier)
                          .removeCachedBook(book.id);
                    },
                  ),
                  onTap: () => context.push('/reader/${book.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildReadingStats(BookshelfState state) {
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('在读', '${state.myBooks.length}', Icons.book),
          _buildStatItem('今日阅读', '${state.todayReadTime}分钟', Icons.schedule),
          _buildStatItem('累计阅读', '${state.totalReadTime}小时', Icons.emoji_events),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '排序方式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('最近阅读'),
              onTap: () {
                ref.read(bookshelfProvider.notifier).setSortType('recent');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('书名排序'),
              onTap: () {
                ref.read(bookshelfProvider.notifier).setSortType('title');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('加入时间'),
              onTap: () {
                ref.read(bookshelfProvider.notifier).setSortType('added');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.percent),
              title: const Text('阅读进度'),
              onTap: () {
                ref.read(bookshelfProvider.notifier).setSortType('progress');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBatchActions(BookshelfState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '已选择 ${state.selectedBooks.length} 本',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ref.read(bookshelfProvider.notifier).selectAll();
            },
            child: const Text('全选'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: state.selectedBooks.isEmpty
                ? null
                : () {
                    ref.read(bookshelfProvider.notifier)
                        .deleteSelectedBooks();
                    setState(() {
                      _isEditMode = false;
                    });
                  },
            icon: const Icon(Icons.delete),
            label: const Text('删除'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// 引用 BookstoreState
class BookstoreState {}
