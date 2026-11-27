import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/budgets/budgets_view.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int attempts = 40,
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

  tearDown(() async => repository.close());

  testWidgets('creates a monthly budget and recurring expense schedule', (tester) async {
    await repository.createAccount(
      name: 'Main cash',
      accountType: 'cash',
      currencyCode: 'PKR',
    );
    await tester.pumpWidget(
      MaterialApp(home: BudgetsView(repository: repository)),
    );
    await pumpUntilFound(tester, find.text('Budgets'));

    await tester.tap(find.text('Add budget'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '500.00');
    await tester.tap(find.text('Save'));
    await pumpUntilFound(tester, find.text('All expenses'));
    expect(find.textContaining('PKR 500.00'), findsOneWidget);

    await tester.tap(find.text('Add schedule'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '75.00');
    await tester.tap(find.text('Save'));
    await pumpUntilFound(tester, find.text('Expense'));
    expect(find.textContaining('Monthly · Main cash'), findsOneWidget);

    final budgets = await repository.getBudgets();
    final recurring = await repository.getRecurringTransactions();
    expect(budgets, hasLength(1));
    expect(recurring, hasLength(1));
    expect(recurring.single.amountMinorUnits, 7500);
  });
}
