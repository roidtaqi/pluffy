import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pluffy/src/app.dart';

void main() {
  testWidgets('Pluffy app has a title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final titleFinder = find.text('Pluffy');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Menu screen is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final menuButtonFinder = find.byKey(const ValueKey('menuButton'));
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(MenuScreen), findsOneWidget);
  });

  testWidgets('Cart screen is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final cartButtonFinder = find.byKey(const ValueKey('cartButton'));
    await tester.tap(cartButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(CartScreen), findsOneWidget);
  });
}