import 'package:flutter/material.dart';
import 'skeleton_box.dart';
import 'skeleton_text.dart';

/// Reusable list row skeleton placeholder for Cart, Wishlist, and Review step order items.
class ProductListRowSkeleton extends StatelessWidget {
  const ProductListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Thumbnail Box
          SkeletonBox(
            width: 66,
            height: 66,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 14),

          // Product Details (Title, variant, price)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText.heading(width: 140),
                const SizedBox(height: 6),
                SkeletonText.caption(width: 80),
                const SizedBox(height: 8),
                SkeletonText(width: 60, height: 16),
              ],
            ),
          ),

          // Trailing Action Skeleton Box
          SkeletonBox(
            width: 28,
            height: 28,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

/// List of product row skeletons for Cart and Wishlist screens.
class ProductListRowsSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductListRowsSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('product_list_rows_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const ProductListRowSkeleton(),
    );
  }
}
