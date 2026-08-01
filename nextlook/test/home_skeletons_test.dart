import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/core/widgets/skeleton/skeleton_box.dart';
import 'package:nextlook/core/widgets/skeleton/skeleton_circle.dart';
import 'package:nextlook/core/widgets/skeleton/skeleton_text.dart';
import 'package:nextlook/features/home/presentation/widgets/home_skeletons.dart';
import 'package:nextlook/features/home/presentation/home_screen.dart';
import 'package:nextlook/features/products/application/product_providers.dart';
import 'package:nextlook/features/home/application/banner_providers.dart';
import 'package:nextlook/features/products/data/category_model.dart';
import 'package:nextlook/features/products/data/home_sections_model.dart';
import 'package:nextlook/features/products/data/product_card_model.dart';

const sampleCategory = Category(
  id: 'cat-1',
  name: 'Men',
  slug: 'men',
  iconName: 'men',
  productCount: 10,
);

const sampleProductCard = ProductCard(
  id: 'prod-1',
  name: 'Classic Leather Jacket',
  brand: 'NextLook',
  price: 199.99,
  rating: 4.8,
  reviewCount: 120,
  isFlashSale: true,
);

const sampleHomeSections = HomeSections(
  flashSale: [sampleProductCard],
  newArrivals: [sampleProductCard],
  trending: [sampleProductCard],
  bestSellers: [sampleProductCard],
);

void main() {
  group('Core Skeleton Primitives Tests', () {
    testWidgets('SkeletonBox renders with custom width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonBox(width: 100, height: 50),
          ),
        ),
      );
      expect(find.byType(SkeletonBox), findsOneWidget);
    });

    testWidgets('SkeletonCircle renders with specified diameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCircle(diameter: 60),
          ),
        ),
      );
      expect(find.byType(SkeletonCircle), findsOneWidget);
    });

    testWidgets('SkeletonText renders heading, body, and caption variants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SkeletonText.heading(width: 150),
                SkeletonText.body(width: 100),
                SkeletonText.caption(width: 50),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(SkeletonText), findsNWidgets(3));
    });
  });

  group('Home Screen Skeleton Layouts Tests', () {
    testWidgets('CategoriesRowSkeleton renders 5 skeleton items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoriesRowSkeleton(),
          ),
        ),
      );
      expect(find.byKey(const Key('categories_skeleton')), findsOneWidget);
    });

    testWidgets('HomeSectionsSkeleton renders product section skeletons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeSectionsSkeleton(),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('home_sections_skeleton')), findsOneWidget);
      expect(find.byType(ProductCardSkeleton), findsWidgets);
    });
  });

  group('HomeScreen Skeleton Integration & Loading Behavior Tests', () {
    testWidgets('HomeScreen renders skeleton placeholders when sections are loading', (tester) async {
      final categoriesCompleter = Completer<List<Category>>();
      final sectionsCompleter = Completer<HomeSections>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bannersProvider.overrideWith((ref) async => []),
            categoriesProvider.overrideWith((ref) => categoriesCompleter.future),
            homeSectionsProvider.overrideWith((ref) => sectionsCompleter.future),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CategoriesRowSkeleton), findsOneWidget);
      expect(find.byType(HomeSectionsSkeleton), findsOneWidget);
    });

    testWidgets('HomeScreen preserves independent section loading state', (tester) async {
      final sectionsCompleter = Completer<HomeSections>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bannersProvider.overrideWith((ref) async => []),
            categoriesProvider.overrideWith((ref) async => [sampleCategory]),
            homeSectionsProvider.overrideWith((ref) => sectionsCompleter.future),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Categories loaded
      expect(find.text('Men'), findsOneWidget);
      // Product sections still loading skeleton
      expect(find.byType(HomeSectionsSkeleton), findsOneWidget);
    });

    testWidgets('HomeScreen shows error state on failure instead of stuck skeleton', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bannersProvider.overrideWith((ref) async => []),
            categoriesProvider.overrideWith((ref) async => throw Exception('Network error')),
            homeSectionsProvider.overrideWith((ref) async => sampleHomeSections),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Failed to load categories'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(CategoriesRowSkeleton), findsNothing);
    });
  });
}
