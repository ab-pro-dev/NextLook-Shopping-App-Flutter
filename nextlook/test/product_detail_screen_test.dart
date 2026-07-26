import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextlook/features/cart/application/cart_providers.dart';
import 'package:nextlook/features/cart/data/cart_models.dart';
import 'package:nextlook/features/products/application/product_providers.dart';
import 'package:nextlook/features/products/data/product_detail_model.dart';
import 'package:nextlook/features/products/presentation/product_detail_screen.dart';

class FakeCartNotifier extends CartNotifier {
  @override
  Future<CartSummary> build() async {
    return CartSummary.empty();
  }

  @override
  Future<void> addToCart({
    required String productId,
    required String colorName,
    required String sizeLabel,
    required int quantity,
  }) async {
    state = const AsyncValue.data(
      CartSummary(items: [], subtotal: 7500, itemCount: 1),
    );
  }
}

void main() {
  const fakeDetail = ProductDetail(
    id: '4c40a244-09d6-41ed-911c-1d0fdb0fb5e0',
    name: 'Classic Leather Biker Jacket',
    description: 'Premium genuine lambskin leather jacket with asymmetrical zip closure.',
    brand: 'UrbanEdge',
    categoryName: 'Men',
    categorySlug: 'men',
    price: 10000,
    discountPrice: 7500,
    rating: 4.8,
    reviewCount: 124,
    images: [
      ProductImage(id: 'img1', url: 'https://picsum.photos/800/800', sortOrder: 0),
      ProductImage(id: 'img2', url: 'https://picsum.photos/800/800', sortOrder: 1),
    ],
    colors: [
      ProductColor(id: 'c1', name: 'Black', hexCode: '#000000'),
      ProductColor(id: 'c2', name: 'Dark Brown', hexCode: '#3E2723'),
    ],
    sizes: [
      ProductSize(id: 's1', label: 'S', stock: 10),
      ProductSize(id: 's2', label: 'M', stock: 15),
      ProductSize(id: 's3', label: 'L', stock: 20),
      ProductSize(id: 's4', label: 'XL', stock: 0), // Out of stock
    ],
    sku: 'MEN-JKT-001',
    isFlashSale: true,
    isNewArrival: false,
    isTrending: true,
    isBestSeller: true,
  );

  testWidgets('ProductDetailScreen renders title, brand, converted price, badges, colors & sizes', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productDetailProvider('4c40a244-09d6-41ed-911c-1d0fdb0fb5e0')
              .overrideWith((ref) async => fakeDetail),
          cartProvider.overrideWith(() => FakeCartNotifier()),
        ],
        child: const MaterialApp(
          home: ProductDetailScreen(productId: '4c40a244-09d6-41ed-911c-1d0fdb0fb5e0'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title, Brand, Price, Rating
    expect(find.text('Classic Leather Biker Jacket'), findsOneWidget);
    expect(find.text('UrbanEdge'), findsOneWidget);
    expect(find.text('ETB 7,500'), findsOneWidget);
    expect(find.text('ETB 10,000'), findsOneWidget);
    expect(find.text('-25%'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('(124)'), findsOneWidget);

    // Verify Colors and Sizes
    expect(find.byKey(const Key('color_swatch_Black')), findsOneWidget);
    expect(find.byKey(const Key('size_chip_S')), findsOneWidget);
    expect(find.byKey(const Key('size_chip_XL')), findsOneWidget);

    // Ensure elements are visible and tap
    await tester.ensureVisible(find.byKey(const Key('color_swatch_Black')));
    await tester.tap(find.byKey(const Key('color_swatch_Black')));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byKey(const Key('size_chip_M')));
    await tester.tap(find.byKey(const Key('size_chip_M')));
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Add to Cart after selection - calls addToCart and shows snackbar
    await tester.ensureVisible(find.byKey(const Key('add_to_cart_button')));
    await tester.tap(find.byKey(const Key('add_to_cart_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Added to Cart'), findsOneWidget);

    // Toggle Wishlist Heart
    expect(find.byKey(const Key('wishlist_heart_button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('wishlist_heart_button')), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));

    // Finish any remaining toast auto-dismiss timers
    await tester.pump(const Duration(seconds: 3));
  });
}
