import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nextlook/features/profile/profile_screen.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/user_model.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';

class FakeTestAuthController extends AuthController {
  bool logoutCalled = false;

  FakeTestAuthController(AuthState initialState) : super(FakeTestAuthRepository()) {
    state = initialState;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = const AuthUnauthenticated();
  }
}

class FakeTestAuthRepository extends AuthRepository {}

const testUser = User(
  id: 'user-123',
  email: 'alex.johnson@example.com',
  name: 'Alex Johnson',
  avatarUrl: 'https://lh3.googleusercontent.com/a/example_avatar.png',
);

void main() {
  group('ProfileScreen Widget Tests', () {
    testWidgets('Renders SignInRequiredView when unauthenticated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthUnauthenticated())),
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

    testWidgets('Renders header with user info and 6 account option rows when authenticated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header info
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('alex.johnson@example.com'), findsOneWidget);

      // Account Options
      expect(find.text('Account Options'), findsOneWidget);
      expect(find.byKey(const Key('profile_edit_profile_tile')), findsOneWidget);
      expect(find.byKey(const Key('profile_my_addresses_tile')), findsOneWidget);
      expect(find.byKey(const Key('profile_my_orders_tile')), findsOneWidget);
      expect(find.byKey(const Key('profile_wishlist_tile')), findsOneWidget);
      expect(find.byKey(const Key('profile_notifications_tile')), findsOneWidget);
      expect(find.byKey(const Key('profile_settings_tile')), findsOneWidget);
      expect(find.byKey(const Key('profile_logout_button')), findsOneWidget);
    });

    testWidgets('Account option rows navigate to correct routes', (tester) async {
      String? lastNavigatedRoute;

      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(
            path: '/profile/edit',
            builder: (context, state) {
              lastNavigatedRoute = '/profile/edit';
              return const Scaffold(body: Text('Edit Profile Page'));
            },
          ),
          GoRoute(
            path: '/addresses',
            builder: (context, state) {
              lastNavigatedRoute = '/addresses';
              return const Scaffold(body: Text('My Addresses Page'));
            },
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) {
              lastNavigatedRoute = '/orders';
              return const Scaffold(body: Text('My Orders Page'));
            },
          ),
          GoRoute(
            path: '/wishlist',
            builder: (context, state) {
              lastNavigatedRoute = '/wishlist';
              return const Scaffold(body: Text('Wishlist Page'));
            },
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) {
              lastNavigatedRoute = '/notifications';
              return const Scaffold(body: Text('Notifications Page'));
            },
          ),
          GoRoute(
            path: '/settings-mobile',
            builder: (context, state) {
              lastNavigatedRoute = '/settings-mobile';
              return const Scaffold(body: Text('Settings Page'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Edit Profile
      await tester.tap(find.byKey(const Key('profile_edit_profile_tile')));
      await tester.pumpAndSettle();
      expect(lastNavigatedRoute, equals('/profile/edit'));

      // Pop back to profile
      router.go('/profile');
      await tester.pumpAndSettle();

      // Tap My Addresses
      await tester.tap(find.byKey(const Key('profile_my_addresses_tile')));
      await tester.pumpAndSettle();
      expect(lastNavigatedRoute, equals('/addresses'));

      // Pop back
      router.go('/profile');
      await tester.pumpAndSettle();

      // Tap My Orders
      await tester.tap(find.byKey(const Key('profile_my_orders_tile')));
      await tester.pumpAndSettle();
      expect(lastNavigatedRoute, equals('/orders'));

      // Pop back
      router.go('/profile');
      await tester.pumpAndSettle();

      // Tap Wishlist
      await tester.tap(find.byKey(const Key('profile_wishlist_tile')));
      await tester.pumpAndSettle();
      expect(lastNavigatedRoute, equals('/wishlist'));

      // Pop back
      router.go('/profile');
      await tester.pumpAndSettle();

      // Tap Notifications
      await tester.tap(find.byKey(const Key('profile_notifications_tile')));
      await tester.pumpAndSettle();
      expect(lastNavigatedRoute, equals('/notifications'));

      // Pop back
      router.go('/profile');
      await tester.pumpAndSettle();

      // Tap Settings
      await tester.tap(find.byKey(const Key('profile_settings_tile')));
      await tester.pumpAndSettle();
      expect(lastNavigatedRoute, equals('/settings-mobile'));
    });

    testWidgets('Tapping Log Out calls logout() on AuthController', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      late FakeTestAuthController fakeAuth;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) {
              fakeAuth = FakeTestAuthController(const AuthAuthenticated(testUser));
              return fakeAuth;
            }),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final logoutBtn = find.byKey(const Key('profile_logout_button'));
      expect(logoutBtn, findsOneWidget);
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(fakeAuth.logoutCalled, isTrue);
    });
  });
}
