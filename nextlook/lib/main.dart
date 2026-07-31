import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/shell_scaffold.dart';
import 'features/auth/application/auth_providers.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/products/categories_screen.dart';
import 'features/products/presentation/category_products_screen.dart';
import 'features/products/presentation/product_detail_screen.dart';
import 'features/wishlist/wishlist_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/checkout/presentation/checkout_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/orders/presentation/order_success_screen.dart';
import 'features/orders/presentation/orders_list_screen.dart';
import 'features/orders/presentation/order_tracking_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) => RouterNotifier(ref));

final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuth = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/sign-in';

      // Redirect authenticated users away from /sign-in back to home
      if (isAuth && isAuthRoute) {
        return '/home';
      }

      return null;
    },
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
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),

      // Routes for Search, Category Products, and Product Detail
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final isFlashSale = state.uri.queryParameters['isFlashSale'] == 'true';
          final isNewArrival = state.uri.queryParameters['isNewArrival'] == 'true';
          final isTrending = state.uri.queryParameters['isTrending'] == 'true';
          final isBestSeller = state.uri.queryParameters['isBestSeller'] == 'true';
          String title = 'Search Products';
          if (isFlashSale) title = 'Flash Sale Products';
          if (isNewArrival) title = 'New Arrivals';
          if (isTrending) title = 'Trending Products';
          if (isBestSeller) title = 'Best Sellers';

          return Scaffold(
            appBar: AppBar(title: Text(title, style: GoogleFonts.poppins())),
            body: Center(
              child: Text(
                'Search & Filter Screen Placeholder\nQuery: ${state.uri.queryParameters}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/categories/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return CategoryProductsScreen(categorySlug: slug);
        },
      ),
      GoRoute(
        path: '/categories/:slug/products',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return CategoryProductsScreen(categorySlug: slug);
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final orderNumber = extra?['orderNumber'] as String? ?? state.uri.queryParameters['orderNumber'] ?? '';
          final orderId = extra?['orderId'] as String? ?? state.uri.queryParameters['orderId'] ?? '';
          return OrderSuccessScreen(
            orderNumber: orderNumber,
            orderId: orderId,
          );
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersListScreen(),
      ),
      GoRoute(
        path: '/orders/:id/tracking',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderTrackingScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
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
      title: 'NextLook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
