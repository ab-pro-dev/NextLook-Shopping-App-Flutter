import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/core/theme/app_theme.dart';
import 'package:nextlook/features/checkout/presentation/checkout_screen.dart';
import 'package:nextlook/features/checkout/application/checkout_providers.dart';
import 'package:nextlook/features/orders/presentation/order_success_screen.dart';
import 'package:nextlook/features/orders/application/order_providers.dart';
import 'package:nextlook/features/orders/data/order_repository.dart';
import 'package:nextlook/features/orders/data/order_model.dart';
import 'package:nextlook/features/address/application/address_providers.dart';
import 'package:nextlook/features/address/data/address_model.dart';
import 'package:nextlook/features/cart/application/cart_providers.dart';
import 'package:nextlook/features/cart/data/cart_models.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ScreenshotApp(),
    ),
  );
}

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleAddress = Address(
      id: 'addr-1',
      fullName: 'Abera Hagazi',
      phone: '+251914169551',
      addressLine1: 'Bole Road, House #402',
      city: 'Addis Ababa',
      region: 'Addis Ababa',
      country: 'Ethiopia',
      isDefault: true,
    );

    final sampleCartItem = CartItem(
      id: 'item-1',
      productId: 'prod-1',
      name: 'Classic Leather Biker Jacket',
      brand: 'NextLook',
      thumbnailUrl: 'https://picsum.photos/seed/biker-jacket-1/800/800',
      price: 10000,
      discountPrice: 7500,
      colorName: 'Black',
      sizeLabel: 'M',
      quantity: 2,
      lineTotal: 15000,
      inStock: true,
    );

    final sampleCartSummary = CartSummary(
      items: [sampleCartItem],
      subtotal: 15000,
      itemCount: 2,
    );

    return MaterialApp(
      title: 'NextLook Screenshots',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/payment',
      routes: {
        '/payment': (context) => ProviderScope(
              overrides: [
                addressListNotifierProvider.overrideWith((ref) => FakeAddressListNotifier([sampleAddress])),
                selectedCheckoutAddressProvider.overrideWith((ref) => FakeSelectedAddressNotifier(sampleAddress)),
                cartProvider.overrideWith((ref) => FakeCartNotifier(sampleCartSummary)),
                orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
              ],
              child: const PaymentContainerScreen(),
            ),
        '/order-success': (context) => const OrderSuccessScreen(
              orderNumber: 'NLERP4F5',
              orderId: '1dfb26ec-4238-4712-8912-1ae0c3c26dbe',
            ),
      },
    );
  }
}

class PaymentContainerScreen extends ConsumerWidget {
  const PaymentContainerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutSessionProvider.notifier).setStep(2);
    });
    return const CheckoutScreen();
  }
}

class FakeAddressListNotifier extends AddressListNotifier {
  final List<Address> initialAddresses;
  FakeAddressListNotifier(this.initialAddresses);

  @override
  Future<List<Address>> build() async => initialAddresses;
}

class FakeSelectedAddressNotifier extends SelectedCheckoutAddressNotifier {
  final Address? initialAddress;
  FakeSelectedAddressNotifier(this.initialAddress);

  @override
  Address? build() => initialAddress;
}

class FakeCartNotifier extends CartNotifier {
  final CartSummary summary;
  FakeCartNotifier(this.summary);

  @override
  Future<CartSummary> build() async => summary;
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
      id: '1dfb26ec-4238-4712-8912-1ae0c3c26dbe',
      userId: 'b2a7f6e8-e78b-421c-ab52-4db71fc34db9',
      orderNumber: 'NLERP4F5',
      status: 'PENDING',
      subtotal: 15000,
      shippingCost: 350,
      tax: 0,
      total: 15350,
      deliveryMethodLabel: deliveryMethodLabel,
      shippingFullName: 'Abera Hagazi',
      shippingPhone: '+251914169551',
      shippingAddressLine1: 'Bole Road, House #402',
      shippingCity: 'Addis Ababa',
      shippingRegion: 'Addis Ababa',
      shippingCountry: 'Ethiopia',
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [],
      statusHistory: [],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getOrders() async => [];

  @override
  Future<OrderModel> getOrderById(String orderId) async => throw UnimplementedError();
}
