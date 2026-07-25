import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/cart/application/cart_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class ShellTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const ShellTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}

final List<ShellTab> tabs = [
  ShellTab(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
    path: '/home',
  ),
  ShellTab(
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view,
    label: 'Categories',
    path: '/categories',
  ),
  ShellTab(
    icon: Icons.favorite_outline,
    activeIcon: Icons.favorite,
    label: 'Wishlist',
    path: '/wishlist',
  ),
  ShellTab(
    icon: Icons.shopping_bag_outlined,
    activeIcon: Icons.shopping_bag,
    label: 'Cart',
    path: '/cart',
  ),
  ShellTab(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
    path: '/profile',
  ),
];

class ShellScaffold extends ConsumerWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  int _currentIndex(String location) {
    final path = location.split('?').first;
    final index = tabs.indexWhere((t) => t.path == path);
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => context.go(tabs[index].path),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF8A8D9F),
        elevation: 8,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          color: const Color(0xFF8A8D9F),
        ),
        items: tabs.map((tab) {
          final isCartTab = tab.path == '/cart';

          Widget iconWidget = Icon(tab.icon, size: 24);
          Widget activeIconWidget = Icon(tab.activeIcon, size: 24);

          if (isCartTab && cartItemCount > 0) {
            iconWidget = Badge(
              label: Text('$cartItemCount'),
              backgroundColor: AppColors.primary,
              child: iconWidget,
            );
            activeIconWidget = Badge(
              label: Text('$cartItemCount'),
              backgroundColor: AppColors.primary,
              child: activeIconWidget,
            );
          }

          return BottomNavigationBarItem(
            icon: iconWidget,
            activeIcon: activeIconWidget,
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}
