import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/main.dart';

void main() {
  testWidgets('dashboard opens account flow and creates a cash account', (tester) async {
    await setupLocator();
    await tester.pumpWidget(const PersonalFinanceApp());

    expect(find.text('Personal Finance'), findsOneWidget);
    expect(find.text('Your financial overview starts here'), findsOneWidget);

    await tester.tap(find.text('Manage accounts'));
    await tester.pumpAndSettle();

    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('No accounts yet'), findsOneWidget);

    await tester.tap(find.text('Add account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Daily cash');
    await tester.enterText(find.byType(TextFormField).at(1), 'PKR');
    await tester.enterText(find.byType(TextFormField).at(2), '1250.50');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Daily cash'), findsOneWidget);
    expect(find.text('PKR 1250.50'), findsOneWidget);
  });
}
