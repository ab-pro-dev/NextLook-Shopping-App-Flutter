import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nextlook/core/widgets/success_toast.dart';

void main() {
  testWidgets('AppToast displays floating top toast with title, subtitle, and action', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    bool actionTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppToast.show(
                  context,
                  title: 'Added to Cart',
                  subtitle: 'Classic Leather Biker Jacket',
                  actionLabel: 'View Cart',
                  onActionTap: () {
                    actionTapped = true;
                  },
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ),
      ),
    );

    // Tap button to show toast
    await tester.tap(find.text('Show Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Added to Cart'), findsOneWidget);
    expect(find.text('Classic Leather Biker Jacket'), findsOneWidget);
    expect(find.text('View Cart'), findsOneWidget);

    // Tap action button on toast
    await tester.tap(find.byKey(const Key('toast_action_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(actionTapped, isTrue);
  });
}
