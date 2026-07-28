import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/auth/presentation/sign_in_screen.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('SignInScreen renders NextLook branding, tagline, and Google Sign-In button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    // Verify Title & Tagline
    expect(find.text('NextLook'), findsOneWidget);
    expect(find.text('Discover Your Next Look'), findsOneWidget);

    // Verify Google Sign-In Button
    final googleBtn = find.byKey(const Key('google_sign_in_button'));
    expect(googleBtn, findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('SignInScreen displays inline error banner on AuthError state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => FakeErrorAuthController(),
          ),
        ],
        child: const MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    expect(find.text('Google Sign-In failed due to network error'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });
}

class FakeErrorAuthController extends AuthController {
  FakeErrorAuthController() : super(FakeErrorRepository()) {
    state = const AuthError('Google Sign-In failed due to network error');
  }
}

class FakeErrorRepository extends AuthRepository {}
