import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';
import 'package:nextlook/features/auth/presentation/splash_screen.dart';
import 'package:nextlook/features/wishlist/presentation/wishlist_screen.dart';
import 'package:nextlook/features/cart/presentation/cart_screen.dart';
import 'package:nextlook/features/profile/profile_screen.dart';
import 'package:nextlook/core/widgets/product_card.dart';
import 'package:nextlook/features/products/data/product_card_model.dart';
import 'package:nextlook/core/utils/onboarding_prefs.dart';
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
    testWidgets('WishlistScreen shows SignInRequiredView for guest user', (tester) async {
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

      expect(find.text('Sign In Required'), findsOneWidget);
      expect(find.text('Sign in to see your wishlist and saved items.'), findsOneWidget);
      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
    });

    testWidgets('CartScreen shows SignInRequiredView for guest user', (tester) async {
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

      expect(find.text('Sign In Required'), findsOneWidget);
      expect(find.text('Sign in to see your cart and complete checkout.'), findsOneWidget);
      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
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

    testWidgets('ProductCard heart tap triggers Sign In Required modal bottom sheet for guest', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeGuestAuthController()),
          ],
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

      // Modal bottom sheet should pop up with Sign In prompt
      expect(find.text('Sign In Required'), findsOneWidget);
      expect(find.text('Sign in to add items to your wishlist.'), findsOneWidget);
      expect(find.byKey(const Key('google_sign_in_modal_button')), findsOneWidget);
    });
  });
}
