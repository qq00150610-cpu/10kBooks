import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  
  const ShimmerBox({
    Key? key,
    this.width,
    this.height,
    this.borderRadius = 8,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  
  const ShimmerText({
    Key? key,
    this.width = 100,
    this.height = 16,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ShimmerBox(width: width, height: height, borderRadius: 4);
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;
  
  const ShimmerList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const ShimmerBox(width: 60, height: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerText(width: double.infinity, height: 16),
                    const SizedBox(height: 8),
                    ShimmerText(width: 120, height: 12),
                    const SizedBox(height: 8),
                    ShimmerText(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double itemHeight;
  
  const ShimmerGrid({
    Key? key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
    this.itemHeight = 180,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              width: double.infinity,
              height: itemHeight - 30,
              borderRadius: 8,
            ),
            const SizedBox(height: 8),
            ShimmerText(width: double.infinity, height: 14),
            const SizedBox(height: 4),
            ShimmerText(width: 60, height: 12),
          ],
        );
      },
    );
  }
}

// 骨架屏占位组件
class BookCardShimmer extends StatelessWidget {
  final bool showDescription;
  
  const BookCardShimmer({
    Key? key,
    this.showDescription = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const ShimmerBox(width: 80, height: 110),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerText(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  ShimmerText(width: 80, height: 12),
                  const SizedBox(height: 8),
                  if (showDescription) ...[
                    ShimmerText(width: double.infinity, height: 12),
                    const SizedBox(height: 4),
                    ShimmerText(width: 150, height: 12),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ShimmerBox(width: 40, height: 20, borderRadius: 4),
                      const SizedBox(width: 8),
                      ShimmerBox(width: 40, height: 20, borderRadius: 4),
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
}
