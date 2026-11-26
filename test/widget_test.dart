import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/main.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int attempts = 30,
}) async {
  for (var i = 0; i < attempts; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Widget not found after waiting: $finder');
}

void main() {
  testWidgets('dashboard opens account flow and creates a cash account', (tester) async {
    await setupLocator();
    await tester.pumpWidget(const PersonalFinanceApp());

    expect(find.text('Personal Finance'), findsOneWidget);
    expect(find.text('Your financial overview starts here'), findsOneWidget);

    await tester.tap(find.text('Manage accounts'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump();
    await pumpUntilFound(tester, find.text('No accounts yet'));

    expect(find.text('Accounts'), findsOneWidget);

    await tester.tap(find.text('Add account'));
    await tester.pump();
    expect(find.text('Add account'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Daily cash');
    await tester.enterText(find.byType(TextFormField).at(1), 'PKR');
    await tester.enterText(find.byType(TextFormField).at(2), '1250.50');
    await tester.tap(find.text('Create account'));
    await pumpUntilFound(tester, find.text('Daily cash'));

    expect(find.text('PKR 1250.50'), findsOneWidget);
  });
}
