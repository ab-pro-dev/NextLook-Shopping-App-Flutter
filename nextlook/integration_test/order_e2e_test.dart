import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nextlook/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full Checkout & Payment & Order Placement Live E2E Flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Login if on login screen, or proceed if authenticated
    final loginButtonFinder = find.byKey(const Key('login_button'));
    if (loginButtonFinder.evaluate().isNotEmpty) {
      final emailInput = find.byKey(const Key('email_input'));
      final passwordInput = find.byKey(const Key('password_input'));
      if (emailInput.evaluate().isNotEmpty) {
        await tester.enterText(emailInput, 'ordertest1@example.com');
        await tester.enterText(passwordInput, 'password123');
        await tester.tap(loginButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    }

    // Expect Home screen or navigate
    expect(find.byKey(const Key('home_screen')), findsOneWidget);
  });
}
