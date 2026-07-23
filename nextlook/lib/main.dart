import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/shell_scaffold.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/products/categories_screen.dart';
import 'features/wishlist/wishlist_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/profile/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          key: Key('login_screen_placeholder'),
          body: Center(child: Text('Login Screen Placeholder')),
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/categories',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CategoriesScreen(),
            ),
          ),
          GoRoute(
            path: '/wishlist',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WishlistScreen(),
            ),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

void main() {
  runApp(
    const ProviderScope(
      child: NextLookApp(),
    ),
  );
}

class NextLookApp extends ConsumerWidget {
  const NextLookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'StyleHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
