import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../data/address_model.dart';
import '../data/address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AddressRepository(dioClient);
});

class AddressListNotifier extends AsyncNotifier<List<Address>> {
  late final AddressRepository _repository;

  @override
  Future<List<Address>> build() async {
    final authState = ref.watch(authControllerProvider);
    if (authState is! AuthAuthenticated) {
      return [];
    }
    _repository = ref.watch(addressRepositoryProvider);
    final addresses = await _repository.getAddresses();
    return addresses;
  }

  /// Refresh address list from server
  Future<void> fetchAddresses() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAddresses());
  }

  /// Create new address and update list
  Future<Address> createAddress({
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String region,
    required String country,
    bool isDefault = false,
  }) async {
    final newAddress = await _repository.createAddress(
      fullName: fullName,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      region: region,
      country: country,
      isDefault: isDefault,
    );

    await fetchAddresses();
    return newAddress;
  }

  /// Update an existing address
  Future<Address> updateAddress({
    required String id,
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String region,
    required String country,
    bool isDefault = false,
  }) async {
    final updatedAddress = await _repository.updateAddress(
      id: id,
      fullName: fullName,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      region: region,
      country: country,
      isDefault: isDefault,
    );

    await fetchAddresses();
    return updatedAddress;
  }

  /// Delete address
  Future<void> deleteAddress(String id) async {
    await _repository.deleteAddress(id);
    await fetchAddresses();
  }

  /// Set default address
  Future<Address> setDefault(String id) async {
    final updatedAddress = await _repository.setDefault(id);
    await fetchAddresses();
    return updatedAddress;
  }
}

final addressListNotifierProvider =
    AsyncNotifierProvider<AddressListNotifier, List<Address>>(() {
  return AddressListNotifier();
});

/// Tracks the selected address for the active checkout session
class SelectedCheckoutAddressNotifier extends Notifier<Address?> {
  @override
  Address? build() {
    final addressesAsync = ref.watch(addressListNotifierProvider);
    return addressesAsync.when(
      data: (list) {
        if (list.isEmpty) return null;
        return list.firstWhere((a) => a.isDefault, orElse: () => list.first);
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  void selectAddress(Address address) {
    state = address;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedCheckoutAddressProvider =
    NotifierProvider<SelectedCheckoutAddressNotifier, Address?>(() {
  return SelectedCheckoutAddressNotifier();
});
