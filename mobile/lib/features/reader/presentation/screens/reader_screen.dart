import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reader_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/book_model.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId;
  
  const ReaderScreen({
    Key? key,
    required this.bookId,
    this.chapterId,
  }) : super(key: key);
  
  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _isControlsVisible = true;
  bool _is immersiveMode = false;
  
  @override
  void initState() {
    super.initState();
    // 进入沉浸模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    Future.microtask(() {
      ref.read(readerProvider.notifier).loadBook(widget.bookId);
    });
  }
  
  @override
  void dispose() {
    // 退出沉浸模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
  
  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
      _is immersiveMode = !_isControlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          // 阅读内容
          GestureDetector(
            onTap: _toggleControls,
            child: _buildReadingContent(state),
          ),
          
          // 顶部控制栏
          if (_isControlsVisible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(state),
            ),
          
          // 底部控制栏
          if (_isControlsVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(state),
            ),
          
          // 左侧翻页区域
          if (_isControlsVisible)
            Positioned(
              left: 0,
              top: 100,
              bottom: 100,
              width: 80,
              child: GestureDetector(
                onTap: () => ref.read(readerProvider.notifier).prevChapter(),
                child: Container(color: Colors.transparent),
              ),
            ),
          
          // 右侧翻页区域
          if (_isControlsVisible)
            Positioned(
              right: 0,
              top: 100,
              bottom: 100,
              width: 80,
              child: GestureDetector(
                onTap: () => ref.read(readerProvider.notifier).nextChapter(),
                child: Container(color: Colors.transparent),
              ),
            ),
          
          // 中间点击区域 - 下一章
          if (_isControlsVisible)
            Positioned(
              left: 80,
              right: 80,
              top: MediaQuery.of(context).size.height / 2 - 50,
              child: GestureDetector(
                onTap: () => ref.read(readerProvider.notifier).nextChapter(),
                child: Container(
                  height: 100,
                  color: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildReadingContent(ReaderState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '加载中...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    if (state.currentChapter == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('暂无内容'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/bookstore'),
              child: const Text('去书城'),
            ),
          ],
        ),
      );
    }
    
    final bgColor = state.readerTheme.backgroundColor;
    
    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        controller: ref.read(readerProvider).scrollController,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: MediaQuery.of(context).padding.top + 60,
          bottom: MediaQuery.of(context).padding.bottom + 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 章节标题
            Center(
              child: Text(
                state.currentChapter!.title,
                style: TextStyle(
                  fontSize: state.fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: state.readerTheme.textColor,
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 章节内容
            Text(
              state.currentChapter!.content.isNotEmpty
                  ? state.currentChapter!.content
                  : _generateMockContent(),
              style: TextStyle(
                fontSize: state.fontSize,
                color: state.readerTheme.textColor,
                height: state.lineHeight,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // 章节结束提示
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 2,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '本章完',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(readerProvider.notifier).nextChapter(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('下一章'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopBar(ReaderState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.book?.title ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (state.currentChapter != null)
                      Text(
                        '第${state.currentChapter!.index}章 ${state.currentChapter!.title}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () => _showBookmarkDialog(state),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showMoreOptions(state),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomBar(ReaderState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 章节导航
            _buildChapterNav(state),
            
            const SizedBox(height: 8),
            
            // 底部工具栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildToolButton(
                    icon: Icons.format_list_bulleted,
                    label: '目录',
                    onTap: () => _showChapterList(state),
                  ),
                  _buildToolButton(
                    icon: Icons.format_size,
                    label: '字体',
                    onTap: () => _showFontSettings(state),
                  ),
                  _buildToolButton(
                    icon: Icons.brightness_6,
                    label: '亮度',
                    onTap: () => _showBrightnessSettings(state),
                  ),
                  _buildToolButton(
                    icon: Icons.palette,
                    label: '主题',
                    onTap: () => _showThemeSettings(state),
                  ),
                  _buildToolButton(
                    icon: Icons.auto_stories,
                    label: '设置',
                    onTap: () => _showReaderSettings(state),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChapterNav(ReaderState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            onPressed: state.currentChapter?.index > 1
                ? () => ref.read(readerProvider.notifier).prevChapter()
                : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          GestureDetector(
            onTap: () => _showChapterList(state),
            child: Text(
              '${state.currentChapter?.index ?? 0} / ${state.totalChapters}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: state.currentChapter?.index != state.totalChapters
                ? () => ref.read(readerProvider.notifier).nextChapter()
                : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  void _showChapterList(ReaderState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '目录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: state.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = state.chapters[index];
                    final isCurrent = chapter.index == state.currentChapter?.index;
                    
                    return ListTile(
                      leading: isCurrent
                          ? const Icon(Icons.play_arrow, color: AppTheme.primaryColor)
                          : Text('${chapter.index}'),
                      title: Text(
                        chapter.title,
                        style: TextStyle(
                          color: isCurrent ? AppTheme.primaryColor : null,
                          fontWeight: isCurrent ? FontWeight.bold : null,
                        ),
                      ),
                      trailing: chapter.isVip
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VIP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        ref.read(readerProvider.notifier)
                            .goToChapter(chapter.index);
                        Navigator.pop(context);
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
  
  void _showFontSettings(ReaderState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '字体大小',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.text_decrease),
                  onPressed: state.fontSize > 12
                      ? () => ref.read(readerProvider.notifier)
                          .setFontSize(state.fontSize - 2)
                      : null,
                ),
                Expanded(
                  child: Slider(
                    value: state.fontSize,
                    min: 12,
                    max: 32,
                    divisions: 10,
                    label: '${state.fontSize.toInt()}',
                    onChanged: (value) {
                      ref.read(readerProvider.notifier).setFontSize(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.text_increase),
                  onPressed: state.fontSize < 32
                      ? () => ref.read(readerProvider.notifier)
                          .setFontSize(state.fontSize + 2)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '行间距',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('紧凑'),
                Expanded(
                  child: Slider(
                    value: state.lineHeight,
                    min: 1.2,
                    max: 2.0,
                    divisions: 4,
                    label: state.lineHeight.toStringAsFixed(1),
                    onChanged: (value) {
                      ref.read(readerProvider.notifier).setLineHeight(value);
                    },
                  ),
                ),
                const Text('宽松'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showBrightnessSettings(ReaderState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '屏幕亮度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${(state.brightness * 100).toInt()}%'),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: state.brightness,
              onChanged: (value) {
                ref.read(readerProvider.notifier).setBrightness(value);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '跟随系统',
              style: TextStyle(fontSize: 16),
            ),
            Switch(
              value: state.autoBrightness,
              onChanged: (value) {
                ref.read(readerProvider.notifier).setAutoBrightness(value);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showThemeSettings(ReaderState state) {
    final themes = [
      {'name': '羊皮纸', 'bg': const Color(0xFFFFF8E1), 'text': const Color(0xFF5D4037)},
      {'name': '护眼绿', 'bg': const Color(0xFFE8F5E9), 'text': const Color(0xFF2E7D32)},
      {'name': '淡蓝', 'bg': const Color(0xFFE3F2FD), 'text': const Color(0xFF1565C0)},
      {'name': '粉色', 'bg': const Color(0xFFFCE4EC), 'text': const Color(0xFFC2185B)},
      {'name': '纯白', 'bg': const Color(0xFFFFFFFF), 'text': const Color(0xFF212121)},
      {'name': '夜间', 'bg': const Color(0xFF263238), 'text': const Color(0xFFBDBDBD)},
    ];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '阅读主题',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: themes.map((theme) {
                final isSelected = state.readerTheme.backgroundColor == theme['bg'];
                return GestureDetector(
                  onTap: () {
                    ref.read(readerProvider.notifier).setReaderTheme(
                      theme['bg'] as Color,
                      theme['text'] as Color,
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme['bg'] as Color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Aa',
                          style: TextStyle(
                            color: theme['text'] as Color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme['name'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme['text'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showReaderSettings(ReaderState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.auto_stories),
              title: const Text('翻页模式'),
              trailing: Text(
                state.pageMode == 'scroll' ? '滑动' : '覆盖',
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                ref.read(readerProvider.notifier).togglePageMode();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('翻译全文'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showAITranslate(state);
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('AI摘要'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showAISummary(state);
              },
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: const Text('听书'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showBookmarkDialog(ReaderState state) {
    final noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加书签'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${state.currentChapter?.index}章 ${state.currentChapter?.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: '添加笔记（可选）',
              ),
              maxLines: 3,
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
              ref.read(readerProvider.notifier).addBookmark(
                noteController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('书签已添加')),
              );
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
  
  void _showMoreOptions(ReaderState state) {
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
              leading: const Icon(Icons.bug_report),
              title: const Text('反馈错误'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('下载本章'),
              onTap: () {
                ref.read(readerProvider.notifier).downloadChapter();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('开始下载...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fullscreen),
              title: const Text('全屏阅读'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isControlsVisible = false;
                  _is immersiveMode = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAITranslate(ReaderState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI翻译'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在翻译，请稍候...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
  
  void _showAISummary(ReaderState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI摘要'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '本章主要内容：\n\n'
              '1. 主角面临重大抉择\n'
              '2. 揭示了新的世界观设定\n'
              '3. 为后续剧情埋下伏笔\n\n'
              '关键人物：主角、反派NPC\n'
              '关键地点：废弃矿洞',
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  String _generateMockContent() {
    return '''
　　林逸缓缓睁开眼睛，入目是一片陌生的天花板。

　　"这是哪里？"他揉了揉太阳穴，脑海中一片混乱。

　　记忆中最后的画面，是那场突如其来的车祸，然后便是无尽的黑暗。

　　"少爷，您终于醒了！"一个清脆的声音从旁边传来。

　　林逸转过头，看到一个穿着女仆装的少女正站在床边，眼眶微红，似乎刚刚哭过。

　　"你是谁？"林逸下意识地问道。

　　"少爷，您不记得我了吗？"少女的脸上闪过一丝慌乱，"我是小翠啊，从小伺候您的小翠！"

　　林逸张了张嘴，想要说些什么，却发现脑海中一片空白。

　　他只记得自己的名字叫林逸，其他的一切都是空白。

　　"少爷，您先别急。"小翠递过来一杯温水，"大夫说了，您这次受了很重的伤，可能会有些后遗症，慢慢就会想起来的。"

　　林逸接过水杯，脑海中却在快速思考着。

　　这具身体的原主人，到底是什么身份？那个女仆口中的"少爷"，又意味着什么？

　　看来，自己穿越了。

　　而且还穿越到了一个大家族之中。

　　林逸深吸一口气，决定先接受这个事实，然后慢慢弄清楚自己的处境。

　　"小翠，"他开口道，"能跟我说说，我们林家现在是什么情况吗？"

　　小翠闻言，脸色微微一变，似乎有些为难。

　　"少爷，您真的不记得了吗？"

　　"嗯。"林逸点点头，"你从头跟我说说吧。"

　　小翠犹豫了一下，最终还是开口了。

　　"我们林家是青阳镇上的大户人家，老爷，也就是您的父亲，是林家的家主......"

　　随着小翠的讲述，林逸逐渐了解了这个世界和自己这具身体的情况。

　　这是一个修炼者的世界，而林家，则是青阳镇上的一个修炼世家。

　　只可惜，这具身体的原主人资质平庸，在修炼上并没有太大的成就，一直被家族中其他人看不起。

　　三天前，原主人被人陷害，重伤垂死，这才让自己有了穿越过来的机会。

　　"陷害？"林逸敏锐地抓住了这个关键词，"是谁陷害我的？"

　　小翠低下头，声音变得更小了。

　　"是......是二少爷他们......"
''';
  }
}
