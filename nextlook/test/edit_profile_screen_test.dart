import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/profile/presentation/edit_profile_screen.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/user_model.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';

class FakeTestAuthController extends AuthController {
  bool updateProfileCalled = false;
  String? lastUpdatedName;

  FakeTestAuthController(AuthState initialState) : super(FakeTestAuthRepository()) {
    state = initialState;
  }

  @override
  Future<User> updateProfile({required String name}) async {
    updateProfileCalled = true;
    lastUpdatedName = name;
    final currentUser = (state as AuthAuthenticated).user;
    final updated = currentUser.copyWith(name: name);
    state = AuthAuthenticated(updated);
    return updated;
  }
}

class FakeTestAuthRepository extends AuthRepository {}

const testUser = User(
  id: 'user-123',
  email: 'alex.johnson@example.com',
  name: 'Alex Johnson',
  avatarUrl: 'https://lh3.googleusercontent.com/a/example_avatar.png',
);

void main() {
  group('EditProfileScreen Widget Tests', () {
    testWidgets('Renders SignInRequiredView when unauthenticated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthUnauthenticated())),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign In Required'), findsOneWidget);
      expect(find.text('Sign in to manage and edit your profile.'), findsOneWidget);
    });

    testWidgets('Renders pre-filled name, disabled email field, and avatar caption', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeTestAuthController(const AuthAuthenticated(testUser))),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Profile photo is managed by your Google account'), findsOneWidget);
      expect(find.text('Email is linked to your Google account and can\'t be changed here'), findsOneWidget);

      // Name field pre-filled
      final nameFinder = find.byKey(const Key('edit_profile_name_field'));
      expect(nameFinder, findsOneWidget);
      final TextFormField nameField = tester.widget(nameFinder);
      expect(nameField.controller?.text, equals('Alex Johnson'));

      // Email field disabled
      final emailFinder = find.byKey(const Key('edit_profile_email_field'));
      expect(emailFinder, findsOneWidget);
      final TextFormField emailField = tester.widget(emailFinder);
      expect(emailField.enabled, isFalse);
      expect(emailField.controller?.text, equals('alex.johnson@example.com'));
    });

    testWidgets('Empty name shows inline error message and blocks submission', (tester) async {
      late FakeTestAuthController fakeAuth;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) {
              fakeAuth = FakeTestAuthController(const AuthAuthenticated(testUser));
              return fakeAuth;
            }),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nameFinder = find.byKey(const Key('edit_profile_name_field'));
      await tester.enterText(nameFinder, '  ');
      await tester.pumpAndSettle();

      final saveBtn = find.byKey(const Key('edit_profile_save_button'));
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Name cannot be empty'), findsWidgets);
      expect(fakeAuth.updateProfileCalled, isFalse);
    });

    testWidgets('Submitting valid name calls updateProfile and updates auth user state', (tester) async {
      late FakeTestAuthController fakeAuth;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) {
              fakeAuth = FakeTestAuthController(const AuthAuthenticated(testUser));
              return fakeAuth;
            }),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nameFinder = find.byKey(const Key('edit_profile_name_field'));
      await tester.enterText(nameFinder, 'Alex Smith');
      await tester.pumpAndSettle();

      final saveBtn = find.byKey(const Key('edit_profile_save_button'));
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(fakeAuth.updateProfileCalled, isTrue);
      expect(fakeAuth.lastUpdatedName, equals('Alex Smith'));
      expect((fakeAuth.state as AuthAuthenticated).user.name, equals('Alex Smith'));
    });
  });
}
