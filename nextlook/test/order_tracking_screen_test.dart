import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/orders/presentation/order_tracking_screen.dart';
import 'package:nextlook/features/orders/application/order_providers.dart';
import 'package:nextlook/features/orders/data/order_model.dart';

void main() {
  final sampleDetail = OrderDetail(
    id: 'order-1',
    userId: 'user-1',
    orderNumber: 'NLZK6Y7L',
    status: 'PENDING',
    subtotal: 15000,
    shippingCost: 350,
    tax: 0,
    total: 15350,
    deliveryMethodLabel: 'Express Delivery',
    paymentMethod: 'Cash on Delivery',
    shippingFullName: 'Abera Hagazi',
    shippingPhone: '+251914169551',
    shippingAddressLine1: 'Bole Road, House #402',
    shippingCity: 'Addis Ababa',
    shippingRegion: 'Addis Ababa',
    shippingCountry: 'Ethiopia',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    items: [
      OrderItem(
        id: 'item-1',
        orderId: 'order-1',
        productId: 'prod-1',
        productName: 'Classic Leather Biker Jacket',
        productThumbnailUrl: '',
        colorName: 'Black',
        sizeLabel: 'M',
        quantity: 2,
        unitPrice: 7500,
        lineTotal: 15000,
      ),
    ],
    statusHistory: [
      OrderStatusHistory(
        id: 'hist-1',
        orderId: 'order-1',
        status: 'PENDING',
        createdAt: DateTime.now(),
      ),
    ],
  );

  group('OrderTrackingScreen Widget Tests', () {
    testWidgets('renders timeline stages and order details', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderDetailProvider('order-1').overrideWith((ref) async => sampleDetail),
          ],
          child: const MaterialApp(
            home: OrderTrackingScreen(orderId: 'order-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('#NLZK6Y7L'), findsOneWidget);
      expect(find.text('Order Confirmed'), findsOneWidget);
      expect(find.text('Packed'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      expect(find.text('Classic Leather Biker Jacket'), findsOneWidget);
      expect(find.text('Black • Size: M  •  Qty: 2'), findsOneWidget);
      expect(find.text('Abera Hagazi  (+251914169551)'), findsOneWidget);
      expect(find.text('Express Delivery'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
      expect(find.text('ETB 15,350'), findsOneWidget);
    });

    testWidgets('renders error state on 404 / invalid order ID', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderDetailProvider('fake-id').overrideWith((ref) async => throw Exception('Order not found')),
          ],
          child: const MaterialApp(
            home: OrderTrackingScreen(orderId: 'fake-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Order Not Found'), findsOneWidget);
      expect(find.byKey(const Key('back_to_orders_error_button')), findsOneWidget);
    });
  });
}
