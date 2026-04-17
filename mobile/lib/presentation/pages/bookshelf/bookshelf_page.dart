import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/book_widgets.dart';

class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends ConsumerState<BookshelfPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditMode = false;
  final Set<String> _selectedBooks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() => _isEditMode = true);
              },
            )
          else ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  _selectedBooks.clear();
                });
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: _selectedBooks.isEmpty
                  ? null
                  : () {
                      // 批量删除
                    },
              child: Text('删除(${_selectedBooks.length})'),
            ),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'sort':
                  _showSortMenu();
                  break;
                case 'download':
                  _showDownloadDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 20),
                    SizedBox(width: 8),
                    Text('排序'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('批量下载'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '我的书籍'),
            Tab(text: '下载管理'),
            Tab(text: '阅读历史'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyBooksView(),
          _buildDownloadsView(),
          _buildHistoryView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 添加书籍
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMyBooksView() {
    final myBooksAsync = ref.watch(myBooksProvider);

    return myBooksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return EmptyState(
            icon: Icons.library_books_outlined,
            title: '书架空空如也',
            subtitle: '快去书城添加喜欢的书籍吧',
            buttonText: '去书城',
            onButtonPressed: () {
              // 跳转到书城
            },
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final isSelected = _selectedBooks.contains(book.id);

            return BookshelfItem(
              book: book,
              progress: 0.3, // 模拟进度
              isSelected: isSelected,
              onTap: () {
                if (_isEditMode) {
                  setState(() {
                    if (isSelected) {
                      _selectedBooks.remove(book.id);
                    } else {
                      _selectedBooks.add(book.id);
                    }
                  });
                } else {
                  // 跳转到阅读器
                }
              },
              onLongPress: () {
                if (!_isEditMode) {
                  setState(() {
                    _isEditMode = true;
                    _selectedBooks.add(book.id);
                  });
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyState(
        icon: Icons.error_outline,
        title: '加载失败',
        subtitle: '请检查网络连接',
      ),
    );
  }

  Widget _buildDownloadsView() {
    // 下载管理列表
    return EmptyState(
      icon: Icons.download_outlined,
      title: '暂无下载',
      subtitle: '在书籍详情页可下载离线阅读',
    );
  }

  Widget _buildHistoryView() {
    // 阅读历史列表
    return EmptyState(
      icon: Icons.history,
      title: '暂无阅读记录',
      subtitle: '开始阅读后记录将显示在这里',
    );
  }

  void _showSortMenu() {
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('最近阅读'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('书名排序'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('最近更新'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDownloadDialog() {
    if (_selectedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要下载的书籍')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量下载'),
        content: Text('确定要下载选中的 ${_selectedBooks.length} 本书籍吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行批量下载
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class BookshelfDetailPage extends ConsumerWidget {
  final String bookId;

  const BookshelfDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookDetailAsync = ref.watch(bookDetailProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('书籍详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: bookDetailAsync.when(
        data: (book) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(book),
            ),
            SliverToBoxAdapter(
              child: _buildChapterList(book),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline,
          title: '加载失败',
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(Book book) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            coverUrl: book.cover,
            width: 120,
            height: 160,
            isVip: book.isVip,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: AppTextStyles.h4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  book.author,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingStars(rating: book.rating, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      book.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${book.wordCountFormatted} | ${book.chapterCount}章 | ${book.statusText}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: book.tags.take(3).map((tag) {
                    return TagBadge(
                      text: tag,
                      color: AppColors.grey500,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList(Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('目录', style: AppTextStyles.h5),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 20,
          itemBuilder: (context, index) {
            return ChapterListItem(
              chapter: Chapter(
                id: '$index',
                bookId: book.id,
                number: index + 1,
                title: '第${index + 1}章',
                wordCount: 3000,
                isVip: index > 10,
                isLock: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              isCurrent: index == 0,
              onTap: () {
                // 跳转到阅读器
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // 加入书架
                },
                child: const Text('加入书架'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // 开始阅读
                },
                child: const Text('开始阅读'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
