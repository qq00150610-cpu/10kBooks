import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/author_provider.dart';
import '../../../../core/theme/app_theme.dart';

class AuthorBookEditScreen extends ConsumerStatefulWidget {
  final String bookId;
  
  const AuthorBookEditScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  ConsumerState<AuthorBookEditScreen> createState() => _AuthorBookEditScreenState();
}

class _AuthorBookEditScreenState extends ConsumerState<AuthorBookEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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
        title: const Text('书籍管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '基本信息'),
            Tab(text: '章节管理'),
            Tab(text: '数据统计'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildChapterTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChapterDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.book, size: 50),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 书名
          const Text('书名', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: '逆天改命',
            decoration: const InputDecoration(
              hintText: '请输入书名',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 分类
          const Text('分类', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: '玄幻',
            items: ['玄幻', '都市', '仙侠', '科幻', '言情']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {},
          ),
          
          const SizedBox(height: 16),
          
          // 简介
          const Text('简介', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: '这是一个精彩的故事...',
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '请输入书籍简介',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 收费模式
          const Text('收费模式', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('VIP付费'),
            subtitle: const Text('开启后VIP会员可免费阅读'),
            value: true,
            onChanged: (value) {},
          ),
          
          const SizedBox(height: 16),
          
          // 标签
          const Text('标签', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['热血', '升级', '爽文', '玄幻']
                .map((tag) => Chip(label: Text(tag)))
                .toList(),
          ),
          
          const SizedBox(height: 32),
          
          // 保存按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('保存成功')),
                );
              },
              child: const Text('保存修改'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChapterTab() {
    final chapters = List.generate(10, (index) {
      return {
        'id': 'chapter_$index',
        'title': '第${index + 1}章：新的开始',
        'words': 3000 + index * 100,
        'date': '2024-01-${15 - index}',
        'status': index < 8 ? '已发布' : '待发布',
      };
    });
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(chapter['title'] as String),
            subtitle: Text('${chapter['words']}字 · ${chapter['date']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: chapter['status'] == '已发布'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    chapter['status'] as String,
                    style: TextStyle(
                      color: chapter['status'] == '已发布'
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('编辑')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                    if (chapter['status'] == '待发布')
                      const PopupMenuItem(value: 'publish', child: Text('发布')),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditChapterDialog(chapter);
                    } else if (value == 'delete') {
                      _showDeleteConfirm(chapter);
                    } else if (value == 'publish') {
                      // 发布
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '阅读趋势',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text('图表区域', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            '详细数据',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatRow('总阅读', '125,680'),
          _buildStatRow('总收藏', '5,234'),
          _buildStatRow('总评论', '1,234'),
          _buildStatRow('总订阅', '3,456'),
          _buildStatRow('总收益', '¥1,234.56'),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
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
  
  void _showAddChapterDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isVip = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const Text(
                    '发布章节',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('发布成功')),
                      );
                    },
                    child: const Text('发布'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '章节标题',
                        hintText: '例如：第一章 新的开始',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('设为VIP章节'),
                      value: isVip,
                      onChanged: (value) => isVip = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      maxLines: 15,
                      decoration: const InputDecoration(
                        labelText: '章节内容',
                        hintText: '开始写作吧...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditChapterDialog(dynamic chapter) {
    final titleController = TextEditingController(text: chapter['title'] as String);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑章节'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: '章节标题'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirm(dynamic chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除章节'),
        content: const Text('确定要删除这个章节吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('删除成功')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
