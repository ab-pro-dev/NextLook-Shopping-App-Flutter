import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextlook/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NextLookApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(NextLookApp), findsOneWidget);
  });
}
