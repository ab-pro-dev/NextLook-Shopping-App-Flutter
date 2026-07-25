import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextlook/features/products/application/product_providers.dart';
import 'package:nextlook/features/products/data/category_model.dart';
import 'package:nextlook/features/products/data/product_card_model.dart';
import 'package:nextlook/features/products/data/product_query_params.dart';
import 'package:nextlook/features/products/presentation/category_products_screen.dart';

void main() {
  final fakeCategories = [
    const Category(id: '1', name: 'Men', slug: 'men', iconName: 'male', productCount: 3),
    const Category(id: '2', name: 'Women', slug: 'women', iconName: 'female', productCount: 3),
  ];

  final fakeProducts = [
    const ProductCard(
      id: 'p1',
      name: 'Elegance Trench Coat',
      brand: 'NextLook Studio',
      price: 249.99,
      discountPrice: 179.99,
      rating: 4.8,
      reviewCount: 34,
      thumbnailUrl: null,
      isFlashSale: true,
    ),
  ];

  testWidgets('CategoryProductsScreen renders header title, sort button, and product grid', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesProvider.overrideWith((ref) async => fakeCategories),
          productListNotifierProvider.overrideWith(
            (ref) {
              final notifier = ProductListNotifier(ref.watch(productRepositoryProvider));
              notifier.state = AsyncValue.data(
                ProductListState(
                  params: const ProductQueryParams(category: 'men'),
                  products: fakeProducts,
                  total: 1,
                  page: 1,
                  totalPages: 1,
                ),
              );
              return notifier;
            },
          ),
        ],
        child: const MaterialApp(
          home: CategoryProductsScreen(categorySlug: 'men'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title & Filter icon
    expect(find.text('Men'), findsOneWidget);
    expect(find.byKey(const Key('filter_icon_button')), findsOneWidget);

    // Verify Sort selector button
    expect(find.byKey(const Key('sort_selector_button')), findsOneWidget);

    // Tap Filter icon
    await tester.tap(find.byKey(const Key('filter_icon_button')));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Filters sheet UI elements
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Price Range'), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
    expect(find.byKey(const Key('apply_filters_button')), findsOneWidget);
  });
}
