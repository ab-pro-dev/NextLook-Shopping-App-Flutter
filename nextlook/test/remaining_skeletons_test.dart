import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/core/widgets/skeleton/address_card_skeleton.dart';
import 'package:nextlook/core/widgets/skeleton/product_list_row_skeleton.dart';
import 'package:nextlook/features/address/application/address_providers.dart';
import 'package:nextlook/features/address/data/address_model.dart';
import 'package:nextlook/features/address/presentation/addresses_screen.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/user_model.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';
import 'package:nextlook/features/cart/application/cart_providers.dart';
import 'package:nextlook/features/cart/data/cart_models.dart';
import 'package:nextlook/features/cart/presentation/cart_screen.dart';
import 'package:nextlook/features/notifications/application/notification_providers.dart';
import 'package:nextlook/features/notifications/data/notification_model.dart';
import 'package:nextlook/features/notifications/presentation/notifications_screen.dart';
import 'package:nextlook/features/notifications/presentation/widgets/notification_skeletons.dart';
import 'package:nextlook/features/orders/application/order_providers.dart';
import 'package:nextlook/features/orders/data/order_model.dart';
import 'package:nextlook/features/orders/presentation/orders_list_screen.dart';
import 'package:nextlook/features/orders/presentation/order_tracking_screen.dart';
import 'package:nextlook/features/orders/presentation/widgets/order_skeletons.dart';
import 'package:nextlook/features/wishlist/application/wishlist_providers.dart';
import 'package:nextlook/features/wishlist/presentation/wishlist_screen.dart';

class FakeTestAuthController extends AuthController {
  FakeTestAuthController(AuthState initialState) : super(FakeTestAuthRepository()) {
    state = initialState;
  }
}

class FakeTestAuthRepository extends AuthRepository {}

const testUser = User(
  id: 'usr-1',
  email: 'user@example.com',
  name: 'John Doe',
);

void main() {
  group('Remaining App Screens Skeleton Loading Tests', () {
    testWidgets('CartScreen renders ProductListRowsSkeleton when cart is loading', (tester) async {
      final completer = Completer<CartSummary>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            cartProvider.overrideWith(() => FakeCartNotifier(completer.future)),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ProductListRowsSkeleton), findsOneWidget);
    });

    testWidgets('WishlistScreen renders ProductListRowsSkeleton when loading', (tester) async {
      final completer = Completer<WishlistState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            wishlistNotifierProvider.overrideWith(() => FakeWishlistNotifier(completer.future)),
          ],
          child: const MaterialApp(
            home: WishlistScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ProductListRowsSkeleton), findsOneWidget);
    });

    testWidgets('OrdersListScreen renders OrdersListSkeleton when loading', (tester) async {
      final completer = Completer<List<OrderSummary>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            ordersListProvider.overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: OrdersListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(OrdersListSkeleton), findsOneWidget);
    });

    testWidgets('OrderTrackingScreen renders OrderTrackingSkeleton when loading', (tester) async {
      final completer = Completer<OrderDetail>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            orderDetailProvider('ord-123').overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: OrderTrackingScreen(orderId: 'ord-123'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(OrderTrackingSkeleton), findsOneWidget);
    });

    testWidgets('NotificationsScreen renders NotificationsListSkeleton when loading', (tester) async {
      final completer = Completer<List<AppNotification>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            notificationsNotifierProvider.overrideWith(() => FakeNotificationsNotifier(completer.future)),
          ],
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(NotificationsListSkeleton), findsOneWidget);
    });

    testWidgets('AddressesScreen renders AddressListSkeleton when loading', (tester) async {
      final completer = Completer<List<Address>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(() => FakeAddressListNotifier(completer.future)),
          ],
          child: const MaterialApp(
            home: AddressesScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AddressListSkeleton), findsOneWidget);
    });
  });
}

class FakeCartNotifier extends CartNotifier {
  final Future<CartSummary> _future;
  FakeCartNotifier(this._future);

  @override
  Future<CartSummary> build() => _future;
}

class FakeWishlistNotifier extends WishlistNotifier {
  final Future<WishlistState> _future;
  FakeWishlistNotifier(this._future);

  @override
  Future<WishlistState> build() => _future;
}

class FakeNotificationsNotifier extends NotificationsNotifier {
  final Future<List<AppNotification>> _future;
  FakeNotificationsNotifier(this._future);

  @override
  Future<List<AppNotification>> build() => _future;
}

class FakeAddressListNotifier extends AddressListNotifier {
  final Future<List<Address>> _future;
  FakeAddressListNotifier(this._future);

  @override
  Future<List<Address>> build() => _future;
}
