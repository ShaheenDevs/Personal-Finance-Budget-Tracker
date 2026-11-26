import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/accounts/accounts_view.dart';

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
  late AppDatabase database;
  late LocalFinanceRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
  });

  tearDown(() async {
    await repository.close();
  });

  testWidgets('shows account balance and creates a new account', (tester) async {
    await repository.createAccount(
      name: 'Main cash',
      accountType: 'cash',
      currencyCode: 'PKR',
      openingBalanceMinorUnits: 120000,
    );

    await tester.pumpWidget(
      MaterialApp(home: AccountsView(repository: repository)),
    );
    await pumpUntilFound(tester, find.text('Main cash'));

    expect(find.text('PKR 1200.00'), findsOneWidget);

    await tester.tap(find.text('Add account'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(0), 'Savings');
    await tester.enterText(find.byType(TextFormField).at(1), 'PKR');
    await tester.enterText(find.byType(TextFormField).at(2), '125.00');
    await tester.tap(find.text('Create account'));
    await pumpUntilFound(tester, find.text('Savings'));

    expect(find.text('PKR 125.00'), findsOneWidget);
  });

  testWidgets('archives an account while retaining it in the account list', (tester) async {
    await repository.createAccount(
      name: 'Old wallet',
      accountType: 'wallet',
      currencyCode: 'PKR',
      openingBalanceMinorUnits: 5000,
    );

    await tester.pumpWidget(
      MaterialApp(home: AccountsView(repository: repository)),
    );
    await pumpUntilFound(tester, find.text('Old wallet'));

    await tester.tap(find.byTooltip('Account actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Archive account?'), findsOneWidget);
    await tester.tap(find.text('Archive').last);
    await pumpUntilFound(tester, find.text('Archived'));

    expect(find.text('PKR 50.00'), findsOneWidget);
    expect(find.byTooltip('Account actions'), findsNothing);
  });
}
