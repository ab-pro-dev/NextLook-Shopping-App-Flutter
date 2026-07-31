import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/address/presentation/addresses_screen.dart';
import 'package:nextlook/features/address/application/address_providers.dart';
import 'package:nextlook/features/address/data/address_model.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/user_model.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';

class FakeTestAuthController extends AuthController {
  FakeTestAuthController(AuthState initialState) : super(FakeTestAuthRepository()) {
    state = initialState;
  }
}

class FakeTestAuthRepository extends AuthRepository {}

const testUser = User(
  id: 'user-123',
  email: 'alex.johnson@example.com',
  name: 'Alex Johnson',
);

class FakeAddressListNotifier extends AddressListNotifier {
  final List<Address> initialAddresses;
  bool setDefaultCalled = false;
  bool deleteCalled = false;
  String? lastSetDefaultId;
  String? lastDeletedId;

  FakeAddressListNotifier(this.initialAddresses);

  @override
  Future<List<Address>> build() async {
    return initialAddresses;
  }

  @override
  Future<Address> setDefault(String id) async {
    setDefaultCalled = true;
    lastSetDefaultId = id;
    final updated = initialAddresses.firstWhere((a) => a.id == id).copyWith(isDefault: true);
    state = AsyncValue.data(
      initialAddresses.map((a) => a.id == id ? updated : a.copyWith(isDefault: false)).toList(),
    );
    return updated;
  }

  @override
  Future<void> deleteAddress(String id) async {
    deleteCalled = true;
    lastDeletedId = id;
    state = AsyncValue.data(initialAddresses.where((a) => a.id != id).toList());
  }
}

class FakeErrorAddressListNotifier extends AddressListNotifier {
  @override
  Future<List<Address>> build() async {
    throw Exception('Failed to fetch addresses from server');
  }
}

const sampleAddress1 = Address(
  id: 'addr-1',
  fullName: 'Alex Johnson',
  phone: '+1 555 123 4567',
  addressLine1: '123 Main St',
  city: 'New York',
  region: 'NY',
  country: 'US',
  isDefault: true,
);

const sampleAddress2 = Address(
  id: 'addr-2',
  fullName: 'Alex Johnson Office',
  phone: '+1 555 987 6543',
  addressLine1: '456 Business Blvd',
  city: 'Brooklyn',
  region: 'NY',
  country: 'US',
  isDefault: false,
);

void main() {
  group('AddressesScreen Widget Tests', () {
    testWidgets('Renders empty state when address list is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(() => FakeAddressListNotifier([])),
          ],
          child: const MaterialApp(
            home: AddressesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Shipping Addresses'), findsOneWidget);
      expect(find.text('Save your shipping addresses to speed up checkout.'), findsOneWidget);
      expect(find.byKey(const Key('add_address_empty_button')), findsOneWidget);
    });

    testWidgets('Renders address list with cards and DEFAULT badge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(() => FakeAddressListNotifier([sampleAddress1, sampleAddress2])),
          ],
          child: const MaterialApp(
            home: AddressesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Addresses'), findsOneWidget);
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('Alex Johnson Office'), findsOneWidget);
      expect(find.byKey(const Key('add_new_address_button')), findsOneWidget);
    });

    testWidgets('Tapping Set as Default calls setDefault on notifier', (tester) async {
      late FakeAddressListNotifier fakeNotifier;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(() {
              fakeNotifier = FakeAddressListNotifier([sampleAddress1, sampleAddress2]);
              return fakeNotifier;
            }),
          ],
          child: const MaterialApp(
            home: AddressesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final setDefaultBtn = find.byKey(const Key('set_default_button_addr-2'));
      expect(setDefaultBtn, findsOneWidget);

      await tester.tap(setDefaultBtn);
      await tester.pumpAndSettle();

      expect(fakeNotifier.setDefaultCalled, isTrue);
      expect(fakeNotifier.lastSetDefaultId, equals('addr-2'));
    });

    testWidgets('Tapping delete button shows confirmation dialog and confirms deletion', (tester) async {
      late FakeAddressListNotifier fakeNotifier;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(() {
              fakeNotifier = FakeAddressListNotifier([sampleAddress1, sampleAddress2]);
              return fakeNotifier;
            }),
          ],
          child: const MaterialApp(
            home: AddressesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deleteBtn = find.byKey(const Key('address_delete_button_addr-2'));
      expect(deleteBtn, findsOneWidget);

      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('Delete Address'), findsOneWidget);
      final confirmBtn = find.byKey(const Key('confirm_delete_address_button'));
      expect(confirmBtn, findsOneWidget);

      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(fakeNotifier.deleteCalled, isTrue);
      expect(fakeNotifier.lastDeletedId, equals('addr-2'));
    });

    testWidgets('Renders error state and retry button on provider error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
            addressListNotifierProvider.overrideWith(() => FakeErrorAddressListNotifier()),
          ],
          child: const MaterialApp(
            home: AddressesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load addresses'), findsOneWidget);
      expect(find.byKey(const Key('addresses_retry_button')), findsOneWidget);
    });
  });
}
