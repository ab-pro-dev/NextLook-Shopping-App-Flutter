import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../../core/widgets/skeleton/skeleton_circle.dart';
import '../../../../core/widgets/skeleton/skeleton_text.dart';

/// Skeleton placeholder for Home Screen Categories Row.
class CategoriesRowSkeleton extends StatelessWidget {
  const CategoriesRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.builder(
        key: const Key('categories_skeleton'),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 18),
            child: Column(
              children: [
                const SkeletonCircle(diameter: 58),
                const SizedBox(height: 6),
                SkeletonText.caption(width: 44),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton placeholder for Home Screen Banner Slider.
class BannerSkeleton extends StatelessWidget {
  const BannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SkeletonBox(
        height: 190,
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}

/// Skeleton placeholder for a single Product Card matching real ProductCardWidget dimensions.
class ProductCardSkeleton extends StatelessWidget {
  final double width;

  const ProductCardSkeleton({
    super.key,
    this.width = 165.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          SkeletonBox(
            height: 145,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Line
                SkeletonText.caption(width: 60),
                const SizedBox(height: 6),
                // Title Line
                SkeletonText.body(width: 120),
                const SizedBox(height: 4),
                SkeletonText.body(width: 80),
                const SizedBox(height: 10),
                // Price & Heart Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText(width: 55, height: 16),
                    const SkeletonCircle(diameter: 22),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for a horizontal list of Product Cards.
class ProductHorizontalListSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductHorizontalListSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 265,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const ProductCardSkeleton();
        },
      ),
    );
  }
}

/// Skeleton placeholder for Home Screen product sections (Flash Sale, New Arrivals, etc.).
class HomeSectionsSkeleton extends StatelessWidget {
  const HomeSectionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('home_sections_skeleton'),
      children: List.generate(3, (index) {
        return Column(
          children: [
            // Section Header Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonText.heading(width: 120),
                  SkeletonText.caption(width: 50),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const ProductHorizontalListSkeleton(itemCount: 4),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }
}
