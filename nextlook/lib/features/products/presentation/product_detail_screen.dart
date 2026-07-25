import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/product_card.dart';
import '../application/product_providers.dart';
import '../data/product_detail_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final PageController _imagePageController = PageController();
  int _activeImageIndex = 0;

  bool _isWishlisted = false;
  ProductColor? _selectedColor;
  ProductSize? _selectedSize;

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hexCode) {
    try {
      final cleanHex = hexCode.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } catch (_) {}
    return Colors.grey;
  }

  bool get _canAddToCart => _selectedColor != null && _selectedSize != null && !_selectedSize!.isOutOfStock;

  void _onAddToCartTap() {
    if (!_canAddToCart) {
      String hint = 'Please select a size';
      if (_selectedColor == null && _selectedSize == null) {
        hint = 'Please select a color and a size';
      } else if (_selectedColor == null) {
        hint = 'Please select a color';
      }
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hint,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF1E1E2D),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // NOTE: Real cart & checkout logic will be connected in a future phase.
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coming soon! Cart & Checkout logic will be enabled in the next phase.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    const discountPink = Color(0xFFFF6584);
    const backgroundColor = Color(0xFFF8F9FC);

    final productDetailAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: productDetailAsync.when(
        data: (product) {
          final images = List<ProductImage>.from(product.images)
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          return Stack(
            children: [
              // Scrollable Details Body
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP IMAGE CAROUSEL AREA
                    Stack(
                      children: [
                        SizedBox(
                          height: 380,
                          child: PageView.builder(
                            controller: _imagePageController,
                            onPageChanged: (index) {
                              setState(() {
                                _activeImageIndex = index;
                              });
                            },
                            itemCount: images.isNotEmpty ? images.length : 1,
                            itemBuilder: (context, index) {
                              final imageUrl = images.isNotEmpty ? images[index].url : null;
                              return Container(
                                color: Colors.white,
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: primaryPurple,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => const Center(
                                          child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(Icons.image_not_supported_rounded, size: 64, color: Colors.grey),
                                      ),
                              );
                            },
                          ),
                        ),

                        // Floating Overlaid Header Buttons (Back, Share, Wishlist)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              CircleAvatar(
                                backgroundColor: Colors.white.withValues(alpha: 0.85),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded, color: darkNavy, size: 20),
                                  onPressed: () => context.pop(),
                                ),
                              ),

                              Row(
                                children: [
                                  // Share Button
                                  CircleAvatar(
                                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                                    child: IconButton(
                                      icon: const Icon(Icons.share_outlined, color: darkNavy, size: 20),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Sharing coming soon')),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Wishlist Heart Button
                                  // NOTE: Wishlist persistence is a future phase. Toggles local UI state for now.
                                  CircleAvatar(
                                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                                    child: IconButton(
                                      key: const Key('wishlist_heart_button'),
                                      icon: Icon(
                                        _isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                        color: _isWishlisted ? discountPink : darkNavy,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isWishlisted = !_isWishlisted;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Dot Indicators
                    if (images.length > 1) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _activeImageIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _activeImageIndex == index ? primaryPurple : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],

                    // 2. PRODUCT INFO SECTION
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.brand != null && product.brand!.isNotEmpty) ...[
                            Text(
                              product.brand!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            product.name,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Price Row & Discount Badge
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '\$${(product.hasDiscount ? product.discountPrice! : product.price).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPurple,
                                ),
                              ),
                              if (product.hasDiscount) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[400],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: discountPink,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '-${product.discountPercent}%',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Rating Row
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: darkNavy,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${product.reviewCount})',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // 3. COLOR SELECTOR
                          if (product.colors.isNotEmpty) ...[
                            Text(
                              'Color',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkNavy,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: product.colors.map((c) {
                                  final isSelected = _selectedColor?.id == c.id || _selectedColor?.name == c.name;
                                  final swatchColor = _parseHexColor(c.hexCode);
                                  return GestureDetector(
                                    key: Key('color_swatch_${c.name}'),
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = c;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 14),
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? primaryPurple : Colors.transparent,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: swatchColor,
                                        child: isSelected
                                            ? Icon(
                                                Icons.check_rounded,
                                                color: swatchColor.computeLuminance() > 0.5
                                                    ? Colors.black
                                                    : Colors.white,
                                                size: 18,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // 4. SIZE SELECTOR
                          if (product.sizes.isNotEmpty) ...[
                            Text(
                              'Size',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkNavy,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: product.sizes.map((s) {
                                  final isSelected = _selectedSize?.id == s.id || _selectedSize?.label == s.label;
                                  final isOutOfStock = s.isOutOfStock;

                                  return GestureDetector(
                                    key: Key('size_chip_${s.label}'),
                                    onTap: isOutOfStock
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedSize = s;
                                            });
                                          },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isOutOfStock
                                            ? Colors.grey[200]
                                            : (isSelected ? primaryPurple : Colors.white),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isOutOfStock
                                              ? Colors.grey[300]!
                                              : (isSelected ? primaryPurple : Colors.grey[300]!),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          s.label,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isOutOfStock
                                                ? Colors.grey[400]
                                                : (isSelected ? Colors.white : darkNavy),
                                            decoration: isOutOfStock ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 5. DESCRIPTION SECTION
                          Text(
                            'Description',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 6. SIMILAR PRODUCTS SECTION
                          _buildSimilarProductsSection(ref, product),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 7. FIXED BOTTOM BAR (Add to Cart & Buy Now)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 14,
                    bottom: MediaQuery.of(context).padding.bottom + 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Add to Cart (Outlined Style)
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('add_to_cart_button'),
                          onPressed: _onAddToCartTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: _canAddToCart ? darkNavy : Colors.grey[300]!,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Add to Cart',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _canAddToCart ? darkNavy : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Buy Now (Filled Style)
                      Expanded(
                        child: ElevatedButton(
                          key: const Key('buy_now_button'),
                          onPressed: _onAddToCartTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canAddToCart ? darkNavy : Colors.grey[300],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Buy Now',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _canAddToCart ? Colors.white : Colors.grey[500],
                            ),
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
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load product details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        child: Text('Go Back', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(productDetailProvider(widget.productId)),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                        child: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Similar Products Section fetching products from the same category
  Widget _buildSimilarProductsSection(WidgetRef ref, ProductDetail product) {
    const darkNavy = Color(0xFF1E1E2D);
    const primaryPurple = Color(0xFF6C63FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar Products',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkNavy,
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder(
          future: ref.read(productRepositoryProvider).getProducts(category: product.categorySlug),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final products = snapshot.data!.products
                .where((p) => p.id != product.id)
                .toList();

            if (products.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 265,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/product/${p.id}');
                    },
                    child: ProductCardWidget(product: p),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
