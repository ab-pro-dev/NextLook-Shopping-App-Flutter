import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton/skeleton_circle.dart';
import '../../../../core/widgets/skeleton/skeleton_text.dart';

/// Skeleton placeholder for a single notification item row.
class NotificationRowSkeleton extends StatelessWidget {
  const NotificationRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonCircle(diameter: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText.heading(width: 130),
                const SizedBox(height: 6),
                SkeletonText.body(width: double.infinity),
                const SizedBox(height: 4),
                SkeletonText.caption(width: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List of NotificationRowSkeleton items.
class NotificationsListSkeleton extends StatelessWidget {
  final int itemCount;

  const NotificationsListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('notifications_list_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const NotificationRowSkeleton(),
    );
  }
}
