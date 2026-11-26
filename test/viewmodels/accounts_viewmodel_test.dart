import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/accounts/accounts_viewmodel.dart';

void main() {
  late AppDatabase database;
  late LocalFinanceRepository repository;
  late AccountsViewModel viewModel;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
    viewModel = AccountsViewModel(repository: repository);
  });

  tearDown(() async {
    await repository.close();
  });

  test('loads account balances from local transactions', () async {
    await repository.createAccount(
      name: 'Cash wallet',
      accountType: 'cash',
      currencyCode: 'PKR',
      openingBalanceMinorUnits: 10000,
    );
    final account = (await repository.getAccounts()).single;
    await repository.createTransaction(
      accountId: account.id,
      transactionType: 'income',
      amountMinorUnits: 2500,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 3, 1),
    );

    await viewModel.initialise();

    expect(viewModel.accountSummaries, hasLength(1));
    expect(viewModel.accountSummaries.single.balanceMinorUnits, 12500);
    expect(viewModel.formatBalance('PKR', 12500), 'PKR 125.00');
  });

  test('creates and updates an account', () async {
    final created = await viewModel.saveAccount(
      name: '  Main bank  ',
      accountType: 'bank',
      currencyCode: 'pkr',
      openingBalanceMinorUnits: 50000,
    );

    expect(created, isTrue);
    expect(viewModel.accountSummaries.single.account.name, 'Main bank');
    expect(viewModel.accountSummaries.single.balanceMinorUnits, 50000);

    final id = viewModel.accountSummaries.single.account.id;
    final updated = await viewModel.saveAccount(
      id: id,
      name: 'Updated bank',
      accountType: 'bank',
      currencyCode: 'PKR',
    );

    expect(updated, isTrue);
    expect(viewModel.accountSummaries.single.account.name, 'Updated bank');
    expect(viewModel.accountSummaries.single.balanceMinorUnits, 50000);
  });

  test('archives an account without deleting its history', () async {
    await viewModel.saveAccount(
      name: 'Old wallet',
      accountType: 'wallet',
      currencyCode: 'PKR',
      openingBalanceMinorUnits: 2000,
    );
    final id = viewModel.accountSummaries.single.account.id;

    final archived = await viewModel.archiveAccount(id);

    expect(archived, isTrue);
    expect(viewModel.accountSummaries.single.account.archived, isTrue);
    expect(viewModel.accountSummaries.single.balanceMinorUnits, 2000);
  });

  test('reports invalid account input without crashing', () async {
    final result = await viewModel.saveAccount(
      name: ' ',
      accountType: 'cash',
      currencyCode: 'PKR',
    );

    expect(result, isFalse);
    expect(viewModel.errorMessage, isNotNull);
    expect(viewModel.accountSummaries, isEmpty);
  });
}
