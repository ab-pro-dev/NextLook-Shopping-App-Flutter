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
import 'package:nextlook/features/settings/data/store_settings.dart';
import 'package:nextlook/features/settings/application/settings_providers.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/user_model.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';

class FakeAuthController extends AuthController {
  FakeAuthController(AuthState initialState) : super(FakeAuthRepository()) {
    state = initialState;
  }
}

class FakeAuthRepository extends AuthRepository {}

const testUser = User(id: 'u1', email: 'test@example.com', name: 'Alex Johnson');

void main() {
  const mockSettings = StoreSettings(
    id: 'settings-1',
    standardDeliveryLabel: 'Standard Delivery',
    standardDeliveryDays: '3-5 days',
    standardDeliveryPrice: 150.0,
    expressDeliveryLabel: 'Express Delivery',
    expressDeliveryDays: '1-2 days',
    expressDeliveryPrice: 350.0,
    taxRatePercent: 0.0,
  );

  group('StoreSettings Model Tests', () {
    test('StoreSettings generates standard and express options', () {
      final methods = mockSettings.deliveryMethods;
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

      // Switch delivery method
      const express = DeliveryMethod(
        id: 'express',
        label: 'Express Delivery',
        estimatedDays: '1-2 days',
        price: 350.0,
      );
      notifier.setDeliveryMethod(express);

      state = container.read(checkoutSessionProvider);
      expect(state.selectedDeliveryMethod?.id, equals('express'));
      expect(state.selectedDeliveryMethod?.price, equals(350.0));

      // Advance steps
      notifier.nextStep();
      expect(container.read(checkoutSessionProvider).currentStep, equals(1));

      notifier.setStep(3);
      expect(container.read(checkoutSessionProvider).currentStep, equals(3));
    });
  });

  group('Checkout Delivery and Review UI Tests', () {
    testWidgets('Renders Delivery options and progresses to Review', (tester) async {
      const sampleAddress = Address(
        id: 'addr-1',
        fullName: 'Alex Johnson',
        phone: '+1 555 123 4567',
        addressLine1: '123 Main St',
        city: 'New York',
        region: 'NY',
        country: 'US',
        isDefault: true,
      );

      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthAuthenticated(testUser))),
          addressListNotifierProvider.overrideWith(() => FakeAddressListNotifier([sampleAddress])),
          selectedCheckoutAddressProvider.overrideWith(() => FakeSelectedAddressNotifier(sampleAddress)),
          cartProvider.overrideWith(() => FakeCartNotifier()),
          orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
          storeSettingsProvider.overrideWith((ref) async => mockSettings),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 0: Address step -> tap continue
      expect(find.text('Shipping Address'), findsOneWidget);
      final continueAddrButton = find.byKey(const Key('checkout_continue_button'));
      expect(continueAddrButton, findsOneWidget);
      await tester.tap(continueAddrButton);
      await tester.pumpAndSettle();

      // Step 1: Delivery step -> expect options rendered
      expect(find.text('Standard Delivery'), findsWidgets);
      expect(find.text('Express Delivery'), findsWidgets);

      final continuePaymentButton = find.byKey(const Key('continue_to_payment_button'));
      expect(continuePaymentButton, findsOneWidget);
      await tester.tap(continuePaymentButton);
      await tester.pumpAndSettle();

      // Step 2: Payment step
      final continueReviewButton = find.byKey(const Key('continue_to_review_button'));
      expect(continueReviewButton, findsOneWidget);
      await tester.ensureVisible(continueReviewButton);
      await tester.tap(continueReviewButton);
      await tester.pumpAndSettle();

      // Step 3: Review step -> Place Order button exists
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.byKey(const Key('place_order_button')), findsOneWidget);
    });
  });
}

class FakeAddressListNotifier extends AddressListNotifier {
  final List<Address> _initial;
  FakeAddressListNotifier(this._initial);

  @override
  Future<List<Address>> build() async => _initial;
}

class FakeSelectedAddressNotifier extends SelectedCheckoutAddressNotifier {
  final Address? _initial;
  FakeSelectedAddressNotifier(this._initial);

  @override
  Address? build() => _initial;
}

class FakeCartNotifier extends CartNotifier {
  @override
  Future<CartSummary> build() async {
    return const CartSummary(
      items: [
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          name: 'Classic Biker Jacket',
          price: 4000.0,
          colorName: 'Black',
          sizeLabel: 'M',
          quantity: 1,
          lineTotal: 4000.0,
          inStock: true,
        ),
      ],
      itemCount: 1,
      subtotal: 4000.0,
    );
  }
}

class FakeOrderRepository implements OrderRepository {
  @override
  Future<OrderDetail> createOrder({
    required String addressId,
    required String deliveryMethod,
    required String paymentMethod,
    String? deliveryMethodLabel,
    double? deliveryMethodPrice,
  }) async {
    return OrderDetail(
      id: 'test-order-id',
      userId: 'test-user-id',
      orderNumber: 'NL123456',
      status: 'PENDING',
      subtotal: 4000,
      shippingCost: 150,
      tax: 0,
      total: 4150,
      deliveryMethodLabel: deliveryMethodLabel ?? 'Standard Delivery',
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
