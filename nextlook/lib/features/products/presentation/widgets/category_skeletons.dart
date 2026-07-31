import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../../core/widgets/skeleton/skeleton_circle.dart';
import '../../../../core/widgets/skeleton/skeleton_text.dart';

/// Single category row skeleton placeholder matching real category row layout.
class CategoryRowSkeleton extends StatelessWidget {
  const CategoryRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          // Circular Avatar Skeleton
          const SkeletonCircle(diameter: 54),
          const SizedBox(width: 16),

          // Two text lines (name + count)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText.heading(width: 110),
                const SizedBox(height: 6),
                SkeletonText.caption(width: 60),
              ],
            ),
          ),

          // Trailing Chevron Skeleton Box
          SkeletonBox(
            width: 16,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

/// List of ~5 category row skeletons for the Categories screen.
class CategoriesListSkeleton extends StatelessWidget {
  final int itemCount;

  const CategoriesListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('categories_list_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const CategoryRowSkeleton(),
    );
  }
}
