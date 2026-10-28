import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';
import 'package:nextlook/features/auth/data/user_model.dart';
import 'package:nextlook/features/profile/presentation/edit_profile_screen.dart';
import 'package:nextlook/features/settings/application/settings_providers.dart';
import 'package:nextlook/features/settings/presentation/settings_screen.dart';

class MockTestAuthController extends AuthController {
  bool updateProfileCalled = false;
  String? updatedName;
  String? updatedAvatarUrl;

  MockTestAuthController(AuthState initialState) : super(MockTestAuthRepository()) {
    state = initialState;
  }

  @override
  Future<User> updateProfile({required String name, String? avatarUrl}) async {
    updateProfileCalled = true;
    updatedName = name;
    updatedAvatarUrl = avatarUrl;
    final user = (state as AuthAuthenticated).user;
    final updated = user.copyWith(name: name, avatarUrl: avatarUrl ?? user.avatarUrl);
    state = AuthAuthenticated(updated);
    return updated;
  }
}

class MockTestAuthRepository extends AuthRepository {}

const testUser = User(
  id: 'usr-123',
  email: 'sam.smith@example.com',
  name: 'Sam Smith',
  avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
);

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('Renders all setting sections and theme mode selector', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header title
      expect(find.text('Settings'), findsOneWidget);

      // Section titles
      expect(find.text('Appearance & Theme'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Security & Preferences'), findsOneWidget);
      expect(find.text('Data & Storage'), findsOneWidget);
      expect(find.text('Legal & About'), findsOneWidget);

      // Theme options
      expect(find.byKey(const Key('settings_theme_light')), findsOneWidget);
      expect(find.byKey(const Key('settings_theme_dark')), findsOneWidget);
      expect(find.byKey(const Key('settings_theme_system')), findsOneWidget);

      // Notification switches
      expect(find.byKey(const Key('settings_order_updates_switch')), findsOneWidget);
      expect(find.byKey(const Key('settings_promo_switch')), findsOneWidget);
      expect(find.byKey(const Key('settings_new_arrivals_switch')), findsOneWidget);

      // Clear cache tile
      expect(find.byKey(const Key('settings_clear_cache_tile')), findsOneWidget);

      // App version
      expect(find.text('NextLook Shopping App'), findsOneWidget);
      expect(find.text('Version 1.2.0 (Build 42)'), findsOneWidget);
    });

    testWidgets('Tapping Dark theme updates themeModeProvider state', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      final darkOption = find.byKey(const Key('settings_theme_dark'));
      await tester.tap(darkOption);
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), equals(ThemeMode.dark));
    });

    testWidgets('Toggling notification switches updates state', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final newArrivalsSwitch = find.byKey(const Key('settings_new_arrivals_switch'));
      expect(container.read(notificationSettingsProvider).newArrivals, isFalse);

      await tester.tap(newArrivalsSwitch);
      await tester.pumpAndSettle();

      expect(container.read(notificationSettingsProvider).newArrivals, isTrue);
    });
  });

  group('Profile Picture Selection in EditProfileScreen', () {
    testWidgets('Renders change photo button badge and text button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => MockTestAuthController(const AuthAuthenticated(testUser))),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('edit_profile_change_photo_button')), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_choose_photo_text_button')), findsOneWidget);
      expect(find.text('Change Profile Picture'), findsOneWidget);
    });

    testWidgets('Tapping change photo button opens bottom sheet with options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => MockTestAuthController(const AuthAuthenticated(testUser))),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final changePhotoBtn = find.byKey(const Key('edit_profile_change_photo_button'));
      await tester.tap(changePhotoBtn);
      await tester.pumpAndSettle();

      expect(find.text('Change Profile Photo'), findsOneWidget);
      expect(find.byKey(const Key('photo_option_camera')), findsOneWidget);
      expect(find.byKey(const Key('photo_option_gallery')), findsOneWidget);
      expect(find.byKey(const Key('photo_option_preset')), findsOneWidget);
    });
  });
}
