import 'package:flutter/material.dart';
import 'shimmer_wrapper.dart';

/// A rounded bar widget simulating a line of text.
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  /// Preset for heading text
  factory SkeletonText.heading({double? width}) {
    return SkeletonText(
      width: width,
      height: 20,
      borderRadius: BorderRadius.circular(6),
    );
  }

  /// Preset for body text
  factory SkeletonText.body({double? width}) {
    return SkeletonText(
      width: width,
      height: 14,
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Preset for caption / small text
  factory SkeletonText.caption({double? width}) {
    return SkeletonText(
      width: width,
      height: 10,
      borderRadius: BorderRadius.circular(3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}
