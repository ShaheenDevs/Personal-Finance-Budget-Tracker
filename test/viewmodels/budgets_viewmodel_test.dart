// ignore_for_file: require_trailing_commas

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/budgets/budgets_viewmodel.dart';

void main() {
  late AppDatabase database;
  late LocalFinanceRepository repository;
  late BudgetsViewModel viewModel;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
    viewModel = BudgetsViewModel(repository: repository);
  });

  tearDown(() async => repository.close());

  test('loads budget progress and category labels', () async {
    await repository.createAccount(
      name: 'Cash', accountType: 'cash', currencyCode: 'PKR');
    final account = (await repository.getAccounts()).single;
    await repository.createCategory(name: 'Food', transactionType: 'expense');
    final category = (await repository.getCategories()).single;
    await repository.createBudget(
      categoryId: category.id,
      amountMinorUnits: 10000,
      currencyCode: 'PKR',
      periodType: 'monthly',
      startDate: DateTime(2026, 3, 1),
    );
    await repository.createTransaction(
      accountId: account.id,
      categoryId: category.id,
      transactionType: 'expense',
      amountMinorUnits: 2500,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 3, 10),
    );

    await viewModel.initialise();

    expect(viewModel.budgets, hasLength(1));
    expect(viewModel.budgets.single.categoryName, 'Food');
    expect(viewModel.budgets.single.spentMinorUnits, 2500);
    expect(viewModel.budgets.single.remainingMinorUnits, 7500);
  });

  test('creates and deletes a monthly budget', () async {
    final saved = await viewModel.saveBudget(
      amountMinorUnits: 50000,
      currencyCode: 'PKR',
      periodType: 'monthly',
      startDate: DateTime(2026, 3, 12),
    );
    expect(saved, isTrue);
    expect(viewModel.budgets, hasLength(1));
    expect(viewModel.budgets.single.budget.startDate, DateTime(2026, 3, 1));

    final deleted = await viewModel.deleteBudget(viewModel.budgets.single.budget.id);
    expect(deleted, isTrue);
    expect(viewModel.budgets, isEmpty);
  });

  test('creates, pauses, and removes a recurring schedule', () async {
    await repository.createAccount(
      name: 'Bank', accountType: 'bank', currencyCode: 'PKR');
    await viewModel.initialise();
    final account = viewModel.activeAccounts.single;

    final saved = await viewModel.saveRecurring(
      accountId: account.id,
      transactionType: 'expense',
      amountMinorUnits: 100000,
      frequency: 'monthly',
      nextDueDate: DateTime(2026, 4, 1),
    );
    expect(saved, isTrue);
    expect(viewModel.recurringItems, hasLength(1));
    expect(viewModel.recurringItems.single.recurring.currencyCode, 'PKR');

    final toggled = await viewModel.toggleRecurring(
      viewModel.recurringItems.single.recurring,
    );
    expect(toggled, isTrue);
    expect(viewModel.recurringItems.single.recurring.isActive, isFalse);

    final deleted = await viewModel.deleteRecurring(
      viewModel.recurringItems.single.recurring.id,
    );
    expect(deleted, isTrue);
    expect(viewModel.recurringItems, isEmpty);
  });

  test('reports invalid budget and recurring input', () async {
    final budgetSaved = await viewModel.saveBudget(
      amountMinorUnits: 0,
      currencyCode: 'PKR',
      periodType: 'monthly',
      startDate: DateTime(2026, 3, 1),
    );
    expect(budgetSaved, isFalse);
    expect(viewModel.errorMessage, isNotNull);

    final recurringSaved = await viewModel.saveRecurring(
      accountId: 'missing',
      transactionType: 'expense',
      amountMinorUnits: 100,
      frequency: 'monthly',
      nextDueDate: DateTime(2026, 3, 1),
    );
    expect(recurringSaved, isFalse);
    expect(viewModel.errorMessage, isNotNull);
  });
}
