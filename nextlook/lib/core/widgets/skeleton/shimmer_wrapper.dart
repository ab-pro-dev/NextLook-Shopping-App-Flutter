import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Wraps any widget in a Shimmer gradient sweep animation.
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final bool enabled;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE5E7EB),
    this.highlightColor = const Color(0xFFF3F4F6),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}
