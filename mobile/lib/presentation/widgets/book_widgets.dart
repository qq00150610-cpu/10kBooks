import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_theme.dart';
import '../../data/models/models.dart';
import 'common_widgets.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool showAuthor;
  final double width;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.showAuthor = true,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              coverUrl: book.cover,
              width: width,
              height: height,
              isVip: book.isVip,
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showAuthor)
              Text(
                book.author,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

class BookListTile extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showTags;

  const BookListTile({
    super.key,
    required this.book,
    this.onTap,
    this.trailing,
    this.showTags = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: BookCover(
        coverUrl: book.cover,
        width: 60,
        height: 80,
        isVip: book.isVip,
      ),
      title: Text(
        book.title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            book.author,
            style: AppTextStyles.caption.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              RatingStars(rating: book.rating, size: 12),
              const SizedBox(width: 8),
              Text(
                book.wordCountFormatted,
                style: AppTextStyles.caption.copyWith(color: AppColors.grey400),
              ),
              const SizedBox(width: 8),
              Text(
                book.statusText,
                style: AppTextStyles.caption.copyWith(
                  color: book.status == BookStatus.completed
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          if (showTags && book.tags.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: book.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 10, color: AppColors.grey600),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      trailing: trailing,
    );
  }
}

class BookGridItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final double width;

  const BookGridItem({
    super.key,
    required this.book,
    this.onTap,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                BookCover(
                  coverUrl: book.cover,
                  width: width,
                  height: width * 1.4,
                  isVip: book.isVip,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      book.wordCountFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              style: AppTextStyles.caption.copyWith(color: AppColors.grey500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class BookshelfItem extends StatelessWidget {
  final Book book;
  final double progress;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const BookshelfItem({
    super.key,
    required this.book,
    this.progress = 0,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdAll,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : null,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                BookCover(
                  coverUrl: book.cover,
                  width: 80,
                  height: 110,
                  isVip: book.isVip,
                ),
                if (progress > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ProgressBar(
                      progress: progress,
                      height: 3,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (book.lastChapterTitle != null)
              Text(
                book.lastChapterTitle!,
                style: AppTextStyles.overline.copyWith(color: AppColors.grey400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

class HotRankItem extends StatelessWidget {
  final Book book;
  final int rank;
  final VoidCallback? onTap;

  const HotRankItem({
    super.key,
    required this.book,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : AppColors.grey600,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            BookCover(
              coverUrl: book.cover,
              width: 45,
              height: 60,
              isVip: book.isVip,
              borderRadius: AppRadius.xsAll,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: AppTextStyles.caption.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 14, color: AppColors.tagHot),
                      const SizedBox(width: 4),
                      CountText(
                        count: book.viewCount,
                        style: AppTextStyles.caption.copyWith(color: AppColors.grey400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFF6B6B);
      case 2:
        return const Color(0xFFFFE66D);
      case 3:
        return const Color(0xFF4ECDC4);
      default:
        return AppColors.grey100;
    }
  }
}

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.icon.isNotEmpty) ...[
              Icon(
                Icons.category,
                size: 16,
                color: isSelected ? Colors.white : AppColors.grey600,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.grey700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  final bool isRead;
  final bool isCurrent;
  final VoidCallback? onTap;

  const ChapterListItem({
    super.key,
    required this.chapter,
    this.isRead = false,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: isCurrent ? AppColors.primary.withOpacity(0.1) : null,
      leading: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isRead ? AppColors.grey200 : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${chapter.number}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isRead ? AppColors.grey500 : AppColors.primary,
          ),
        ),
      ),
      title: Text(
        chapter.title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isRead ? AppColors.grey500 : null,
          fontWeight: isCurrent ? FontWeight.w600 : null,
        ),
      ),
      subtitle: Text(
        '${chapter.wordCount}字',
        style: AppTextStyles.caption.copyWith(color: AppColors.grey400),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chapter.isVip)
            Container(
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (chapter.isLock)
            const Icon(Icons.lock, size: 16, color: AppColors.grey400),
        ],
      ),
    );
  }
}
