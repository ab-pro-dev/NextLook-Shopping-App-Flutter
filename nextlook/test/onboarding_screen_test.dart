import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextlook/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders Skip and Next buttons, then Finish on last screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify Skip button on Screen 1
    expect(find.text('Skip'), findsOneWidget);

    // Verify Next button on Screen 1
    expect(find.text('Next'), findsOneWidget);

    // Tap Next to navigate to Screen 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify Next button on Screen 2
    expect(find.text('Next'), findsOneWidget);

    // Tap Next to navigate to Screen 3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify Finish button on Screen 3
    expect(find.text('Finish'), findsOneWidget);
  });
}
