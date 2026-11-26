import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';

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

  test('creates and reads a local financial account', () async {
    await repository.createAccount(
      name: 'Cash',
      accountType: 'cash',
      currencyCode: 'PKR',
      openingBalanceMinorUnits: 125000,
    );

    final accounts = await repository.getAccounts();

    expect(accounts, hasLength(1));
    expect(accounts.single.name, 'Cash');
    expect(accounts.single.currencyCode, 'PKR');
    expect(accounts.single.openingBalanceMinorUnits, 125000);
  });

  test('rejects zero or negative transaction amounts', () async {
    expect(
      () => repository.createTransaction(
        accountId: 'missing-account',
        transactionType: 'expense',
        amountMinorUnits: 0,
        currencyCode: 'PKR',
        transactionDate: DateTime(2026, 1, 1),
      ),
      throwsArgumentError,
    );
  });
}
