import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';
import 'package:nextlook/features/wishlist/presentation/wishlist_screen.dart';
import 'package:nextlook/features/wishlist/application/wishlist_providers.dart';
import 'package:nextlook/features/cart/presentation/cart_screen.dart';
import 'package:nextlook/features/profile/profile_screen.dart';
import 'package:nextlook/core/widgets/product_card.dart';
import 'package:nextlook/features/products/data/product_card_model.dart';
import 'package:nextlook/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeGuestAuthController extends AuthController {
  FakeGuestAuthController() : super(FakeGuestAuthRepository()) {
    state = const AuthUnauthenticated();
  }
}

class FakeGuestAuthRepository extends AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleProduct = ProductCard(
    id: 'prod-1',
    name: 'Unisex Denim Jacket',
    brand: 'UrbanStyle',
    price: 3200,
    discountPrice: 2800,
    rating: 4.8,
    reviewCount: 42,
    thumbnailUrl: null,
    isFlashSale: true,
  );

  group('Guest Access & Auth Guard Widget Tests', () {
    testWidgets('WishlistScreen shows wishlist for guest user (no sign-in guard)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeGuestAuthController()),
          ],
          child: const MaterialApp(
            home: WishlistScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('Your wishlist is empty'), findsOneWidget);
      expect(find.text('Sign In Required'), findsNothing);
    });

    testWidgets('CartScreen shows cart for guest user (no sign-in guard)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeGuestAuthController()),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Sign In Required'), findsNothing);
    });

    testWidgets('ProfileScreen shows SignInRequiredView for guest user', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeGuestAuthController()),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign In Required'), findsOneWidget);
      expect(find.text('Sign in to manage your profile, addresses, and account settings.'), findsOneWidget);
      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
    });

    testWidgets('ProductCard heart tap toggles wishlist for guest without sign-in modal', (tester) async {
      SharedPreferences.setMockInitialValues({});
      late ProviderContainer container;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container = ProviderContainer(
            overrides: [
              authControllerProvider.overrideWith((ref) => FakeGuestAuthController()),
            ],
          ),
          child: const MaterialApp(
            home: Scaffold(
              body: ProductCardWidget(product: sampleProduct),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final heartBtn = find.byKey(const Key('product_card_heart_prod-1'));
      expect(heartBtn, findsOneWidget);

      await tester.tap(heartBtn);
      await tester.pumpAndSettle();

      // Modal bottom sheet should NOT pop up
      expect(find.text('Sign In Required'), findsNothing);
      expect(find.byKey(const Key('google_sign_in_modal_button')), findsNothing);

      // Wishlist state should have prod-1
      final wishlistState = container.read(wishlistNotifierProvider).valueOrNull;
      expect(wishlistState?.isWishlisted('prod-1'), isTrue);
    });

    testWidgets('OnboardingScreen Skip tap marks onboarding seen and routes to /home', (tester) async {
      SharedPreferences.setMockInitialValues({});
      String? navigatedRoute;

      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              navigatedRoute = '/home';
              return const Scaffold(body: Text('Home Screen'));
            },
          ),
          GoRoute(
            path: '/sign-in',
            builder: (context, state) {
              navigatedRoute = '/sign-in';
              return const Scaffold(body: Text('Sign In Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Tap Get Started to enter onboarding slides
      await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
      await tester.pumpAndSettle();

      // Tap Skip button
      final skipBtn = find.byKey(const Key('onboarding_skip_button'));
      expect(skipBtn, findsOneWidget);
      await tester.tap(skipBtn);
      await tester.pumpAndSettle();

      print('[Console Onboarding Test]: Skip tap navigated to: $navigatedRoute');
      expect(navigatedRoute, equals('/home'));
    });

    testWidgets('OnboardingScreen Next flow completion marks onboarding seen and routes to /home', (tester) async {
      SharedPreferences.setMockInitialValues({});
      String? navigatedRoute;

      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              navigatedRoute = '/home';
              return const Scaffold(body: Text('Home Screen'));
            },
          ),
          GoRoute(
            path: '/sign-in',
            builder: (context, state) {
              navigatedRoute = '/sign-in';
              return const Scaffold(body: Text('Sign In Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Tap Get Started
      await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
      await tester.pumpAndSettle();

      // Tap Next on slide 1
      await tester.tap(find.byKey(const Key('onboarding_action_button')));
      await tester.pumpAndSettle();

      // Tap Next on slide 2
      await tester.tap(find.byKey(const Key('onboarding_action_button')));
      await tester.pumpAndSettle();

      // Tap Finish on final slide
      await tester.tap(find.byKey(const Key('onboarding_action_button')));
      await tester.pumpAndSettle();

      print('[Console Onboarding Test]: Final slide tap navigated to: $navigatedRoute');
      expect(navigatedRoute, equals('/home'));
    });
  });
}
