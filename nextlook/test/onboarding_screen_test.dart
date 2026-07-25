import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextlook/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen flow: Splash Get Started -> Onboarding Slides (Next -> Next -> Finish)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // 1. Initial Welcome View renders Get Started button
    expect(find.text('Get Started'), findsOneWidget);

    // 2. Tap Get Started to enter 3-screen onboarding flow
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Screen 1 renders Skip and Next buttons
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // 3. Tap Next to navigate to Screen 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Next'), findsOneWidget);

    // 4. Tap Next to navigate to Screen 3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify Screen 3 renders Finish button
    expect(find.text('Finish'), findsOneWidget);
  });
}
