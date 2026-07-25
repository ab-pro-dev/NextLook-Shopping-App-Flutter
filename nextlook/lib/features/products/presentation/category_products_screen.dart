import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/product_card.dart';
import '../application/product_providers.dart';
import '../data/product_query_params.dart';
import 'filters_screen.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final String categorySlug;

  const CategoryProductsScreen({
    super.key,
    required this.categorySlug,
  });

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  final Map<String, String> _sortLabels = const {
    'newest': 'Newest',
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'rating': 'Rating',
    'popularity': 'Popularity',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentCategory = ref.read(productListNotifierProvider).valueOrNull?.params.category;
      if (currentCategory != widget.categorySlug) {
        ref.read(productListNotifierProvider.notifier).setCategory(widget.categorySlug);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCategoryTitle(String slug) {
    if (slug.isEmpty) return 'Products';
    switch (slug.toLowerCase()) {
      case 'men':
        return 'Men';
      case 'women':
        return 'Women';
      case 'kids':
        return 'Kids';
      case 'shoes':
        return 'Shoes';
      case 'accessories':
        return 'Accessories';
      default:
        return slug[0].toUpperCase() + slug.substring(1);
    }
  }

  void _openSortBottomSheet(String currentSort) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: Text(
                  'Sort By',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1E2D),
                  ),
                ),
              ),
              const Divider(height: 16),
              ..._sortLabels.entries.map((entry) {
                final isSelected = entry.key == currentSort;
                return ListTile(
                  title: Text(
                    entry.value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF1E1E2D),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6C63FF))
                      : null,
                  onTap: () {
                    ref.read(productListNotifierProvider.notifier).setSort(entry.key);
                    context.pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openFiltersSheet(ProductQueryParams currentParams) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40,
          ),
          child: FiltersScreen(currentParams: currentParams),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    const backgroundColor = Color(0xFFF8F9FC);

    final productListAsync = ref.watch(productListNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkNavy),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _formatCategoryTitle(widget.categorySlug),
          style: GoogleFonts.poppins(
            color: darkNavy,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('filter_icon_button'),
            icon: const Icon(Icons.tune_rounded, color: darkNavy),
            onPressed: () {
              final currentParams = productListAsync.valueOrNull?.params ??
                  ProductQueryParams(category: widget.categorySlug);
              _openFiltersSheet(currentParams);
            },
          ),
        ],
      ),
      body: productListAsync.when(
        data: (state) {
          final currentSortLabel = _sortLabels[state.params.sort] ?? 'Newest';

          return Column(
            children: [
              // Sort Option Selector Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.total} Products',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      key: const Key('sort_selector_button'),
                      onTap: () => _openSortBottomSheet(state.params.sort),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Sort: $currentSortLabel',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: darkNavy,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: darkNavy),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Product Grid Body or Empty State
              Expanded(
                child: state.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No products found',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkNavy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try clearing your active filters',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(productListNotifierProvider.notifier).fetchProducts(
                                      ProductQueryParams(category: widget.categorySlug),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Clear filters',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.products.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 16,
                              ),
                              itemBuilder: (context, index) {
                                return ProductCardWidget(
                                  product: state.products[index],
                                  width: double.infinity,
                                );
                              },
                            ),
                            if (state.isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryPurple,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primaryPurple,
          ),
        ),
        error: (err, stack) => Center(
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
                'Failed to load products',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(productListNotifierProvider.notifier).setCategory(widget.categorySlug);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
