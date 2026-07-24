import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextlook/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders headline, subtext, and Get Started button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify headline text
    expect(find.text('Your Style, Your Way'), findsOneWidget);

    // Verify subtext
    expect(find.text('Discover fashion that fits your personality.'), findsOneWidget);

    // Verify Get Started button
    expect(find.text('Get Started'), findsOneWidget);
  });
}
