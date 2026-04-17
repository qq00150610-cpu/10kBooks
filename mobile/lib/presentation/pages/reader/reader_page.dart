import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String bookId;

  const ReaderPage({super.key, required this.bookId});

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  late PageController _pageController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _enterImmersiveMode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _exitImmersiveMode();
    super.dispose();
  }

  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _exitImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerProvider(widget.bookId));
    final settings = ref.watch(readerSettingsProvider);

    return Scaffold(
      backgroundColor: settings.theme.backgroundColor,
      body: Stack(
        children: [
          // 阅读内容
          GestureDetector(
            onTap: _toggleControls,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 100, // 模拟总页数
              itemBuilder: (context, index) {
                return _buildPageContent(index, settings);
              },
            ),
          ),

          // 顶部导航
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(readerState),
            ),

          // 底部工具栏
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(readerState),
            ),

          // 加载指示器
          if (readerState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int pageIndex, ReaderSettings settings) {
    // 模拟阅读内容
    final content = _generateSampleContent(pageIndex);

    return Container(
      color: settings.theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: SingleChildScrollView(
        child: Text(
          content,
          style: TextStyle(
            fontSize: settings.fontSize,
            height: settings.lineHeight,
            color: settings.theme.textColor,
            fontFamily: settings.fontFamily,
          ),
        ),
      ),
    );
  }

  String _generateSampleContent(int page) {
    return '''
第${page + 1}页

这是一个示例阅读内容。在实际应用中，这里会显示从服务器获取的书籍章节内容。

阅读器支持多种功能：
• 字体大小调整
• 行间距调整
• 主题切换（白天/夜间/护眼）
• 书签功能
• 笔记功能
• 目录导航

感谢使用万卷书苑！
''';
  }

  Widget _buildTopBar(ReaderState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.book?.title ?? '书籍标题',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '第${state.currentChapter?.number ?? 1}章',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showMoreMenu(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ReaderState state) {
    final settings = ref.watch(readerSettingsProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 章节导航
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: state.hasPrevChapter
                        ? () => ref.read(readerProvider(widget.bookId).notifier).prevChapter()
                        : null,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showChapterList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '目录',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: state.hasNextChapter
                        ? () => ref.read(readerProvider(widget.bookId).notifier).nextChapter()
                        : null,
                  ),
                ],
              ),
            ),
            // 底部工具
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildToolButton(
                    icon: Icons.settings,
                    label: '设置',
                    onTap: () => _showSettingsSheet(),
                  ),
                  _buildToolButton(
                    icon: Icons.bookmark_border,
                    label: '书签',
                    onTap: () => _addBookmark(),
                  ),
                  _buildToolButton(
                    icon: Icons.edit_note,
                    label: '笔记',
                    onTap: () => _addNote(),
                  ),
                  _buildToolButton(
                    icon: Icons.light_mode,
                    label: '主题',
                    onTap: () => _showThemeSheet(),
                  ),
                  _buildToolButton(
                    icon: Icons.aod,
                    label: '听书',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('目录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: index < 10 ? AppColors.primary : AppColors.grey200,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: index < 10 ? Colors.white : AppColors.grey600,
                          ),
                        ),
                      ),
                      title: Text('第${index + 1}章'),
                      trailing: index > 50
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.vipGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VIP',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.vipGold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        // 跳转章节
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    final settingsNotifier = ref.read(readerSettingsProvider.notifier);
    final settings = ref.watch(readerSettingsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('阅读设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // 字体大小
              Row(
                children: [
                  const Text('字体大小'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      settingsNotifier.decreaseFontSize();
                    },
                  ),
                  Text('${settings.fontSize.toInt()}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      settingsNotifier.increaseFontSize();
                    },
                  ),
                ],
              ),
              Slider(
                value: settings.fontSize,
                min: 12,
                max: 32,
                divisions: 10,
                onChanged: (value) => settingsNotifier.setFontSize(value),
              ),
              const SizedBox(height: 16),
              // 行间距
              const Text('行间距'),
              Slider(
                value: settings.lineHeight,
                min: 1.2,
                max: 2.0,
                divisions: 8,
                onChanged: (value) => settingsNotifier.setLineHeight(value),
              ),
              const SizedBox(height: 16),
              // 显示页码
              Row(
                children: [
                  const Text('显示页码'),
                  const Spacer(),
                  Switch(
                    value: settings.showPageNumber,
                    onChanged: (value) => settingsNotifier.setShowPageNumber(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSheet() {
    final settingsNotifier = ref.read(readerSettingsProvider.notifier);
    final settings = ref.watch(readerSettingsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('阅读主题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ReaderTheme.values.map((theme) {
                final isSelected = settings.theme == theme;
                return GestureDetector(
                  onTap: () => settingsNotifier.setTheme(theme),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.grey300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Aa',
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        theme.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? AppColors.primary : AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _addBookmark() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('书签已添加')),
    );
  }

  void _addNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加笔记'),
        content: TextField(
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '输入笔记内容...',
            border: OutlineInputBorder(),
          ),
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
                const SnackBar(content: Text('笔记已保存')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('下载章节'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('内容反馈'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
