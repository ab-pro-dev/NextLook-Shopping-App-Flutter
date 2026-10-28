import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextlook/features/products/application/product_providers.dart';
import 'package:nextlook/features/products/data/category_model.dart';
import 'package:nextlook/features/products/data/product_card_model.dart';
import 'package:nextlook/features/products/data/product_query_params.dart';
import 'package:nextlook/features/products/presentation/search_screen.dart';

void main() {
  final fakeCategories = [
    const Category(id: '1', name: 'Men', slug: 'men', iconName: 'male', productCount: 3),
    const Category(id: '2', name: 'Women', slug: 'women', iconName: 'female', productCount: 3),
  ];

  final fakeProducts = [
    const ProductCard(
      id: 'p1',
      name: 'Classic Leather Biker Jacket',
      brand: 'UrbanEdge',
      price: 12000.0,
      discountPrice: 9500.0,
      rating: 4.8,
      reviewCount: 42,
      thumbnailUrl: null,
      isFlashSale: true,
    ),
    const ProductCard(
      id: 'p2',
      name: 'Minimalist Chronograph Watch',
      brand: 'Tempo',
      price: 8500.0,
      discountPrice: null,
      rating: 4.9,
      reviewCount: 95,
      thumbnailUrl: null,
      isFlashSale: false,
    ),
  ];

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SearchScreen Widget Tests', () {
    testWidgets('SearchScreen renders search input, sort selector, and product grid in search mode',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith((ref) async => fakeCategories),
            searchProductListNotifierProvider.overrideWith(
              (ref) {
                final notifier = ProductListNotifier(ref.watch(productRepositoryProvider));
                notifier.state = AsyncValue.data(
                  ProductListState(
                    params: const ProductQueryParams(search: 'jacket'),
                    products: fakeProducts,
                    total: 2,
                    page: 1,
                    totalPages: 1,
                  ),
                );
                return notifier;
              },
            ),
          ],
          child: const MaterialApp(
            home: SearchScreen(initialQuery: 'jacket'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Verify search text input exists with the initial query
      expect(find.byKey(const Key('search_screen_input')), findsOneWidget);
      expect(find.text('jacket'), findsOneWidget);

      // Verify sort selector and filter icon exist
      expect(find.byKey(const Key('search_sort_selector_button')), findsOneWidget);
      expect(find.byKey(const Key('search_filter_icon_button')), findsOneWidget);

      // Verify products are rendered
      expect(find.text('Classic Leather Biker Jacket'), findsOneWidget);
      expect(find.text('Minimalist Chronograph Watch'), findsOneWidget);
      expect(find.text('2 Products'), findsOneWidget);
    });

    testWidgets('SearchScreen renders Section View with title for Flash Sale', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith((ref) async => fakeCategories),
            searchProductListNotifierProvider.overrideWith(
              (ref) {
                final notifier = ProductListNotifier(ref.watch(productRepositoryProvider));
                notifier.state = AsyncValue.data(
                  ProductListState(
                    params: const ProductQueryParams(isFlashSale: true),
                    products: [fakeProducts.first],
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
            home: SearchScreen(isFlashSale: true),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Verify title shows 'Flash Sale'
      expect(find.text('Flash Sale'), findsOneWidget);

      // Verify 1 product shown
      expect(find.text('1 Products'), findsOneWidget);
      expect(find.text('Classic Leather Biker Jacket'), findsOneWidget);
    });

    testWidgets('SearchScreen shows empty state and popular searches when products list is empty',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith((ref) async => fakeCategories),
            searchProductListNotifierProvider.overrideWith(
              (ref) {
                final notifier = ProductListNotifier(ref.watch(productRepositoryProvider));
                notifier.state = AsyncValue.data(
                  const ProductListState(
                    params: ProductQueryParams(search: 'xyznonexistent'),
                    products: [],
                    total: 0,
                    page: 1,
                    totalPages: 0,
                  ),
                );
                return notifier;
              },
            ),
          ],
          child: const MaterialApp(
            home: SearchScreen(initialQuery: 'xyznonexistent'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Verify empty state text
      expect(find.text('No products found for "xyznonexistent"'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);
      expect(find.text('Popular Searches'), findsOneWidget);
      expect(find.text('Jacket'), findsOneWidget);
      expect(find.text('Shoes'), findsOneWidget);
    });

    testWidgets('Tapping home search bar navigates to SearchScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith((ref) async => fakeCategories),
            searchProductListNotifierProvider.overrideWith(
              (ref) {
                final notifier = ProductListNotifier(ref.watch(productRepositoryProvider));
                notifier.state = AsyncValue.data(
                  ProductListState(
                    params: const ProductQueryParams(),
                    products: fakeProducts,
                    total: 2,
                    page: 1,
                    totalPages: 1,
                  ),
                );
                return notifier;
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => GestureDetector(
                  key: const Key('home_search_bar'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  },
                  child: const Text('Search products, brands...'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byKey(const Key('home_search_bar')), findsOneWidget);

      await tester.tap(find.byKey(const Key('home_search_bar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Now on SearchScreen
      expect(find.byKey(const Key('search_screen_input')), findsOneWidget);
      expect(find.text('Classic Leather Biker Jacket'), findsOneWidget);
    });

    testWidgets('Tapping View all navigates to SearchScreen with section title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith((ref) async => fakeCategories),
            searchProductListNotifierProvider.overrideWith(
              (ref) {
                final notifier = ProductListNotifier(ref.watch(productRepositoryProvider));
                notifier.state = AsyncValue.data(
                  ProductListState(
                    params: const ProductQueryParams(isFlashSale: true),
                    products: [fakeProducts.first],
                    total: 1,
                    page: 1,
                    totalPages: 1,
                  ),
                );
                return notifier;
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => GestureDetector(
                  key: const Key('flash_sale_view_all'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(isFlashSale: true),
                      ),
                    );
                  },
                  child: const Text('View all'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byKey(const Key('flash_sale_view_all')), findsOneWidget);

      await tester.tap(find.byKey(const Key('flash_sale_view_all')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Now on SearchScreen with Flash Sale title
      expect(find.text('Flash Sale'), findsOneWidget);
      expect(find.text('Classic Leather Biker Jacket'), findsOneWidget);
    });
  });
}
