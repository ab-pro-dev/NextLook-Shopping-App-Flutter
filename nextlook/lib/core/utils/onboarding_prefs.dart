import 'package:shared_preferences/shared_preferences.dart';

/// Helper for tracking whether the user has completed or viewed onboarding screens.
class OnboardingPrefs {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  final SharedPreferences? _prefs;

  OnboardingPrefs([this._prefs]);

  /// Returns true if onboarding has been seen, false otherwise.
  Future<bool> hasSeenOnboarding() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Marks onboarding as seen in SharedPreferences.
  Future<void> markOnboardingSeen() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }
}
