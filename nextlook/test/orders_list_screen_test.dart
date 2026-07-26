import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/orders/presentation/orders_list_screen.dart';
import 'package:nextlook/features/orders/application/order_providers.dart';
import 'package:nextlook/features/orders/data/order_model.dart';
import 'package:nextlook/features/orders/data/order_repository.dart';

void main() {
  final sampleOrders = [
    OrderSummary(
      id: 'order-1',
      orderNumber: 'NLZK6Y7L',
      status: 'PENDING',
      total: 15350,
      itemCount: 2,
      thumbnailUrl: null,
      createdAt: DateTime.now(),
    ),
    OrderSummary(
      id: 'order-2',
      orderNumber: 'NL987654',
      status: 'DELIVERED',
      total: 8000,
      itemCount: 1,
      thumbnailUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  group('OrdersListScreen Widget Tests', () {
    testWidgets('renders title, filter chips, and order cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersListProvider.overrideWith((ref) async => sampleOrders),
          ],
          child: const MaterialApp(
            home: OrdersListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('Delivered'), findsWidgets);

      expect(find.text('#NLZK6Y7L'), findsOneWidget);
      expect(find.text('#NL987654'), findsOneWidget);
      expect(find.text('ETB 15,350'), findsOneWidget);
      expect(find.text('ETB 8,000'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('filter chips filter visible orders list correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersListProvider.overrideWith((ref) async => sampleOrders),
          ],
          child: const MaterialApp(
            home: OrdersListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Processing chip
      await tester.tap(find.byKey(const Key('order_filter_chip_Processing')));
      await tester.pumpAndSettle();

      expect(find.text('#NLZK6Y7L'), findsOneWidget);
      expect(find.text('#NL987654'), findsNothing);

      // Tap Delivered chip
      await tester.tap(find.byKey(const Key('order_filter_chip_Delivered')));
      await tester.pumpAndSettle();

      expect(find.text('#NLZK6Y7L'), findsNothing);
      expect(find.text('#NL987654'), findsOneWidget);
    });

    testWidgets('renders empty state when orders list is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersListProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: OrdersListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Orders Yet'), findsOneWidget);
      expect(find.byKey(const Key('start_shopping_button')), findsOneWidget);
    });

    testWidgets('renders retry button on provider error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersListProvider.overrideWith((ref) async => throw Exception('Network error')),
          ],
          child: const MaterialApp(
            home: OrdersListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load orders'), findsOneWidget);
      expect(find.byKey(const Key('orders_retry_button')), findsOneWidget);
    });
  });
}
