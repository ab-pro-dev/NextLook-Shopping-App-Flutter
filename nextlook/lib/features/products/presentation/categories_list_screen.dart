import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../application/product_providers.dart';
import '../data/category_model.dart';
import 'widgets/category_skeletons.dart';

/// Categories List Screen matching The_App_UI.png reference spec
class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  IconData _getCategoryIcon(String iconName) {
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

  List<Category> _sortCategories(List<Category> categories) {
    const fixedOrder = ['men', 'women', 'kids', 'shoes', 'accessories'];
    final sorted = List<Category>.from(categories);
    sorted.sort((a, b) {
      final indexA = fixedOrder.indexOf(a.slug.toLowerCase());
      final indexB = fixedOrder.indexOf(b.slug.toLowerCase());
      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    const backgroundColor = Color(0xFFF8F9FC);

    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header with Title & Search Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    key: const Key('categories_search_icon'),
                    icon: const Icon(Icons.search_rounded, color: darkNavy, size: 24),
                    onPressed: () => context.push('/search'),
                  ),
                ],
              ),
            ),

            // 2. Categories List Body
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  final sortedList = _sortCategories(categories);
                  return ListView.separated(
                    key: const Key('categories_list_view'),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: sortedList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cat = sortedList[index];
                      // NOTE: Circular avatar category photo placeholders. Flagged for real photo assets.
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            key: Key('category_list_item_${cat.slug}'),
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/categories/${cat.slug}/products'),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  // Circular avatar icon
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF1F6),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getCategoryIcon(cat.iconName),
                                        color: darkNavy,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Category name & item count
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: darkNavy,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${cat.productCount} items',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow indicator
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey[400],
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const CategoriesListSkeleton(),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load categories',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkNavy,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(categoriesProvider),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
