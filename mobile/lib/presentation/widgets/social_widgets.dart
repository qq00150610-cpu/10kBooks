import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_theme.dart';
import '../../data/models/models.dart';
import 'common_widgets.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Row(
              children: [
                UserAvatar(
                  avatarUrl: post.author.avatar,
                  size: 40,
                  isVip: post.author.isVip,
                  onTap: () {
                    // 跳转到用户主页
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.author.nickname,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (post.author.isVip) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.vipGold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VIP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        post.timeAgo,
                        style:
                            AppTextStyles.caption.copyWith(color: AppColors.grey400),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                  color: AppColors.grey400,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 内容
            Text(
              post.content,
              style: AppTextStyles.bodyMedium,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
            // 图片
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImageGrid(post.images),
            ],
            // 推荐书籍
            if (post.book != null) ...[
              const SizedBox(height: 12),
              _buildBookReference(post.book!),
            ],
            const SizedBox(height: 12),
            // 操作按钮
            Row(
              children: [
                _buildActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: CountText(count: post.likeCount),
                  color: post.isLiked ? AppColors.error : AppColors.grey500,
                  onTap: onLike,
                ),
                const SizedBox(width: 32),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: CountText(count: post.commentCount),
                  color: AppColors.grey500,
                  onTap: onComment,
                ),
                const SizedBox(width: 32),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: CountText(count: post.shareCount),
                  color: AppColors.grey500,
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> images) {
    final count = images.length;
    if (count == 1) {
      return ClipRRect(
        borderRadius: AppRadius.smAll,
        child: AppNetworkImage(
          imageUrl: images[0],
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (count == 2) {
      return Row(
        children: images.map((url) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: url == images[0] ? 0 : 4,
                right: url == images[1] ? 0 : 4,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.smAll,
                child: AppNetworkImage(
                  imageUrl: url,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: count > 9 ? 9 : count,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: AppRadius.smAll,
            child: Stack(
              children: [
                AppNetworkImage(
                  imageUrl: images[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (index == 8 && count > 9)
                  Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: Text(
                      '+${count - 9}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildBookReference(Book book) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        children: [
          BookCover(
            coverUrl: book.cover,
            width: 40,
            height: 56,
            isVip: book.isVip,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  book.author,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.grey400,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Widget label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            DefaultTextStyle(
              style: AppTextStyles.caption.copyWith(color: color),
              child: label,
            ),
          ],
        ),
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onUserTap;

  const CommentItem({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            avatarUrl: comment.author.avatar,
            size: 36,
            isVip: comment.author.isVip,
            onTap: onUserTap,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author.nickname,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (comment.author.isVip) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.vipGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      comment.timeAgo,
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.grey400),
                    ),
                  ],
                ),
                if (comment.replyTo != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: AppRadius.xsAll,
                    ),
                    child: Text(
                      '回复 @${comment.replyTo!.author.nickname}：${comment.replyTo!.content}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  comment.content,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked
                                ? AppColors.error
                                : AppColors.grey400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeCount}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onReply,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '回复',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // 子回复
                if (comment.replies.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Column(
                      children: comment.replies.take(2).map((reply) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserAvatar(
                                avatarUrl: reply.author.avatar,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${reply.author.nickname} ',
                                            style: AppTextStyles.caption.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (reply.replyTo != null)
                                            TextSpan(
                                              text: '回复 @${reply.replyTo!.author.nickname} ',
                                              style: AppTextStyles.caption.copyWith(
                                                color: AppColors.grey500,
                                              ),
                                            ),
                                          TextSpan(
                                            text: reply.content,
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      reply.timeAgo,
                                      style: AppTextStyles.overline.copyWith(
                                        color: AppColors.grey400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircleCard extends StatelessWidget {
  final Circle circle;
  final VoidCallback? onTap;

  const CircleCard({
    super.key,
    required this.circle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.mdAll,
          boxShadow: AppShadows.small,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(
                Icons.groups,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    circle.description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text(
                        '${circle.memberCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.article, size: 14, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text(
                        '${circle.postCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    circle.isJoined ? AppColors.grey200 : AppColors.primary,
                foregroundColor:
                    circle.isJoined ? AppColors.grey600 : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(circle.isJoined ? '已加入' : '加入'),
            ),
          ],
        ),
      ),
    );
  }
}
