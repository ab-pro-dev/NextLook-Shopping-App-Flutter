import 'package:flutter/material.dart';
import 'shimmer_wrapper.dart';

/// A circular placeholder widget for avatar icons and round buttons.
class SkeletonCircle extends StatelessWidget {
  final double diameter;

  const SkeletonCircle({
    super.key,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          color: Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
