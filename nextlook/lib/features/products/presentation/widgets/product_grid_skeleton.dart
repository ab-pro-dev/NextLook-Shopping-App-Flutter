import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/home_skeletons.dart';

/// 2-Column Product Grid Skeleton for Category Products and Search screens.
class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const ProductGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.fromLTRB(20, 10, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const Key('product_grid_skeleton'),
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return const ProductCardSkeleton(width: double.infinity);
      },
    );
  }
}
