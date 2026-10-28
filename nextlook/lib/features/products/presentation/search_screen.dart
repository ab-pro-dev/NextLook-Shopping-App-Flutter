import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/product_card.dart';
import '../application/product_providers.dart';
import '../data/product_query_params.dart';
import 'filters_screen.dart';
import 'widgets/product_grid_skeleton.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final bool isFlashSale;
  final bool isNewArrival;
  final bool isTrending;
  final bool isBestSeller;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.isFlashSale = false,
    this.isNewArrival = false,
    this.isTrending = false,
    this.isBestSeller = false,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  final Map<String, String> _sortLabels = const {
    'newest': 'Newest',
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'rating': 'Rating',
    'popularity': 'Popularity',
  };

  final List<String> _suggestedKeywords = const [
    'Jacket',
    'Watch',
    'Sunglasses',
    'Leather',
    'Shoes',
    'Hoodie',
    'Bag',
  ];

  bool get _isSectionView =>
      widget.isFlashSale || widget.isNewArrival || widget.isTrending || widget.isBestSeller;

  String get _sectionTitle {
    if (widget.isFlashSale) return 'Flash Sale';
    if (widget.isNewArrival) return 'New Arrivals';
    if (widget.isTrending) return 'Trending Products';
    if (widget.isBestSeller) return 'Best Sellers';
    return 'Search Products';
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentParams = ref.read(searchProductListNotifierProvider).valueOrNull?.params;
      final expectedParams = ProductQueryParams(
        search: widget.initialQuery,
        isFlashSale: widget.isFlashSale ? true : null,
        isNewArrival: widget.isNewArrival ? true : null,
        isTrending: widget.isTrending ? true : null,
        isBestSeller: widget.isBestSeller ? true : null,
      );

      final isSame = currentParams != null &&
          currentParams.search == expectedParams.search &&
          currentParams.isFlashSale == expectedParams.isFlashSale &&
          currentParams.isNewArrival == expectedParams.isNewArrival &&
          currentParams.isTrending == expectedParams.isTrending &&
          currentParams.isBestSeller == expectedParams.isBestSeller;

      if (!isSame) {
        ref.read(searchProductListNotifierProvider.notifier).fetchProducts(expectedParams);
      }

      if (!_isSectionView && (widget.initialQuery == null || widget.initialQuery!.isEmpty)) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchProductListNotifierProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _executeSearch(query);
    });
  }

  void _executeSearch(String query) {
    final currentParams = ref.read(searchProductListNotifierProvider).valueOrNull?.params ??
        ProductQueryParams(
          isFlashSale: widget.isFlashSale ? true : null,
          isNewArrival: widget.isNewArrival ? true : null,
          isTrending: widget.isTrending ? true : null,
          isBestSeller: widget.isBestSeller ? true : null,
        );

    final trimmed = query.trim();
    final updated = trimmed.isEmpty
        ? currentParams.copyWith(clearSearch: true, page: 1)
        : currentParams.copyWith(search: trimmed, page: 1);

    ref.read(searchProductListNotifierProvider.notifier).updateQueryParams(updated);
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
                    final currentParams = ref.read(searchProductListNotifierProvider).valueOrNull?.params;
                    if (currentParams != null) {
                      ref
                          .read(searchProductListNotifierProvider.notifier)
                          .updateQueryParams(currentParams.copyWith(sort: entry.key, page: 1));
                    }
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
          child: FiltersScreen(
            currentParams: currentParams,
            onApply: (updated) {
              ref.read(searchProductListNotifierProvider.notifier).updateQueryParams(updated);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    const backgroundColor = Color(0xFFF8F9FC);

    final productListAsync = ref.watch(searchProductListNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkNavy),
          onPressed: () => context.pop(),
        ),
        title: _isSectionView
            ? Text(
                _sectionTitle,
                style: GoogleFonts.poppins(
                  color: darkNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            : _buildSearchBarInput(darkNavy, primaryPurple),
        centerTitle: _isSectionView,
        actions: [
          IconButton(
            key: const Key('search_filter_icon_button'),
            icon: const Icon(Icons.tune_rounded, color: darkNavy),
            onPressed: () {
              final currentParams = productListAsync.valueOrNull?.params ??
                  ProductQueryParams(
                    isFlashSale: widget.isFlashSale ? true : null,
                    isNewArrival: widget.isNewArrival ? true : null,
                    isTrending: widget.isTrending ? true : null,
                    isBestSeller: widget.isBestSeller ? true : null,
                  );
              _openFiltersSheet(currentParams);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // If section view, show search bar below title
          if (_isSectionView)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: _buildSearchBarInput(darkNavy, primaryPurple),
            ),

          // Main product list / suggestions / state
          Expanded(
            child: productListAsync.when(
              data: (state) {
                final currentSortLabel = _sortLabels[state.params.sort] ?? 'Newest';

                return RefreshIndicator(
                  color: primaryPurple,
                  onRefresh: () async {
                    await ref
                        .read(searchProductListNotifierProvider.notifier)
                        .fetchProducts(state.params.copyWith(page: 1));
                  },
                  child: Column(
                    children: [
                      // Sort & Count Row
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
                              key: const Key('search_sort_selector_button'),
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
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: darkNavy,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Grid or Empty State
                      Expanded(
                        child: state.products.isEmpty
                            ? _buildEmptyState(state, primaryPurple, darkNavy)
                            : SingleChildScrollView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                                child: Column(
                                  children: [
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: state.products.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        padding: EdgeInsets.only(top: 16.0),
                                        child: ProductGridSkeleton(
                                          itemCount: 2,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const ProductGridSkeleton(itemCount: 6),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
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
                          _executeSearch(_searchController.text);
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarInput(Color darkNavy, Color primaryPurple) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        key: const Key('search_screen_input'),
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        onSubmitted: _executeSearch,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: darkNavy,
        ),
        decoration: InputDecoration(
          hintText: _isSectionView ? 'Search in $_sectionTitle...' : 'Search products, brands...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _executeSearch('');
                },
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ProductListState state, Color primaryPurple, Color darkNavy) {
    final query = _searchController.text.trim();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty ? 'No products found for "$query"' : 'No products found',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            query.isNotEmpty
                ? 'Check your spelling or try more general keywords'
                : 'Try adjusting your filters or search keywords',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (query.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _executeSearch('');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Clear Search',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 32),
          Text(
            'Popular Searches',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestedKeywords.map((kw) {
              return ActionChip(
                label: Text(
                  kw,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: darkNavy,
                  ),
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                onPressed: () {
                  _searchController.text = kw;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: kw.length),
                  );
                  _executeSearch(kw);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
