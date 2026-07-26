import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import 'address_model.dart';

class AddressRepository {
  final DioClient _dioClient;

  AddressRepository(this._dioClient);

  /// Fetch all saved addresses for current authenticated user
  Future<List<Address>> getAddresses() async {
    final response = await _dioClient.get('/api/addresses');
    final data = response.data as Map<String, dynamic>;
    final rawList = data['addresses'] as List<dynamic>? ?? [];
    return rawList.map((item) => Address.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Create a new address
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
    final response = await _dioClient.post(
      '/api/addresses',
      data: {
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        if (addressLine2 != null && addressLine2.isNotEmpty) 'addressLine2': addressLine2,
        'city': city,
        'region': region,
        'country': country,
        'isDefault': isDefault,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return Address.fromJson(data['address'] as Map<String, dynamic>);
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
    final response = await _dioClient.put(
      '/api/addresses/$id',
      data: {
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        if (addressLine2 != null && addressLine2.isNotEmpty) 'addressLine2': addressLine2,
        'city': city,
        'region': region,
        'country': country,
        'isDefault': isDefault,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return Address.fromJson(data['address'] as Map<String, dynamic>);
  }

  /// Delete an address
  Future<void> deleteAddress(String id) async {
    await _dioClient.delete('/api/addresses/$id');
  }

  /// Set an address as the default address
  Future<Address> setDefault(String id) async {
    final response = await _dioClient.put('/api/addresses/$id/set-default');
    final data = response.data as Map<String, dynamic>;
    return Address.fromJson(data['address'] as Map<String, dynamic>);
  }
}
