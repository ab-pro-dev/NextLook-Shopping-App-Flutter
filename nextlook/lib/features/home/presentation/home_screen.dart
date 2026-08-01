import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widgets/product_card.dart';
import '../../products/application/product_providers.dart';
import '../../products/data/category_model.dart';
import '../../products/data/product_card_model.dart';
import '../../notifications/application/notification_providers.dart';
import '../application/banner_providers.dart';
import '../data/models/banner_model.dart';
import 'widgets/home_skeletons.dart';

/// Real Home Screen for NextLook matching the exact UI spec from The_App_UI.png
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerController = PageController();
  int _activeBannerIndex = 0;
  Timer? _bannerTimer;
  int _currentBannerCount = 0;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _updateAutoScrollTimer(int totalBanners) {
    if (_currentBannerCount == totalBanners) return;
    _currentBannerCount = totalBanners;
    _bannerTimer?.cancel();

    if (totalBanners > 1) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_bannerController.hasClients && _currentBannerCount > 1) {
          final nextPage = (_activeBannerIndex + 1) % _currentBannerCount;
          _bannerController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

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

  /// Sort categories in the exact reference order: Men, Women, Kids, Shoes, Accessories
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
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    const backgroundColor = Color(0xFFF8F9FC);

    final bannersAsync = ref.watch(bannersProvider);
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
              const SizedBox(height: 12),

              // 1. TOP OF SCREEN: Search Bar + Notification Bell Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        key: const Key('home_search_bar'),
                        onTap: () => context.push('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                              Expanded(
                                child: Text(
                                  'Search products, brands...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Icon(Icons.tune_rounded, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Consumer(
                      builder: (context, ref, child) {
                        final unreadCount = ref.watch(unreadNotificationCountProvider);

                        return GestureDetector(
                          key: const Key('home_notification_bell'),
                          onTap: () => context.push('/notifications'),
                          child: Container(
                            width: 48,
                            height: 48,
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
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.notifications_outlined, color: darkNavy, size: 24),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: primaryPurple,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$unreadCount',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. HERO BANNER SLIDER (Dynamic banners from backend API)
              bannersAsync.when(
                data: (banners) => _buildBannerSection(banners),
                loading: () => const Column(
                  children: [
                    BannerSkeleton(),
                    SizedBox(height: 24),
                  ],
                ),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              // 3. CATEGORIES ROW: Fixed order (Men, Women, Kids, Shoes, Accessories)
              _buildSectionHeader(
                title: 'Categories',
                onViewAll: null,
              ),
              const SizedBox(height: 14),
              categoriesAsync.when(
                data: (categories) => _buildCategoriesRow(_sortCategories(categories)),
                loading: () => const CategoriesRowSkeleton(),
                error: (err, stack) => _buildInlineError(
                  message: 'Failed to load categories',
                  onRetry: () => ref.invalidate(categoriesProvider),
                ),
              ),
              const SizedBox(height: 24),

              // 4. FLASH SALE + PRODUCT CARDS SECTION
              homeSectionsAsync.when(
                data: (sections) => Column(
                  children: [
                    _buildSectionHeader(
                      title: 'Flash Sale',
                      badgeWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6584).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFFF6584)),
                            const SizedBox(width: 4),
                            Text(
                              '02 : 45 : 30',
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
                    const SizedBox(height: 14),
                    _buildHorizontalProductList('flash_sale_list', sections.flashSale),
                    const SizedBox(height: 24),

                    // New Arrivals Section
                    _buildSectionHeader(
                      title: 'New Arrivals',
                      onViewAll: () => context.push('/search?isNewArrival=true'),
                    ),
                    const SizedBox(height: 14),
                    _buildHorizontalProductList('new_arrivals_list', sections.newArrivals),
                    const SizedBox(height: 24),

                    // Trending Section
                    _buildSectionHeader(
                      title: 'Trending Now',
                      onViewAll: () => context.push('/search?isTrending=true'),
                    ),
                    const SizedBox(height: 14),
                    _buildHorizontalProductList('trending_list', sections.trending),
                    const SizedBox(height: 24),

                    // Best Sellers Section
                    _buildSectionHeader(
                      title: 'Best Sellers',
                      onViewAll: () => context.push('/search?isBestSeller=true'),
                    ),
                    const SizedBox(height: 14),
                    _buildHorizontalProductList('best_sellers_list', sections.bestSellers),
                  ],
                ),
                loading: () => const HomeSectionsSkeleton(),
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

  /// Dynamic Hero Banner Slider section fed from backend API
  Widget _buildBannerSection(List<BannerModel> banners) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    _updateAutoScrollTimer(banners.length);

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            key: const Key('home_banner_slider'),
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                _activeBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildBannerCard(banners[index]);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Banner Dot Indicators (only show if > 1 banner)
        if (banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _activeBannerIndex == index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _activeBannerIndex == index ? const Color(0xFF1E1E2D) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Banner Card widget rendering network image, title, subtitle, and action CTA button
  Widget _buildBannerCard(BannerModel banner) {
    final hasCategoryNav = banner.categorySlug != null && banner.categorySlug!.trim().isNotEmpty;

    void handleBannerTap() {
      if (hasCategoryNav) {
        context.push('/categories/${banner.categorySlug!.trim()}/products');
      }
    }

    return GestureDetector(
      onTap: handleBannerTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF161A23),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Background network photo image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  placeholder: (context, url) => Container(color: const Color(0xFF1E1E2D)),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF1E1E2D),
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 36),
                    ),
                  ),
                ),
              ),

              // Soft left-to-right gradient overlay for optimal text readability while keeping the image vibrant
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Content Overlay
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    if (banner.subtitle != null && banner.subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        banner.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    // Action CTA button
                    GestureDetector(
                      onTap: handleBannerTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1219),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: Text(
                          (banner.buttonText != null && banner.buttonText!.trim().isNotEmpty)
                              ? banner.buttonText!
                              : 'Explore Now',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Circular Avatar-Style Category Row matching the reference layout
  Widget _buildCategoriesRow(List<Category> categories) {
    return SizedBox(
      height: 92,
      child: ListView.builder(
        key: const Key('home_categories_list'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          // NOTE: Circular avatar category icon placeholders. Flagged for real photo assets.
          return GestureDetector(
            key: Key('category_item_${cat.slug}'),
            onTap: () => context.push('/categories/${cat.slug}/products'),
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1F6), // Soft light-grey circular avatar background
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(cat.iconName),
                        color: const Color(0xFF1E1E2D),
                        size: 24,
                      ),
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
                  fontSize: 12,
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
