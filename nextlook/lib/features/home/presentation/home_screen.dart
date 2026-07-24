import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/product_card.dart';
import '../../products/application/product_providers.dart';
import '../../products/data/category_model.dart';
import '../../products/data/product_card_model.dart';

/// Real Home Screen matching StyleHub design reference with search bar,
/// banner carousel, categories row, and 4 product section lists.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerController = PageController();
  int _activeBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_activeBannerIndex + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'male':
        return Icons.male_rounded;
      case 'female':
        return Icons.female_rounded;
      case 'child':
      case 'kids':
        return Icons.child_care_rounded;
      case 'shoe':
      case 'shoes':
        return Icons.hiking_rounded;
      case 'accessories':
        return Icons.watch_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    const backgroundColor = Color(0xFFF5F6FA);

    final categoriesAsync = ref.watch(categoriesProvider);
    final homeSectionsAsync = ref.watch(homeSectionsProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Search Bar Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StyleHub',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkNavy,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Dress Your Best',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: darkNavy, size: 26),
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Search Bar Stub
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: GestureDetector(
                  key: const Key('home_search_bar'),
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Search products, brands...',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Banner Slider Carousel
              SizedBox(
                height: 150,
                child: PageView(
                  key: const Key('home_banner_slider'),
                  controller: _bannerController,
                  onPageChanged: (index) {
                    setState(() {
                      _activeBannerIndex = index;
                    });
                  },
                  children: [
                    _buildBannerCard(
                      bgColor: darkNavy,
                      tag: 'NEW COLLECTION 2026',
                      title: '25% OFF On Selected Items',
                      buttonText: 'Explore Now',
                      accentColor: primaryPurple,
                    ),
                    _buildBannerCard(
                      bgColor: primaryPurple,
                      tag: 'FLASH SALE WEEKEND',
                      title: 'Up to 50% Discount Deals',
                      buttonText: 'Shop Sale',
                      accentColor: const Color(0xFFFF6584),
                    ),
                    _buildBannerCard(
                      bgColor: const Color(0xFF2C3E50),
                      tag: 'TRENDING FASHION',
                      title: 'Discover Essential Styles',
                      buttonText: 'View Trends',
                      accentColor: Colors.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Banner Dot Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _activeBannerIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _activeBannerIndex == index ? primaryPurple : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Categories Section
              _buildSectionHeader(
                title: 'Categories',
                onViewAll: null,
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (categories) => _buildCategoriesRow(categories),
                loading: () => const SizedBox(
                  height: 90,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
                  ),
                ),
                error: (err, stack) => _buildInlineError(
                  message: 'Failed to load categories',
                  onRetry: () => ref.invalidate(categoriesProvider),
                ),
              ),
              const SizedBox(height: 24),

              // Flash Sale Section
              homeSectionsAsync.when(
                data: (sections) => Column(
                  children: [
                    _buildSectionHeader(
                      title: 'Flash Sale',
                      badgeWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6584).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFFF6584)),
                            const SizedBox(width: 4),
                            Text(
                              '02:45:30',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF6584),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onViewAll: () => context.push('/search?isFlashSale=true'),
                    ),
                    const SizedBox(height: 12),
                    _buildHorizontalProductList('flash_sale_list', sections.flashSale),
                    const SizedBox(height: 24),

                    // New Arrivals Section
                    _buildSectionHeader(
                      title: 'New Arrivals',
                      onViewAll: () => context.push('/search?isNewArrival=true'),
                    ),
                    const SizedBox(height: 12),
                    _buildHorizontalProductList('new_arrivals_list', sections.newArrivals),
                    const SizedBox(height: 24),

                    // Trending Section
                    _buildSectionHeader(
                      title: 'Trending Now',
                      onViewAll: () => context.push('/search?isTrending=true'),
                    ),
                    const SizedBox(height: 12),
                    _buildHorizontalProductList('trending_list', sections.trending),
                    const SizedBox(height: 24),

                    // Best Sellers Section
                    _buildSectionHeader(
                      title: 'Best Sellers',
                      onViewAll: () => context.push('/search?isBestSeller=true'),
                    ),
                    const SizedBox(height: 12),
                    _buildHorizontalProductList('best_sellers_list', sections.bestSellers),
                  ],
                ),
                loading: () => Column(
                  children: List.generate(
                    3,
                    (index) => Container(
                      height: 220,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
                      ),
                    ),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildInlineError(
                    message: 'Failed to load product sections',
                    onRetry: () => ref.invalidate(homeSectionsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCard({
    required Color bgColor,
    required String tag,
    required String title,
    required String buttonText,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.poppins(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(List<Category> categories) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        key: const Key('home_categories_list'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            key: Key('category_item_${cat.slug}'),
            onTap: () => context.push('/categories/${cat.slug}'),
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getCategoryIcon(cat.iconName),
                      color: const Color(0xFF6C63FF),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E1E2D),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    Widget? badgeWidget,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1E2D),
                    ),
                  ),
                ),
                if (badgeWidget != null) ...[
                  const SizedBox(width: 8),
                  badgeWidget,
                ],
              ],
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(String keyName, List<ProductCard> products) {
    return SizedBox(
      height: 265,
      child: ListView.builder(
        key: Key(keyName),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCardWidget(product: products[index]);
        },
      ),
    );
  }

  Widget _buildInlineError({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                message,
                style: GoogleFonts.poppins(color: Colors.red[800], fontSize: 13),
              ),
            ],
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
