import '../../../core/network/dio_client.dart';
import 'store_settings.dart';

class SettingsRepository {
  final DioClient _dioClient;

  SettingsRepository(this._dioClient);

  /// Fetch public StoreSettings via GET /api/settings
  Future<StoreSettings> getSettings() async {
    final response = await _dioClient.get('/api/settings');
    final data = response.data as Map<String, dynamic>;
    return StoreSettings.fromJson(data);
  }
}
