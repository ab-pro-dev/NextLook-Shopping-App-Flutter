import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/checkout/presentation/checkout_screen.dart';
import 'package:nextlook/features/checkout/application/checkout_providers.dart';
import 'package:nextlook/features/address/application/address_providers.dart';
import 'package:nextlook/features/address/data/address_model.dart';
import 'package:nextlook/features/cart/application/cart_providers.dart';
import 'package:nextlook/features/cart/data/cart_models.dart';
import 'package:nextlook/features/orders/application/order_providers.dart';
import 'package:nextlook/features/orders/data/order_repository.dart';
import 'package:nextlook/features/orders/data/order_model.dart';
import 'package:nextlook/features/orders/presentation/order_success_screen.dart';

void main() {
  final sampleAddress = Address(
    id: 'addr-1',
    fullName: 'Alex Johnson',
    phone: '+1 555 123 4567',
    addressLine1: '123 Main St',
    city: 'New York',
    region: 'NY',
    country: 'US',
    isDefault: true,
  );

  final sampleCartItem = CartItem(
    id: 'item-1',
    productId: 'prod-1',
    name: 'Classic White Sneakers',
    brand: 'KicksNation',
    thumbnailUrl: null,
    price: 4000,
    discountPrice: null,
    colorName: 'White',
    sizeLabel: 'US 10',
    quantity: 1,
    lineTotal: 4000,
    inStock: true,
  );

  final sampleCartSummary = CartSummary(
    items: [sampleCartItem],
    subtotal: 4000,
    itemCount: 1,
  );

  group('Payment Step & Order Success Screen Widget Tests', () {
    testWidgets('Payment step allows selecting payment option and advancing to Review', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            addressListNotifierProvider.overrideWith(() => FakeAddressListNotifier([sampleAddress])),
            selectedCheckoutAddressProvider.overrideWith(() => FakeSelectedAddressNotifier(sampleAddress)),
            cartProvider.overrideWith(() => FakeCartNotifier(sampleCartSummary)),
            orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
          ],
          child: const MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(CheckoutScreen)));
      container.read(checkoutSessionProvider.notifier).setStep(2); // Payment Step
      await tester.pumpAndSettle();

      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Credit / Debit Card'), findsOneWidget);
      expect(find.text('TeleBirr'), findsOneWidget);
      expect(find.text('Chapa'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);

      // Select TeleBirr
      await tester.tap(find.byKey(const Key('payment_option_telebirr')));
      await tester.pumpAndSettle();

      // Advance to Review
      final continueBtn = find.byKey(const Key('continue_to_review_button'));
      await tester.ensureVisible(continueBtn);
      await tester.pumpAndSettle();
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('TeleBirr'), findsOneWidget);
    });

    testWidgets('OrderSuccessScreen renders order number and navigation buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OrderSuccessScreen(
            orderNumber: 'NL123456',
            orderId: 'test-order-id',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.text('Your order #NL123456 has been placed.'), findsOneWidget);
      expect(find.byKey(const Key('view_orders_button')), findsOneWidget);
      expect(find.byKey(const Key('continue_shopping_button')), findsOneWidget);
    });
  });
}

class FakeAddressListNotifier extends AddressListNotifier {
  final List<Address> initialAddresses;
  FakeAddressListNotifier(this.initialAddresses);

  @override
  Future<List<Address>> build() async {
    return initialAddresses;
  }
}

class FakeSelectedAddressNotifier extends SelectedCheckoutAddressNotifier {
  final Address? initialAddress;
  FakeSelectedAddressNotifier(this.initialAddress);

  @override
  Address? build() {
    return initialAddress;
  }
}

class FakeCartNotifier extends CartNotifier {
  final CartSummary summary;
  FakeCartNotifier(this.summary);

  @override
  Future<CartSummary> build() async {
    return summary;
  }
}

class FakeOrderRepository implements OrderRepository {
  @override
  Future<OrderModel> createOrder({
    required String addressId,
    required String deliveryMethodLabel,
    required double deliveryMethodPrice,
    required String paymentMethod,
  }) async {
    return OrderModel(
      id: 'test-order-id',
      userId: 'test-user-id',
      orderNumber: 'NL123456',
      status: 'PENDING',
      subtotal: 4000,
      shippingCost: 150,
      tax: 0,
      total: 4150,
      deliveryMethodLabel: deliveryMethodLabel,
      shippingFullName: 'Alex Johnson',
      shippingPhone: '+1 555 123 4567',
      shippingAddressLine1: '123 Main St',
      shippingCity: 'New York',
      shippingRegion: 'NY',
      shippingCountry: 'US',
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [],
      statusHistory: [],
    );
  }

  @override
  Future<List<OrderSummary>> getOrders() async => [];

  @override
  Future<OrderDetail> getOrderDetail(String orderId) async => throw UnimplementedError();

  @override
  Future<OrderDetail> getOrderById(String orderId) async => throw UnimplementedError();
}
