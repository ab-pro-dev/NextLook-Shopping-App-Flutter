import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/application/auth_providers.dart';
import '../data/settings_repository.dart';
import '../data/store_settings.dart';

// --- STORE SETTINGS (BACKEND STORE CONFIG) ---
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SettingsRepository(dioClient);
});

final storeSettingsProvider = FutureProvider<StoreSettings>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getSettings();
});

// --- THEME MODE NOTIFIER ---
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefKey = 'app_theme_mode';

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'dark') {
        state = ThemeMode.dark;
      } else if (saved == 'light') {
        state = ThemeMode.light;
      } else if (saved == 'system') {
        state = ThemeMode.system;
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'light';
      if (mode == ThemeMode.dark) val = 'dark';
      if (mode == ThemeMode.system) val = 'system';
      await prefs.setString(_prefKey, val);
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// --- NOTIFICATION SETTINGS ---
class NotificationSettings {
  final bool orderUpdates;
  final bool promotions;
  final bool newArrivals;

  const NotificationSettings({
    this.orderUpdates = true,
    this.promotions = true,
    this.newArrivals = false,
  });

  NotificationSettings copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? newArrivals,
  }) {
    return NotificationSettings(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      newArrivals: newArrivals ?? this.newArrivals,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  static const _orderKey = 'notif_order_updates';
  static const _promoKey = 'notif_promotions';
  static const _newArrivalsKey = 'notif_new_arrivals';

  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = NotificationSettings(
        orderUpdates: prefs.getBool(_orderKey) ?? true,
        promotions: prefs.getBool(_promoKey) ?? true,
        newArrivals: prefs.getBool(_newArrivalsKey) ?? false,
      );
    } catch (_) {}
  }

  Future<void> toggleOrderUpdates(bool val) async {
    state = state.copyWith(orderUpdates: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orderKey, val);
  }

  Future<void> togglePromotions(bool val) async {
    state = state.copyWith(promotions: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promoKey, val);
  }

  Future<void> toggleNewArrivals(bool val) async {
    state = state.copyWith(newArrivals: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newArrivalsKey, val);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

// --- SECURITY SETTINGS ---
class SecuritySettingsNotifier extends StateNotifier<bool> {
  static const _prefKey = 'security_biometric_enabled';

  SecuritySettingsNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_prefKey) ?? false;
    } catch (_) {}
  }

  Future<void> setBiometricEnabled(bool val) async {
    state = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, val);
  }
}

final biometricSettingProvider = StateNotifierProvider<SecuritySettingsNotifier, bool>((ref) {
  return SecuritySettingsNotifier();
});

// --- CACHE SERVICE ---
class CacheService {
  Future<void> clearImageCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}
  }
}

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());
