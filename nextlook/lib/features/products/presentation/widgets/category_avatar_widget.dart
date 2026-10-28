import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/category_model.dart';

/// Circular avatar widget displaying a real photo for the category
/// (Men, Women, Kids face portraits, Shoes & Accessories items) with
/// smooth icon fallback.
class CategoryAvatarWidget extends StatelessWidget {
  final Category category;
  final double size;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const CategoryAvatarWidget({
    super.key,
    required this.category,
    this.size = 58,
    this.border,
    this.boxShadow,
  });

  static IconData getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'male':
      case 'men':
        return Icons.person_rounded;
      case 'female':
      case 'women':
        return Icons.face_3_rounded;
      case 'child':
      case 'kids':
        return Icons.child_care_rounded;
      case 'shoe':
      case 'shoes':
        return Icons.roller_skating_rounded;
      case 'accessories':
        return Icons.watch_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        getCategoryIcon(category.iconName),
        color: const Color(0xFF1E1E2D),
        size: size * 0.44,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = category.assetImagePath;
    final networkUrl = category.imageUrl;

    Widget imageContent;

    if (networkUrl != null && networkUrl.isNotEmpty) {
      imageContent = CachedNetworkImage(
        imageUrl: networkUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFEEF1F6),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          if (assetPath != null && assetPath.isNotEmpty) {
            return Image.asset(
              assetPath,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallbackIcon(),
            );
          }
          return _buildFallbackIcon();
        },
      );
    } else if (assetPath != null && assetPath.isNotEmpty) {
      imageContent = Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    } else {
      imageContent = _buildFallbackIcon();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F6),
        shape: BoxShape.circle,
        border: border ?? Border.all(color: Colors.white, width: 2),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
      ),
      child: ClipOval(
        child: imageContent,
      ),
    );
  }
}
