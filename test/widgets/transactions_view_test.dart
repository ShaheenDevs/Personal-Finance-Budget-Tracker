import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/transactions/transactions_view.dart';

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

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
    await repository.createAccount(
      name: 'Main account',
      accountType: 'bank',
      currencyCode: 'PKR',
    );
  });

  tearDown(() async {
    await repository.close();
  });

  testWidgets('creates and displays a transaction from the transaction form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: TransactionsView(repository: repository)),
    );
    await pumpUntilFound(tester, find.text('No transactions yet'));

    await tester.tap(find.text('Add transaction'));
    await tester.pump();

    expect(find.text('Add transaction'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '25.50');
    await tester.enterText(find.byType(TextFormField).at(1), 'Lunch');
    await tester.tap(find.text('Save transaction'));
    await pumpUntilFound(tester, find.text('Lunch'));

    expect(find.text('-PKR 25.50'), findsOneWidget);
    expect(find.text('Main account'), findsOneWidget);
  });

  testWidgets('soft deletes a transaction after confirmation', (tester) async {
    await repository.createTransaction(
      accountId: (await repository.getAccounts()).single.id,
      transactionType: 'expense',
      amountMinorUnits: 500,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 3, 10),
      note: 'Coffee',
    );

    await tester.pumpWidget(
      MaterialApp(home: TransactionsView(repository: repository)),
    );
    await pumpUntilFound(tester, find.text('Coffee'));

    await tester.tap(find.byTooltip('Transaction actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete transaction?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await pumpUntilFound(tester, find.text('No transactions yet'));

    expect(find.text('Coffee'), findsNothing);
  });
}
