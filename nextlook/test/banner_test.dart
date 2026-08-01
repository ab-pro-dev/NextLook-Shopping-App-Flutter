import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nextlook/features/home/data/models/banner_model.dart';
import 'package:nextlook/features/home/application/banner_providers.dart';
import 'package:nextlook/features/products/application/product_providers.dart';
import 'package:nextlook/features/products/data/category_model.dart';
import 'package:nextlook/features/products/data/home_sections_model.dart';
import 'package:nextlook/features/notifications/application/notification_providers.dart';
import 'package:nextlook/features/home/presentation/home_screen.dart';

void main() {
  group('BannerModel Tests', () {
    test('fromJson parses full JSON object correctly including targetProductId', () {
      final json = {
        'id': 'b-1',
        'imageUrl': 'https://res.cloudinary.com/test/banner.jpg',
        'title': 'Summer Sale 50%',
        'subtitle': 'Selected shirts & shorts',
        'buttonText': 'Shop Summer',
        'categorySlug': 'men',
        'targetProductId': 'p-100',
        'sortOrder': 2,
      };

      final banner = BannerModel.fromJson(json);

      expect(banner.id, 'b-1');
      expect(banner.imageUrl, 'https://res.cloudinary.com/test/banner.jpg');
      expect(banner.title, 'Summer Sale 50%');
      expect(banner.subtitle, 'Selected shirts & shorts');
      expect(banner.buttonText, 'Shop Summer');
      expect(banner.categorySlug, 'men');
      expect(banner.targetProductId, 'p-100');
      expect(banner.sortOrder, 2);
    });

    test('fromJson handles null optional fields gracefully', () {
      final json = {
        'id': 'b-2',
        'imageUrl': 'https://res.cloudinary.com/test/banner2.jpg',
        'title': 'New Collection',
      };

      final banner = BannerModel.fromJson(json);

      expect(banner.id, 'b-2');
      expect(banner.title, 'New Collection');
      expect(banner.subtitle, isNull);
      expect(banner.buttonText, isNull);
      expect(banner.categorySlug, isNull);
      expect(banner.targetProductId, isNull);
      expect(banner.sortOrder, 0);
    });
  });

  group('HomeScreen Banner Slider Integration Widget Tests', () {
    final mockCategories = <Category>[
      const Category(id: 'c-1', name: 'Men', slug: 'men', iconName: 'men', productCount: 12),
    ];

    const mockHomeSections = HomeSections(
      flashSale: [],
      newArrivals: [],
      trending: [],
      bestSellers: [],
    );

    testWidgets('Navigates directly to product detail screen when targetProductId is set', (tester) async {
      final mockBanners = [
        const BannerModel(
          id: 'b-product',
          imageUrl: 'https://via.placeholder.com/600x300',
          title: 'Featured Leather Jacket',
          buttonText: 'Buy Jacket',
          targetProductId: 'prod-jacket-123',
          sortOrder: 1,
        ),
      ];

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) => Scaffold(
              body: Text('Product Detail Screen: ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bannersProvider.overrideWith((ref) async => mockBanners),
            categoriesProvider.overrideWith((ref) async => mockCategories),
            homeSectionsProvider.overrideWith((ref) async => mockHomeSections),
            unreadNotificationCountProvider.overrideWith((ref) => 0),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Featured Leather Jacket'), findsOneWidget);

      await tester.tap(find.text('Buy Jacket'));
      await tester.pumpAndSettle();

      expect(find.text('Product Detail Screen: prod-jacket-123'), findsOneWidget);
    });

    testWidgets('Renders real banners when bannersProvider has data', (tester) async {
      final mockBanners = [
        const BannerModel(
          id: 'b-1',
          imageUrl: 'https://via.placeholder.com/600x300',
          title: 'Special Discount 50%',
          subtitle: 'Limited seasonal items',
          buttonText: 'Claim Discount',
          categorySlug: 'men',
          sortOrder: 1,
        ),
        const BannerModel(
          id: 'b-2',
          imageUrl: 'https://via.placeholder.com/600x300',
          title: 'New Winter Collection',
          buttonText: 'Explore Winter',
          sortOrder: 2,
        ),
      ];

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/categories/:slug/products',
            builder: (context, state) => Scaffold(
              body: Text('Category Products Screen: ${state.pathParameters['slug']}'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bannersProvider.overrideWith((ref) async => mockBanners),
            categoriesProvider.overrideWith((ref) async => mockCategories),
            homeSectionsProvider.overrideWith((ref) async => mockHomeSections),
            unreadNotificationCountProvider.overrideWith((ref) => 0),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirm first banner title and CTA button text are rendered
      expect(find.text('Special Discount 50%'), findsOneWidget);
      expect(find.text('Limited seasonal items'), findsOneWidget);
      expect(find.text('Claim Discount'), findsOneWidget);

      // Tap CTA button -> should navigate to category products /categories/men/products
      await tester.tap(find.text('Claim Discount'));
      await tester.pumpAndSettle();

      expect(find.text('Category Products Screen: men'), findsOneWidget);
    });

    testWidgets('Gracefully hides banner section when bannersProvider is empty list', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bannersProvider.overrideWith((ref) async => <BannerModel>[]),
            categoriesProvider.overrideWith((ref) async => mockCategories),
            homeSectionsProvider.overrideWith((ref) async => mockHomeSections),
            unreadNotificationCountProvider.overrideWith((ref) => 0),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Banner slider should be hidden completely without error
      expect(find.byKey(const Key('home_banner_slider')), findsNothing);
      expect(find.text('Categories'), findsOneWidget);
    });
  });
}
