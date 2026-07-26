import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/address/data/address_model.dart';
import 'package:nextlook/features/address/application/address_providers.dart';
import 'package:nextlook/features/cart/application/cart_providers.dart';
import 'package:nextlook/features/cart/data/cart_models.dart';
import 'package:nextlook/features/checkout/data/delivery_method.dart';
import 'package:nextlook/features/checkout/application/checkout_providers.dart';
import 'package:nextlook/features/checkout/presentation/checkout_screen.dart';
import 'package:nextlook/features/orders/application/order_providers.dart';
import 'package:nextlook/features/orders/data/order_repository.dart';
import 'package:nextlook/features/orders/data/order_model.dart';

void main() {
  group('DeliveryMethod Model Tests', () {
    test('DeliveryMethod has standard and express options', () {
      final methods = DeliveryMethod.availableMethods;
      expect(methods.length, equals(2));

      final standard = methods.firstWhere((m) => m.id == 'standard');
      expect(standard.label, equals('Standard Delivery'));
      expect(standard.price, equals(150.0));
      expect(standard.estimatedDays, equals('3-5 days'));

      final express = methods.firstWhere((m) => m.id == 'express');
      expect(express.label, equals('Express Delivery'));
      expect(express.price, equals(350.0));
      expect(express.estimatedDays, equals('1-2 days'));
    });
  });

  group('CheckoutSessionNotifier Tests', () {
    test('CheckoutSessionNotifier manages state transitions', () {
      const sampleAddress = Address(
        id: 'addr-1',
        fullName: 'Test User',
        phone: '1234567890',
        addressLine1: '123 Main St',
        city: 'City',
        region: 'ST',
        country: 'US',
        isDefault: true,
      );

      final container = ProviderContainer(
        overrides: [
          selectedCheckoutAddressProvider.overrideWith(() => FakeSelectedAddressNotifier(sampleAddress)),
        ],
      );

      final notifier = container.read(checkoutSessionProvider.notifier);
      var state = container.read(checkoutSessionProvider);

      expect(state.currentStep, equals(0));
      expect(state.selectedDeliveryMethod.id, equals('standard'));

      // Switch delivery method
      final express = DeliveryMethod.availableMethods.firstWhere((m) => m.id == 'express');
      notifier.setDeliveryMethod(express);

      state = container.read(checkoutSessionProvider);
      expect(state.selectedDeliveryMethod.id, equals('express'));
      expect(state.selectedDeliveryMethod.price, equals(350.0));

      // Advance steps
      notifier.nextStep();
      expect(container.read(checkoutSessionProvider).currentStep, equals(1));

      notifier.setStep(3);
      expect(container.read(checkoutSessionProvider).currentStep, equals(3));
    });
  });

  group('Checkout Delivery and Review Widget Tests', () {
    const sampleAddress = Address(
      id: 'addr-1',
      fullName: 'Alex Johnson',
      phone: '+1 555 123 4567',
      addressLine1: '100 Market St',
      city: 'San Francisco',
      region: 'CA',
      country: 'United States',
      isDefault: true,
    );

    final sampleCartSummary = CartSummary(
      items: [
        const CartItem(
          id: 'item-1',
          productId: 'prod-1',
          name: 'Classic White Sneakers',
          brand: 'NextStep',
          price: 5000,
          discountPrice: 4000,
          colorName: 'White',
          sizeLabel: 'US 10',
          quantity: 1,
          lineTotal: 4000,
          inStock: true,
        ),
      ],
      subtotal: 4000,
      itemCount: 1,
    );

    testWidgets('Delivery step allows changing method and advances to Payment', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            addressListNotifierProvider.overrideWith(() => FakeAddressListNotifier([sampleAddress])),
            selectedCheckoutAddressProvider.overrideWith(() => FakeSelectedAddressNotifier(sampleAddress)),
            cartProvider.overrideWith(() => FakeCartNotifier(sampleCartSummary)),
          ],
          child: const MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Continue on Address step to reach Delivery step
      await tester.tap(find.byKey(const Key('checkout_continue_button')));
      await tester.pumpAndSettle();

      // Verify Delivery options displayed
      expect(find.text('Standard Delivery'), findsOneWidget);
      expect(find.text('Express Delivery'), findsOneWidget);
      expect(find.text('ETB 150'), findsOneWidget);
      expect(find.text('ETB 350'), findsOneWidget);

      // Select Express Delivery
      await tester.tap(find.byKey(const Key('delivery_option_express')));
      await tester.pumpAndSettle();

      // Tap Continue to Payment
      await tester.tap(find.byKey(const Key('continue_to_payment_button')));
      await tester.pumpAndSettle();

      // Verify Payment step
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.byKey(const Key('continue_to_review_button')), findsOneWidget);
    });

    testWidgets('Review step displays correct items, address, delivery, total, and Edit links', (tester) async {
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

      // Advance to Review step (Step 3)
      final container = ProviderScope.containerOf(tester.element(find.byType(CheckoutScreen)));
      container.read(checkoutSessionProvider.notifier).setStep(3);
      await tester.pumpAndSettle();

      // Verify Order Summary (cart items)
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Classic White Sneakers'), findsOneWidget);
      expect(find.text('White • Size: US 10  •  Qty: 1'), findsOneWidget);

      // Verify Shipping Address Summary
      expect(find.text('Alex Johnson  (+1 555 123 4567)'), findsOneWidget);
      expect(find.byKey(const Key('edit_address_review_link')), findsOneWidget);

      // Verify Delivery Method Summary
      expect(find.text('Standard Delivery'), findsOneWidget);
      expect(find.byKey(const Key('edit_delivery_review_link')), findsOneWidget);

      // Verify Payment Method Summary
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.byKey(const Key('edit_payment_review_link')), findsOneWidget);

      // Verify Price Breakdown: Subtotal 4000 + Shipping 150 + Tax 0 = 4150
      expect(find.text('ETB 4,000'), findsWidgets);
      expect(find.text('ETB 150'), findsWidgets);
      expect(find.text('ETB 4,150'), findsOneWidget);

      // Test Edit Shipping Address link jumps back to Address step
      await tester.tap(find.byKey(const Key('edit_address_review_link')));
      await tester.pumpAndSettle();
      expect(find.text('Shipping Address'), findsOneWidget);

      // Return to Review step and test Edit Delivery Method link
      container.read(checkoutSessionProvider.notifier).setStep(3);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('edit_delivery_review_link')));
      await tester.pumpAndSettle();
      expect(find.text('Delivery Method'), findsOneWidget);

      // Return to Review step and test Edit Payment Method link
      container.read(checkoutSessionProvider.notifier).setStep(3);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('edit_payment_review_link')));
      await tester.pumpAndSettle();
      expect(find.text('Payment Method'), findsOneWidget);
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
