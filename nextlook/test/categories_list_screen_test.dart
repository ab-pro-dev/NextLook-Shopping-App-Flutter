import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextlook/features/products/application/product_providers.dart';
import 'package:nextlook/features/products/data/category_model.dart';
import 'package:nextlook/features/products/presentation/categories_list_screen.dart';

void main() {
  final fakeCategories = [
    const Category(id: '1', name: 'Men', slug: 'men', iconName: 'male', productCount: 3),
    const Category(id: '2', name: 'Women', slug: 'women', iconName: 'female', productCount: 3),
    const Category(id: '3', name: 'Kids', slug: 'kids', iconName: 'child', productCount: 2),
    const Category(id: '4', name: 'Shoes', slug: 'shoes', iconName: 'shoe', productCount: 2),
    const Category(id: '5', name: 'Accessories', slug: 'accessories', iconName: 'accessories', productCount: 2),
  ];

  testWidgets('CategoriesListScreen renders header, search icon, and category list with item counts', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesProvider.overrideWith((ref) async => fakeCategories),
        ],
        child: const MaterialApp(
          home: CategoriesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Search icon
    expect(find.text('Categories'), findsOneWidget);
    expect(find.byKey(const Key('categories_search_icon')), findsOneWidget);

    // Verify Category names
    expect(find.text('Men'), findsOneWidget);
    expect(find.text('Women'), findsOneWidget);
    expect(find.text('Kids'), findsOneWidget);
    expect(find.text('Shoes'), findsOneWidget);
    expect(find.text('Accessories'), findsOneWidget);

    // Verify item counts
    expect(find.text('3 items'), findsNWidgets(2)); // Men & Women
    expect(find.text('2 items'), findsNWidgets(3)); // Kids, Shoes, Accessories
  });
}
