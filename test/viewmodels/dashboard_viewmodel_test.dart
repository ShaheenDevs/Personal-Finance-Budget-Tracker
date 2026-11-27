import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/dashboard/dashboard_viewmodel.dart';

void main() {
  late AppDatabase database;
  late LocalFinanceRepository repository;
  late DashboardViewModel viewModel;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
    viewModel = DashboardViewModel(repository: repository);
  });

  tearDown(() async => repository.close());

  test('shows account balance and current-month income and expenses', () async {
    await repository.createAccount(
      name: 'Wallet', accountType: 'wallet', currencyCode: 'PKR',
      openingBalanceMinorUnits: 10000);
    final account = (await repository.getAccounts()).single;
    final now = DateTime.now();
    await repository.createTransaction(
      accountId: account.id, transactionType: 'income',
      amountMinorUnits: 5000, currencyCode: 'PKR',
      transactionDate: DateTime(now.year, now.month, 2));
    await repository.createTransaction(
      accountId: account.id, transactionType: 'expense',
      amountMinorUnits: 2000, currencyCode: 'PKR',
      transactionDate: DateTime(now.year, now.month, 3));

    await viewModel.loadSummary();

    expect(viewModel.summaries, hasLength(1));
    expect(viewModel.summaries.single.currencyCode, 'PKR');
    expect(viewModel.summaries.single.balanceMinorUnits, 13000);
    expect(viewModel.summaries.single.monthIncomeMinorUnits, 5000);
    expect(viewModel.summaries.single.monthExpenseMinorUnits, 2000);
  });

  test('keeps balances separate when accounts use different currencies', () async {
    await repository.createAccount(
      name: 'PKR', accountType: 'cash', currencyCode: 'PKR',
      openingBalanceMinorUnits: 5000);
    await repository.createAccount(
      name: 'USD', accountType: 'bank', currencyCode: 'USD',
      openingBalanceMinorUnits: 3000);

    await viewModel.loadSummary();

    expect(viewModel.summaries.map((item) => item.currencyCode),
        containsAll(['PKR', 'USD']));
    expect(viewModel.summaries.map((item) => item.balanceMinorUnits),
        containsAll([5000, 3000]));
  });
}
