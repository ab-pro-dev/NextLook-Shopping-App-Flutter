import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../../core/widgets/skeleton/skeleton_circle.dart';
import '../../../../core/widgets/skeleton/skeleton_text.dart';
import '../../../../features/home/presentation/widgets/home_skeletons.dart';

/// Skeleton placeholder matching Product Detail Screen structure.
class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('product_detail_skeleton'),
      backgroundColor: const Color(0xFFF8F9FC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Carousel Placeholder Box
            const SkeletonBox(
              height: 340,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Brand & Title Lines
                  SkeletonText.caption(width: 70),
                  const SizedBox(height: 8),
                  SkeletonText.heading(width: 220),
                  const SizedBox(height: 12),

                  // 3. Price Line
                  SkeletonText(width: 90, height: 22),
                  const SizedBox(height: 24),

                  // 4. Color Selector Skeleton
                  SkeletonText.body(width: 60),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      4,
                      (index) => const Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: SkeletonCircle(diameter: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Size Selector Skeleton
                  SkeletonText.body(width: 50),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      4,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SkeletonBox(
                          width: 48,
                          height: 44,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Description Area Skeleton
                  SkeletonText.heading(width: 100),
                  const SizedBox(height: 10),
                  SkeletonText.body(width: double.infinity),
                  const SizedBox(height: 6),
                  SkeletonText.body(width: double.infinity),
                  const SizedBox(height: 6),
                  SkeletonText.body(width: 180),
                  const SizedBox(height: 28),

                  // 7. Similar Products Section Skeleton
                  SkeletonText.heading(width: 140),
                  const SizedBox(height: 14),
                  const ProductHorizontalListSkeleton(itemCount: 3),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
