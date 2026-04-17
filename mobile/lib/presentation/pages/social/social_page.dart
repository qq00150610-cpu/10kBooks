import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/social_widgets.dart';

class SocialPage extends ConsumerStatefulWidget {
  const SocialPage({super.key});

  @override
  ConsumerState<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends ConsumerState<SocialPage>
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
        title: const Text('社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '关注'),
            Tab(text: '圈子'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendTab(),
          _buildFollowingTab(),
          _buildCircleTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildRecommendTab() {
    final feedAsync = ref.watch(feedProvider);

    return feedAsync.when(
      data: (posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: posts[index],
            onTap: () => _navigateToPostDetail(posts[index]),
            onLike: () => _toggleLike(posts[index]),
            onComment: () => _showComments(posts[index]),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyState(
        icon: Icons.error_outline,
        title: '加载失败',
        subtitle: '请检查网络连接',
      ),
    );
  }

  Widget _buildFollowingTab() {
    // 关注的人的动态
    return const EmptyState(
      icon: Icons.people_outline,
      title: '暂无关注动态',
      subtitle: '关注更多书友，获取动态更新',
    );
  }

  Widget _buildCircleTab() {
    // 圈子列表
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCircleCard(
          Circle(
            id: '1',
            name: '玄幻小说圈',
            icon: 'fantasy',
            description: '一起探讨玄幻小说的魅力',
            memberCount: 12580,
            postCount: 3568,
            isJoined: true,
            createdAt: DateTime.now(),
          ),
        ),
        const SizedBox(height: 12),
        _buildCircleCard(
          Circle(
            id: '2',
            name: '都市小说圈',
            icon: 'urban',
            description: '都市生活，都市故事',
            memberCount: 8960,
            postCount: 2340,
            isJoined: false,
            createdAt: DateTime.now(),
          ),
        ),
        const SizedBox(height: 12),
        _buildCircleCard(
          Circle(
            id: '3',
            name: '科幻小说圈',
            icon: 'scifi',
            description: '探索科幻的无限可能',
            memberCount: 5620,
            postCount: 1890,
            isJoined: false,
            createdAt: DateTime.now(),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleCard(Circle circle) {
    return CircleCard(
      circle: circle,
      onTap: () {
        // 跳转到圈子详情
      },
    );
  }

  void _navigateToPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post: post),
      ),
    );
  }

  void _toggleLike(Post post) {
    // 切换点赞状态
  }

  void _showComments(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentListPage(post: post),
      ),
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostSheet(),
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态详情'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostCard(
              post: post,
              onLike: () {},
              onComment: () {},
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '评论 ${post.commentCount}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // 评论列表
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return CommentItem(
                  comment: Comment(
                    id: '$index',
                    author: User(
                      id: '$index',
                      nickname: '用户$index',
                      avatar: '',
                      stats: UserStats(
                        bookCount: 0,
                        followCount: 0,
                        followerCount: 0,
                        postCount: 0,
                        commentCount: 0,
                        likeCount: 0,
                      ),
                      createdAt: DateTime.now(),
                    ),
                    content: '这是一条评论内容 $index',
                    likeCount: 100,
                    isLiked: false,
                    createdAt: DateTime.now(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildCommentInput() {
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
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '写下你的评论...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text('发送'),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentListPage extends StatelessWidget {
  final Post post;

  const CommentListPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return CommentItem(
            comment: Comment(
              id: '$index',
              author: User(
                id: '$index',
                nickname: '用户$index',
                avatar: '',
                stats: UserStats(
                  bookCount: 0,
                  followCount: 0,
                  followerCount: 0,
                  postCount: 0,
                  commentCount: 0,
                  likeCount: 0,
                ),
                createdAt: DateTime.now(),
              ),
              content: '这是一条评论内容 $index',
              likeCount: 100,
              isLiked: false,
              createdAt: DateTime.now(),
            ),
          );
        },
      ),
    );
  }
}

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _contentController = TextEditingController();
  final List<String> _selectedImages = [];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const Text(
                  '发布动态',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _handlePublish,
                  child: const Text('发布'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: 10,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: '分享你的阅读心得...',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImages.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () {
                      // 选择图片
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam),
                    onPressed: () {
                      // 选择视频
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.book),
                    onPressed: () {
                      // 添加书籍
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () {
                      // 添加位置
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePublish() {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('发布成功')),
    );
  }
}
