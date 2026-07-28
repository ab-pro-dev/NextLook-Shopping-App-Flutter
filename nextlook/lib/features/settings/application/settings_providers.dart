import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../data/settings_repository.dart';
import '../data/store_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SettingsRepository(dioClient);
});

final storeSettingsProvider = FutureProvider<StoreSettings>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getSettings();
});
