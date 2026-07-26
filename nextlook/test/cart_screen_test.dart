import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextlook/features/cart/application/cart_providers.dart';
import 'package:nextlook/features/cart/data/cart_models.dart';
import 'package:nextlook/features/cart/presentation/cart_screen.dart';

class FakeCartNotifier extends CartNotifier {
  final CartSummary initialState;

  FakeCartNotifier(this.initialState);

  @override
  Future<CartSummary> build() async {
    return initialState;
  }
}

void main() {
  const fakeItem = CartItem(
    id: 'item1',
    productId: 'prod1',
    name: 'Classic Leather Biker Jacket',
    brand: 'UrbanEdge',
    thumbnailUrl: null,
    price: 10000,
    discountPrice: 7500,
    colorName: 'Black',
    sizeLabel: 'M',
    quantity: 2,
    lineTotal: 15000,
    inStock: true,
  );

  testWidgets('CartScreen displays empty state when cart is empty', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartProvider.overrideWith(
            () => FakeCartNotifier(CartSummary.empty()),
          ),
        ],
        child: const MaterialApp(
          home: CartScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byKey(const Key('browse_products_cart_button')), findsOneWidget);
  });

  testWidgets('CartScreen displays cart item, quantity stepper, and totals', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartProvider.overrideWith(
            () => FakeCartNotifier(
              const CartSummary(
                items: [fakeItem],
                subtotal: 15000,
                itemCount: 2,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: CartScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Classic Leather Biker Jacket'), findsOneWidget);
    expect(find.text('Color: Black  |  Size: M'), findsOneWidget);
    expect(find.text('ETB 15,000'), findsNWidgets(3)); // line total, subtotal & total
    expect(find.byKey(const Key('cart_item_row_item1')), findsOneWidget);
    expect(find.byKey(const Key('checkout_button')), findsOneWidget);
  });
}
