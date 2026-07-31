import 'package:flutter/material.dart';
import 'skeleton_box.dart';
import 'skeleton_text.dart';

/// Skeleton placeholder for saved address cards (Checkout & Addresses screen).
class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonText.heading(width: 130),
              SkeletonBox(width: 54, height: 20, borderRadius: BorderRadius.circular(10)),
            ],
          ),
          const SizedBox(height: 8),
          SkeletonText.caption(width: 100),
          const SizedBox(height: 10),
          SkeletonText.body(width: double.infinity),
          const SizedBox(height: 6),
          SkeletonText.body(width: 180),
        ],
      ),
    );
  }
}

/// List of address card skeletons.
class AddressListSkeleton extends StatelessWidget {
  final int itemCount;

  const AddressListSkeleton({
    super.key,
    this.itemCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('address_list_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const AddressCardSkeleton(),
    );
  }
}
