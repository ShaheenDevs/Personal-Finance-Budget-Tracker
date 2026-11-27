// ignore_for_file: require_trailing_commas

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/reports/reports_viewmodel.dart';

void main() {
  late AppDatabase database;
  late LocalFinanceRepository repository;
  late ReportsViewModel viewModel;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
    viewModel = ReportsViewModel(repository: repository);
    viewModel.selectedMonth = DateTime(2026, 3);
  });

  tearDown(() async => repository.close());

  test('summarizes selected month by currency and expense category', () async {
    await repository.createAccount(
      name: 'Cash', accountType: 'cash', currencyCode: 'PKR');
    final account = (await repository.getAccounts()).single;
    await repository.createCategory(name: 'Food', transactionType: 'expense');
    final food = (await repository.getCategories()).single;
    await repository.createTransaction(
      accountId: account.id, categoryId: food.id,
      transactionType: 'expense', amountMinorUnits: 2500,
      currencyCode: 'PKR', transactionDate: DateTime(2026, 3, 5));
    await repository.createTransaction(
      accountId: account.id, transactionType: 'income',
      amountMinorUnits: 10000, currencyCode: 'PKR',
      transactionDate: DateTime(2026, 3, 8));
    await repository.createTransaction(
      accountId: account.id, transactionType: 'expense',
      amountMinorUnits: 9000, currencyCode: 'PKR',
      transactionDate: DateTime(2026, 4, 1));

    await viewModel.loadReport();
    expect(viewModel.monthLabel, 'March 2026');
    expect(viewModel.selectedCurrency, 'PKR');

    expect(viewModel.incomeMinorUnits, 10000);
    expect(viewModel.expenseMinorUnits, 2500);
    expect(viewModel.netMinorUnits, 7500);
    expect(viewModel.categoryExpenses.single.name, 'Food');
    expect(viewModel.categoryExpenses.single.amountMinorUnits, 2500);
    expect(viewModel.weeklyCashFlow.first.income, 10000);
  });

  test('changing month recalculates totals without mixing currencies', () async {
    await repository.createAccount(
      name: 'Cash', accountType: 'cash', currencyCode: 'PKR');
    final account = (await repository.getAccounts()).single;
    await repository.createTransaction(
      accountId: account.id, transactionType: 'income',
      amountMinorUnits: 10000, currencyCode: 'PKR',
      transactionDate: DateTime(2026, 3, 2));
    await repository.createTransaction(
      accountId: account.id, transactionType: 'expense',
      amountMinorUnits: 5000, currencyCode: 'PKR',
      transactionDate: DateTime(2026, 4, 2));

    await viewModel.loadReport();
    expect(viewModel.incomeMinorUnits, 10000);
    viewModel.changeMonth(1);
    expect(viewModel.incomeMinorUnits, 0);
    expect(viewModel.expenseMinorUnits, 5000);
  });
}
