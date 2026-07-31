import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../../core/widgets/skeleton/skeleton_circle.dart';
import '../../../../core/widgets/skeleton/skeleton_text.dart';

/// Skeleton placeholder for a single Order item card in the Orders list.
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonText.heading(width: 120),
              SkeletonBox(width: 70, height: 22, borderRadius: BorderRadius.circular(12)),
            ],
          ),
          const SizedBox(height: 10),

          // Date & Items count
          Row(
            children: [
              SkeletonText.caption(width: 90),
              const SizedBox(width: 12),
              SkeletonText.caption(width: 60),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          // Price Total & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonText(width: 80, height: 18),
              SkeletonBox(width: 90, height: 32, borderRadius: BorderRadius.circular(10)),
            ],
          ),
        ],
      ),
    );
  }
}

/// List of OrderCardSkeleton items for Orders List Screen.
class OrdersListSkeleton extends StatelessWidget {
  final int itemCount;

  const OrdersListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('orders_list_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => const OrderCardSkeleton(),
    );
  }
}

/// Skeleton placeholder for Order Tracking Screen timeline.
class OrderTrackingSkeleton extends StatelessWidget {
  const OrderTrackingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('order_tracking_skeleton'),
      backgroundColor: const Color(0xFFF8F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Box
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText.heading(width: 140),
                      SkeletonBox(width: 80, height: 22, borderRadius: BorderRadius.circular(12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SkeletonText.caption(width: 110),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline Section
            SkeletonText.heading(width: 130),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: List.generate(4, (index) {
                  final isLast = index == 3;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SkeletonCircle(diameter: 24),
                          if (!isLast)
                            SkeletonBox(
                              width: 2,
                              height: 36,
                              borderRadius: BorderRadius.zero,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonText.heading(width: 120),
                            const SizedBox(height: 4),
                            SkeletonText.caption(width: 90),
                            if (!isLast) const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
