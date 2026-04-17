import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_theme.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildShimmer(context),
      errorWidget: (context, url, error) => errorWidget ?? _buildError(isDark),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.grey800 : AppColors.grey200,
      highlightColor: isDark ? AppColors.grey700 : AppColors.grey100,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? AppColors.grey800 : AppColors.grey100,
      child: Icon(
        Icons.image_outlined,
        color: AppColors.grey400,
        size: (width ?? 50) * 0.4,
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  final String? coverUrl;
  final double width;
  final double height;
  final bool isVip;
  final BorderRadius? borderRadius;

  const BookCover({
    super.key,
    this.coverUrl,
    this.width = 100,
    this.height = 140,
    this.isVip = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.smAll;
    
    return Stack(
      children: [
        AppNetworkImage(
          imageUrl: coverUrl,
          width: width,
          height: height,
          borderRadius: radius,
        ),
        if (isVip)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
          ),
      ],
    );
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.secondary;
    final inactive = inactiveColor ?? AppColors.grey300;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: active);
        } else if (index < rating) {
          return Icon(Icons.star_half, size: size, color: active);
        } else {
          return Icon(Icons.star_border, size: size, color: inactive);
        }
      }),
    );
  }
}

class TagBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;
  final EdgeInsets padding;

  const TagBadge({
    super.key,
    required this.text,
    this.color,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.primary;
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: bgColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: bgColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final bool isVip;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.size = 40,
    this.isVip = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isVip
            ? Border.all(color: AppColors.vipGold, width: 2)
            : null,
      ),
      child: ClipOval(
        child: AppNetworkImage(
          imageUrl: avatarUrl,
          width: size,
          height: size,
          errorWidget: Container(
            color: AppColors.grey200,
            child: Icon(
              Icons.person,
              size: size * 0.6,
              color: AppColors.grey400,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: controller != null
          ? ListView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [child],
            )
          : child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.h5,
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Row(
                children: [
                  Text(
                    actionText!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 4,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.grey200;
    final fgColor = foregroundColor ?? AppColors.primary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: fgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

class CountText extends StatelessWidget {
  final int count;
  final String? suffix;
  final TextStyle? style;

  const CountText({
    super.key,
    required this.count,
    this.suffix,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    if (count >= 100000000) {
      text = '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      text = '${(count / 10000).toStringAsFixed(1)}万';
    } else {
      text = count.toString();
    }
    
    if (suffix != null) {
      text += suffix!;
    }

    return Text(
      text,
      style: style,
    );
  }
}
