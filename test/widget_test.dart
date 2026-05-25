import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluffy/main.dart';

void main() {
  testWidgets('Pluffy App boots successfully and shows splash branding', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PluffyApp(),
      ),
    );

    // Verify that the splash screen branding elements are visible
    expect(find.text('PLUFFY'), findsOneWidget);
    expect(find.text('Premium Japanese Dessert Café'), findsOneWidget);
    expect(find.text('Warm Premium Experience'), findsOneWidget);

    // Drain the splash screen navigation timer so no timers are left pending
    await tester.pump(const Duration(seconds: 3));
  });
}
