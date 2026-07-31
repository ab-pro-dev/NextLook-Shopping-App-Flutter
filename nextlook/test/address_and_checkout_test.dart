import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/address/data/address_model.dart';
import 'package:nextlook/features/address/application/address_providers.dart';
import 'package:nextlook/features/checkout/presentation/checkout_screen.dart';
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
  group('Address Model Tests', () {
    test('Address.fromJson parses correctly', () {
      final json = {
        'id': 'addr-123',
        'fullName': 'Jane Doe',
        'phone': '+15551234567',
        'addressLine1': '742 Evergreen Terrace',
        'addressLine2': 'Apt 4B',
        'city': 'Springfield',
        'region': 'OR',
        'country': 'United States',
        'isDefault': true,
        'createdAt': '2026-07-26T00:00:00.000Z',
      };

      final address = Address.fromJson(json);

      expect(address.id, equals('addr-123'));
      expect(address.fullName, equals('Jane Doe'));
      expect(address.phone, equals('+15551234567'));
      expect(address.addressLine1, equals('742 Evergreen Terrace'));
      expect(address.addressLine2, equals('Apt 4B'));
      expect(address.city, equals('Springfield'));
      expect(address.region, equals('OR'));
      expect(address.country, equals('United States'));
      expect(address.isDefault, isTrue);
      expect(address.formattedAddress, equals('742 Evergreen Terrace, Apt 4B, Springfield, OR, United States'));
    });

    test('Address.toJson produces expected map', () {
      const address = Address(
        id: 'addr-1',
        fullName: 'John Smith',
        phone: '1234567890',
        addressLine1: '100 Main St',
        city: 'Metropolis',
        region: 'NY',
        country: 'USA',
        isDefault: false,
      );

      final json = address.toJson();

      expect(json['id'], equals('addr-1'));
      expect(json['fullName'], equals('John Smith'));
      expect(json['isDefault'], isFalse);
    });
  });

  group('SelectedCheckoutAddressNotifier Tests', () {
    test('Defaults to address marked as default', () async {
      const addr1 = Address(
        id: '1',
        fullName: 'A1',
        phone: '1',
        addressLine1: 'L1',
        city: 'C1',
        region: 'R1',
        country: 'US',
        isDefault: false,
      );
      const addr2 = Address(
        id: '2',
        fullName: 'A2',
        phone: '2',
        addressLine1: 'L2',
        city: 'C2',
        region: 'R2',
        country: 'US',
        isDefault: true,
      );

      final container = ProviderContainer(
        overrides: [
          addressListNotifierProvider.overrideWith(() => FakeAddressListNotifier([addr1, addr2])),
        ],
      );

      await container.read(addressListNotifierProvider.future);

      final selected = container.read(selectedCheckoutAddressProvider);
      expect(selected, isNotNull);
      expect(selected!.id, equals('2'));
    });
  });

  group('CheckoutScreen Widget Tests', () {
    testWidgets('Renders 4-step progress indicator and Address step', (tester) async {
      const defaultAddr = Address(
        id: 'addr-default',
        fullName: 'Alex Johnson',
        phone: '+1 555 987 6543',
        addressLine1: '500 Market St',
        city: 'San Francisco',
        region: 'CA',
        country: 'United States',
        isDefault: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(
              () => FakeAddressListNotifier([defaultAddr]),
            ),
            selectedCheckoutAddressProvider.overrideWith(
              () => FakeSelectedAddressNotifier(defaultAddr),
            ),
          ],
          child: const MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Checkout'), findsOneWidget);

      // Verify 4-step progress bar
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);

      // Verify Selected Address Card
      expect(find.text('Shipping Address'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);

      // Verify Continue button exists
      expect(find.byKey(const Key('checkout_continue_button')), findsOneWidget);
    });

    testWidgets('Tapping Continue advances to Delivery step', (tester) async {
      const defaultAddr = Address(
        id: 'addr-default',
        fullName: 'Alex Johnson',
        phone: '+1 555 987 6543',
        addressLine1: '500 Market St',
        city: 'San Francisco',
        region: 'CA',
        country: 'United States',
        isDefault: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(
              () => FakeAddressListNotifier([defaultAddr]),
            ),
            selectedCheckoutAddressProvider.overrideWith(
              () => FakeSelectedAddressNotifier(defaultAddr),
            ),
            storeSettingsProvider.overrideWith(
              (ref) async => const StoreSettings(
                id: 'settings-1',
                standardDeliveryLabel: 'Standard Delivery',
                standardDeliveryDays: '3-5 days',
                standardDeliveryPrice: 150.0,
                expressDeliveryLabel: 'Express Delivery',
                expressDeliveryDays: '1-2 days',
                expressDeliveryPrice: 350.0,
                taxRatePercent: 0.0,
              ),
            ),
          ],
          child: const MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.byKey(const Key('checkout_continue_button')));
      await tester.pumpAndSettle();

      // Verify delivery step UI is displayed
      expect(find.text('Delivery Method'), findsOneWidget);
      expect(find.text('Standard Delivery'), findsOneWidget);
      expect(find.byKey(const Key('continue_to_payment_button')), findsOneWidget);
    });

    testWidgets('Shows empty state when no addresses exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(
              () => FakeAddressListNotifier([]),
            ),
            selectedCheckoutAddressProvider.overrideWith(
              () => FakeSelectedAddressNotifier(null),
            ),
          ],
          child: const MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Shipping Address Saved'), findsOneWidget);
      expect(find.byKey(const Key('add_address_empty_button')), findsOneWidget);
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
