import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/shell_scaffold.dart';
import 'features/auth/application/auth_providers.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/products/categories_screen.dart';
import 'features/wishlist/wishlist_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/profile/profile_screen.dart';

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
      final isUnauth = authState is AuthUnauthenticated;

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      final isProtectedRoute = state.matchedLocation == '/home' ||
          state.matchedLocation == '/categories' ||
          state.matchedLocation == '/wishlist' ||
          state.matchedLocation == '/cart' ||
          state.matchedLocation == '/profile';

      // Redirect authenticated users away from login/register back to home
      if (isAuth && isAuthRoute) {
        return '/home';
      }

      // Redirect unauthenticated users trying to access protected shell routes to login
      if (isUnauth && isProtectedRoute) {
        return '/login';
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
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Placeholder routes for Search, Category Products, and Product Detail
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
          return Scaffold(
            appBar: AppBar(title: Text('Category: $slug', style: GoogleFonts.poppins())),
            body: Center(
              child: Text(
                'Category Products Screen Placeholder ($slug)',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/categories/:slug/products',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return Scaffold(
            appBar: AppBar(title: Text('Category: $slug', style: GoogleFonts.poppins())),
            body: Center(
              child: Text(
                'Category Products Screen Placeholder ($slug)',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return Scaffold(
            appBar: AppBar(title: Text('Product Detail', style: GoogleFonts.poppins())),
            body: Center(
              child: Text(
                'Product Detail Screen Placeholder\nProduct ID: $id',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          );
        },
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
