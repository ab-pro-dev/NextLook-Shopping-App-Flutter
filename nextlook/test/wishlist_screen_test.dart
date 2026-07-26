import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextlook/features/products/data/product_card_model.dart';
import 'package:nextlook/features/wishlist/application/wishlist_providers.dart';
import 'package:nextlook/features/wishlist/presentation/wishlist_screen.dart';

class FakeWishlistNotifier extends WishlistNotifier {
  final WishlistState initialState;

  FakeWishlistNotifier(this.initialState);

  @override
  Future<WishlistState> build() async {
    return initialState;
  }
}

void main() {
  const fakeProduct = ProductCard(
    id: 'p1',
    name: 'Elegance Trench Coat',
    brand: 'NextLook Studio',
    price: 12500,
    discountPrice: 9000,
    rating: 4.8,
    reviewCount: 34,
    thumbnailUrl: null,
    isFlashSale: true,
  );

  testWidgets('WishlistScreen displays empty state when items are empty', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wishlistNotifierProvider.overrideWith(
            () => FakeWishlistNotifier(const WishlistState(items: [], wishlistedIds: {})),
          ),
        ],
        child: const MaterialApp(
          home: WishlistScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.text('Your wishlist is empty'), findsOneWidget);
    expect(find.byKey(const Key('browse_products_button')), findsOneWidget);
  });

  testWidgets('WishlistScreen displays wishlisted products and removes on heart tap', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wishlistNotifierProvider.overrideWith(
            () => FakeWishlistNotifier(const WishlistState(items: [fakeProduct], wishlistedIds: {'p1'})),
          ),
        ],
        child: const MaterialApp(
          home: WishlistScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Elegance Trench Coat'), findsOneWidget);
    expect(find.text('NextLook Studio'), findsOneWidget);
    expect(find.text('ETB 9,000'), findsOneWidget);
    expect(find.byKey(const Key('remove_wishlist_heart_p1')), findsOneWidget);
  });
}
