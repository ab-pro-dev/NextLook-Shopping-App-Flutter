import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../application/wishlist_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/sign_in_required_view.dart';
import '../../../core/widgets/skeleton/product_list_row_skeleton.dart';
import '../../auth/application/auth_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    const discountPink = Color(0xFFFF6584);
    const backgroundColor = Color(0xFFF8F9FC);

    final authState = ref.watch(authControllerProvider);
    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const SafeArea(
          child: SignInRequiredView(
            title: 'Sign In Required',
            message: 'Sign in to see your wishlist and saved items.',
            icon: Icons.favorite_border_rounded,
          ),
        ),
      );
    }

    final wishlistAsync = ref.watch(wishlistNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Title & Search Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wishlist',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkNavy,
                    ),
                  ),
                  IconButton(
                    key: const Key('wishlist_search_icon'),
                    icon: const Icon(Icons.search_rounded, color: darkNavy, size: 26),
                    onPressed: () => context.push('/search'),
                  ),
                ],
              ),
            ),

            // Main Wishlist Content
            Expanded(
              child: wishlistAsync.when(
                data: (wishlistState) {
                  final items = wishlistState.items;

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: discountPink.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_border_rounded,
                                size: 64,
                                color: discountPink,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Your wishlist is empty',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkNavy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Explore our collection and add items to your wishlist.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              key: const Key('browse_products_button'),
                              onPressed: () => context.go('/home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Browse Products',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = items[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            key: Key('wishlist_row_${product.id}'),
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/product/${product.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Product Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      color: const Color(0xFFF5F6FA),
                                      child: product.thumbnailUrl != null && product.thumbnailUrl!.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: product.thumbnailUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(
                                                Icons.broken_image_rounded,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image_not_supported_rounded,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (product.brand != null && product.brand!.isNotEmpty) ...[
                                          Text(
                                            product.brand!,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                        ],
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: darkNavy,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              formatPrice(product.hasDiscount ? product.discountPrice! : product.price),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: primaryPurple,
                                              ),
                                            ),
                                            if (product.hasDiscount) ...[
                                              const SizedBox(width: 6),
                                              Text(
                                                formatPrice(product.price),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.grey[400],
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Remove from Wishlist Heart Button
                                  IconButton(
                                    key: Key('remove_wishlist_heart_${product.id}'),
                                    icon: const Icon(
                                      Icons.favorite_rounded,
                                      color: discountPink,
                                      size: 24,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(wishlistNotifierProvider.notifier)
                                            .toggleWishlist(product);
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to remove from wishlist',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
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
                loading: () => const ProductListRowsSkeleton(itemCount: 3),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 44, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load wishlist',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: darkNavy,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => ref.read(wishlistNotifierProvider.notifier).refresh(),
                          style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
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
      ),
    );
  }
}
