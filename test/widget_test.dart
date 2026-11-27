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
  testWidgets('dashboard opens the account screen and add-account form', (tester) async {
    await setupLocator();
    await tester.pumpWidget(const PersonalFinanceApp());

    expect(find.text('Personal Finance'), findsOneWidget);
    await pumpUntilFound(tester, find.text('Manage accounts'));

    await tester.tap(find.text('Manage accounts'));
    await pumpUntilFound(tester, find.text('Accounts'));

    await tester.tap(find.text('Add account'));
    await tester.pump();

    expect(find.text('Account name'), findsOneWidget);
    expect(find.text('Account type'), findsOneWidget);
    expect(find.text('Currency code'), findsOneWidget);
    expect(find.text('Opening balance'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('Create account'), findsNothing);
  });
}
