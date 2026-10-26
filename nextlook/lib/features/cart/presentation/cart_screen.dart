import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/sign_in_required_view.dart';
import '../../../core/widgets/skeleton/product_list_row_skeleton.dart';
import '../../auth/application/auth_providers.dart';
import '../application/cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryPurple = Color(0xFF6C63FF);
    const darkNavy = Color(0xFF1E1E2D);
    const backgroundColor = Color(0xFFF8F9FC);
    const discountPink = Color(0xFFFF6584);

    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Title & Item Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(
                children: [
                  Text(
                    'Cart',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  cartAsync.maybeWhen(
                    data: (cart) => Text(
                      '(${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'})',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Cart Main Content
            Expanded(
              child: cartAsync.when(
                data: (cart) {
                  final items = cart.items;

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
                                color: primaryPurple.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: primaryPurple,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Your cart is empty',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkNavy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Explore our collection and add items to your cart.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              key: const Key('browse_products_cart_button'),
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

                  final hasOutOfStockItem = items.any((item) => !item.inStock);

                  return Column(
                    children: [
                      // List of Cart Items
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return Container(
                              key: Key('cart_item_row_${item.id}'),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: item.inStock ? Colors.grey[200]! : discountPink.withValues(alpha: 0.5),
                                  width: item.inStock ? 1 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        color: const Color(0xFFF5F6FA),
                                        child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: item.thumbnailUrl!,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: primaryPurple,
                                                  ),
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
                                    const SizedBox(width: 12),

                                    // Product Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: darkNavy,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Color: ${item.colorName}  |  Size: ${item.sizeLabel}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                formatPrice(item.lineTotal),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryPurple,
                                                ),
                                              ),
                                              if (!item.inStock) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: discountPink.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'Out of stock',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: discountPink,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Stepper & Remove Button Column
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // Remove Item Button
                                        IconButton(
                                          key: Key('remove_cart_item_${item.id}'),
                                          icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 20),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            try {
                                              await ref.read(cartProvider.notifier).removeItem(item.id);
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Failed to remove item', style: GoogleFonts.poppins()),
                                                    backgroundColor: Colors.redAccent,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 8),

                                        // Quantity Stepper
                                        Container(
                                          decoration: BoxDecoration(
                                            color: item.inStock ? const Color(0xFFF5F6FA) : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                key: Key('cart_decrement_${item.id}'),
                                                onTap: item.inStock
                                                    ? () async {
                                                        try {
                                                          await ref
                                                              .read(cartProvider.notifier)
                                                              .updateQuantity(item.id, item.quantity - 1);
                                                        } on ApiException catch (e) {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Text(e.message, style: GoogleFonts.poppins()),
                                                                backgroundColor: Colors.redAccent,
                                                              ),
                                                            );
                                                          }
                                                        } catch (_) {}
                                                      }
                                                    : null,
                                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                    color: item.inStock ? darkNavy : Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: item.inStock ? darkNavy : Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                key: Key('cart_increment_${item.id}'),
                                                onTap: item.inStock
                                                    ? () async {
                                                        try {
                                                          await ref
                                                              .read(cartProvider.notifier)
                                                              .updateQuantity(item.id, item.quantity + 1);
                                                        } on ApiException catch (e) {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Text(e.message, style: GoogleFonts.poppins()),
                                                                backgroundColor: Colors.redAccent,
                                                              ),
                                                            );
                                                          }
                                                        } catch (_) {}
                                                      }
                                                    : null,
                                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: item.inStock ? darkNavy : Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Order Summary & Checkout Bottom Area
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Subtotal Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                ),
                                Text(
                                  formatPrice(cart.subtotal),
                                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: darkNavy),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Shipping Row (Placeholder)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Shipping',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                ),
                                Text(
                                  'Free',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Tax Row (Placeholder)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tax',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                ),
                                Text(
                                  formatPrice(0),
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: darkNavy),
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            // Total Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: darkNavy),
                                ),
                                Text(
                                  formatPrice(cart.subtotal),
                                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryPurple),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Checkout Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                key: const Key('checkout_button'),
                                onPressed: () {
                                  if (hasOutOfStockItem) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please remove out of stock items to proceed', style: GoogleFonts.poppins()),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  final authState = ref.read(authControllerProvider);
                                  if (authState is! AuthAuthenticated) {
                                    ensureAuthenticated(
                                      context,
                                      ref,
                                      message: 'Sign in to complete checkout.',
                                      onAuthenticated: () async {
                                        if (context.mounted) {
                                          context.push('/checkout');
                                        }
                                      },
                                    );
                                    return;
                                  }

                                  context.push('/checkout');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasOutOfStockItem ? Colors.grey[400] : primaryPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Checkout',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const ProductListRowsSkeleton(itemCount: 3),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load cart',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkNavy,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => ref.read(cartProvider.notifier).refresh(),
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
