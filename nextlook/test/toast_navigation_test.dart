import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextlook/features/cart/application/cart_providers.dart';
import 'package:nextlook/features/cart/data/cart_models.dart';
import 'package:nextlook/features/cart/presentation/cart_screen.dart';
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
      CartSummary(items: [], subtotal: 149.99, itemCount: 1),
    );
  }
}

void main() {
  const fakeDetail = ProductDetail(
    id: '4c40a244-09d6-41ed-911c-1d0fdb0fb5e0',
    name: 'Classic Leather Biker Jacket',
    description: 'Premium genuine lambskin leather jacket.',
    brand: 'UrbanEdge',
    categoryName: 'Men',
    categorySlug: 'men',
    price: 199.99,
    discountPrice: 149.99,
    rating: 4.8,
    reviewCount: 124,
    images: [],
    colors: [ProductColor(id: 'c1', name: 'Black', hexCode: '#000000')],
    sizes: [ProductSize(id: 's1', label: 'M', stock: 10)],
    sku: 'MEN-JKT-001',
    isFlashSale: true,
    isNewArrival: false,
    isTrending: true,
    isBestSeller: true,
  );

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        productDetailProvider('4c40a244-09d6-41ed-911c-1d0fdb0fb5e0')
            .overrideWith((ref) async => fakeDetail),
        cartProvider.overrideWith(() => FakeCartNotifier()),
      ],
      child: MaterialApp(
        routes: {
          '/': (context) => const ProductDetailScreen(productId: '4c40a244-09d6-41ed-911c-1d0fdb0fb5e0'),
          '/cart': (context) => const CartScreen(),
        },
      ),
    );
  }

  testWidgets('SCENARIO A: Immediate tap View Cart before auto-dismiss navigates cleanly without error', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 300));

    // Select color & size
    await tester.ensureVisible(find.byKey(const Key('color_swatch_Black')));
    await tester.tap(find.byKey(const Key('color_swatch_Black')), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byKey(const Key('size_chip_M')));
    await tester.tap(find.byKey(const Key('size_chip_M')), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Add to Cart
    await tester.ensureVisible(find.byKey(const Key('add_to_cart_button')));
    await tester.tap(find.byKey(const Key('add_to_cart_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Added to Cart'), findsOneWidget);

    // IMMEDIATELY tap View Cart (0ms after appearance)
    await tester.tap(find.byKey(const Key('toast_action_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify clean navigation to CartScreen
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Added to Cart'), findsNothing);

    // Ensure timer cleanup
    await tester.pump(const Duration(seconds: 3));
    debugPrint('[Console Scenario A]: Immediate tap navigated cleanly to CartScreen with 0 errors.');
  });

  testWidgets('SCENARIO B: Untouched toast auto-dismisses cleanly after 2.5 seconds', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 300));

    // Select color & size
    await tester.ensureVisible(find.byKey(const Key('color_swatch_Black')));
    await tester.tap(find.byKey(const Key('color_swatch_Black')), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byKey(const Key('size_chip_M')));
    await tester.tap(find.byKey(const Key('size_chip_M')), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Add to Cart
    await tester.ensureVisible(find.byKey(const Key('add_to_cart_button')));
    await tester.tap(find.byKey(const Key('add_to_cart_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Added to Cart'), findsOneWidget);

    // Wait 2.5 seconds for auto-dismiss timer, then pump 300ms for reverse animation
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 300));

    // Toast is dismissed automatically
    expect(find.text('Added to Cart'), findsNothing);
    debugPrint('[Console Scenario B]: Toast auto-dismissed cleanly after 2.5s with 0 errors.');
  });

  testWidgets('SCENARIO C: Tap View Cart after 1 second (timer overlap) navigates cleanly', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 300));

    // Select color & size
    await tester.ensureVisible(find.byKey(const Key('color_swatch_Black')));
    await tester.tap(find.byKey(const Key('color_swatch_Black')), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byKey(const Key('size_chip_M')));
    await tester.tap(find.byKey(const Key('size_chip_M')), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Add to Cart
    await tester.ensureVisible(find.byKey(const Key('add_to_cart_button')));
    await tester.tap(find.byKey(const Key('add_to_cart_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Added to Cart'), findsOneWidget);

    // Wait 1.0 second
    await tester.pump(const Duration(seconds: 1));

    // Tap View Cart after 1 second delay
    await tester.tap(find.byKey(const Key('toast_action_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify clean navigation to CartScreen and timer cancellation
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Added to Cart'), findsNothing);

    // Ensure timer cancellation
    await tester.pump(const Duration(seconds: 3));
    debugPrint('[Console Scenario C]: Tap after 1s navigated cleanly to CartScreen, cancelled timer, 0 errors.');
  });
}
