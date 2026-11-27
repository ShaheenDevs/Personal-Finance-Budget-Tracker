// ignore_for_file: require_trailing_commas

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

  test('persists a transaction linked to its account', () async {
    await repository.createAccount(
      name: 'Main account',
      accountType: 'bank',
      currencyCode: 'PKR',
    );
    final account = (await repository.getAccounts()).single;

    await repository.createTransaction(
      accountId: account.id,
      transactionType: 'expense',
      amountMinorUnits: 2500,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 1, 10),
      note: 'Groceries',
    );

    final transactions = await database.select(database.transactions).get();
    expect(transactions, hasLength(1));
    expect(transactions.single.amountMinorUnits, 2500);
    expect(transactions.single.accountId, account.id);
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
  test('enforces account foreign keys for transactions', () async {
    expect(
      database.into(database.transactions).insert(
            TransactionsCompanion.insert(
              id: 'orphan-transaction',
              accountId: 'missing-account',
              transactionType: 'expense',
              amountMinorUnits: 100,
              currencyCode: 'PKR',
              transactionDate: DateTime(2026, 1, 10),
            ),
          ),
      throwsA(anything),
    );
  });
  test('cascades account deletion to its transactions', () async {
    await repository.createAccount(
      name: 'Temporary account',
      accountType: 'cash',
      currencyCode: 'PKR',
    );
    final account = (await repository.getAccounts()).single;

    await repository.createTransaction(
      accountId: account.id,
      transactionType: 'expense',
      amountMinorUnits: 500,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 1, 10),
    );

    await (database.delete(database.accounts)
          ..where((row) => row.id.equals(account.id)))
        .go();

    expect(await database.select(database.transactions).get(), isEmpty);
  });

  test('uses the initial database schema version', () {
    expect(database.schemaVersion, 1);
  });

  test('creates tagged transactions and calculates account balance', () async {
    await repository.createAccount(
      name: 'Daily account',
      accountType: 'cash',
      currencyCode: 'PKR',
      openingBalanceMinorUnits: 10000,
    );
    final account = (await repository.getAccounts()).single;
    await repository.createCategory(
      name: 'Food',
      transactionType: 'expense',
    );
    final category = (await repository.getCategories()).single;
    await repository.createTag(name: 'Essential');
    final tag = (await repository.getTags()).single;

    await repository.createTransaction(
      accountId: account.id,
      categoryId: category.id,
      transactionType: 'expense',
      amountMinorUnits: 2500,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 2, 1),
      tagIds: [tag.id],
    );

    final transactions = await repository.getTransactions();
    final links = await database.select(database.transactionTags).get();
    expect(transactions, hasLength(1));
    expect(transactions.single.categoryId, category.id);
    expect(links, hasLength(1));
    expect(links.single.tagId, tag.id);
    expect(await repository.getAccountBalanceMinorUnits(account.id), 7500);
  });

  test('updates and soft-deletes a transaction', () async {
    await repository.createAccount(
      name: 'Main account',
      accountType: 'bank',
      currencyCode: 'PKR',
      openingBalanceMinorUnits: 2000,
    );
    final account = (await repository.getAccounts()).single;
    await repository.createTransaction(
      accountId: account.id,
      transactionType: 'expense',
      amountMinorUnits: 500,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 2, 1),
      note: 'Old note',
    );
    final transaction = (await repository.getTransactions()).single;

    await repository.updateTransaction(
      id: transaction.id,
      accountId: account.id,
      transactionType: 'income',
      amountMinorUnits: 700,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 2, 2),
      note: 'Updated note',
    );

    final updated = (await repository.getTransactions()).single;
    expect(updated.transactionType, 'income');
    expect(updated.amountMinorUnits, 700);
    expect(updated.note, 'Updated note');
    expect(await repository.getAccountBalanceMinorUnits(account.id), 2700);

    await repository.deleteTransaction(transaction.id);
    expect(await repository.getTransactions(), isEmpty);
    expect(await repository.getAccountBalanceMinorUnits(account.id), 2000);
    final stored = await (database.select(database.transactions)
          ..where((row) => row.id.equals(transaction.id)))
        .getSingle();
    expect(stored.deletedAt, isNotNull);
  });

  test('rejects category type and account currency mismatches', () async {
    await repository.createAccount(
      name: 'PKR account',
      accountType: 'cash',
      currencyCode: 'PKR',
    );
    final account = (await repository.getAccounts()).single;
    await repository.createCategory(
      name: 'Salary',
      transactionType: 'income',
    );
    final category = (await repository.getCategories()).single;

    expect(
      repository.createTransaction(
        accountId: account.id,
        categoryId: category.id,
        transactionType: 'expense',
        amountMinorUnits: 100,
        currencyCode: 'PKR',
        transactionDate: DateTime(2026, 2, 1),
      ),
      throwsArgumentError,
    );
    expect(
      repository.createTransaction(
        accountId: account.id,
        transactionType: 'expense',
        amountMinorUnits: 100,
        currencyCode: 'USD',
        transactionDate: DateTime(2026, 2, 1),
      ),
      throwsArgumentError,
    );
  });

  test('protects recorded account currency and archived accounts', () async {
    await repository.createAccount(
      name: 'Main account',
      accountType: 'bank',
      currencyCode: 'PKR',
    );
    final account = (await repository.getAccounts()).single;
    await repository.createTransaction(
      accountId: account.id,
      transactionType: 'expense',
      amountMinorUnits: 100,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 2, 1),
    );

    expect(
      repository.updateAccount(
        id: account.id,
        name: 'Main account',
        accountType: 'bank',
        currencyCode: 'USD',
      ),
      throwsStateError,
    );

    await repository.archiveAccount(account.id);
    expect(
      repository.createTransaction(
        accountId: account.id,
        transactionType: 'expense',
        amountMinorUnits: 100,
        currencyCode: 'PKR',
        transactionDate: DateTime(2026, 2, 2),
      ),
      throwsStateError,
    );
  });


  test('tracks monthly budget spending for matching currency and expenses', () async {
    await repository.createAccount(
      name: 'Main cash', accountType: 'cash', currencyCode: 'PKR');
    final account = (await repository.getAccounts()).single;
    await repository.createBudget(
      amountMinorUnits: 100000,
      currencyCode: 'PKR',
      periodType: 'monthly',
      startDate: DateTime(2026, 3, 18),
    );
    final budget = (await repository.getBudgets()).single;
    expect(budget.startDate, DateTime(2026, 3, 1));

    await repository.createTransaction(
      accountId: account.id,
      transactionType: 'expense',
      amountMinorUnits: 25000,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 3, 5),
    );
    await repository.createTransaction(
      accountId: account.id,
      transactionType: 'income',
      amountMinorUnits: 50000,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 3, 6),
    );
    await repository.createTransaction(
      accountId: account.id,
      transactionType: 'expense',
      amountMinorUnits: 90000,
      currencyCode: 'PKR',
      transactionDate: DateTime(2026, 4, 1),
    );

    expect(await repository.getBudgetSpentMinorUnits(budget), 25000);
  });

  test('custom category budget includes only its date range and category', () async {
    await repository.createAccount(
      name: 'Wallet', accountType: 'wallet', currencyCode: 'PKR');
    final account = (await repository.getAccounts()).single;
    await repository.createCategory(name: 'Food', transactionType: 'expense');
    await repository.createCategory(name: 'Travel', transactionType: 'expense');
    final categories = await repository.getCategories();
    final food = categories.firstWhere((item) => item.name == 'Food');
    final travel = categories.firstWhere((item) => item.name == 'Travel');
    await repository.createBudget(
      categoryId: food.id,
      amountMinorUnits: 50000,
      currencyCode: 'PKR',
      periodType: 'custom',
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 3, 20),
    );
    final budget = (await repository.getBudgets()).single;
    for (final entry in [
      (food.id, DateTime(2026, 3, 10), 10000),
      (food.id, DateTime(2026, 3, 20), 12000),
      (food.id, DateTime(2026, 3, 21), 40000),
      (travel.id, DateTime(2026, 3, 15), 30000),
    ]) {
      await repository.createTransaction(
        accountId: account.id,
        categoryId: entry.$1,
        transactionType: 'expense',
        amountMinorUnits: entry.$3,
        currencyCode: 'PKR',
        transactionDate: entry.$2,
      );
    }
    expect(await repository.getBudgetSpentMinorUnits(budget), 22000);
  });

  test('rejects invalid budget amounts and custom date ranges', () async {
    expect(
      () => repository.createBudget(
        amountMinorUnits: 0,
        currencyCode: 'PKR',
        periodType: 'monthly',
        startDate: DateTime(2026, 3, 1),
      ),
      throwsArgumentError,
    );
    expect(
      () => repository.createBudget(
        amountMinorUnits: 1000,
        currencyCode: 'PKR',
        periodType: 'custom',
        startDate: DateTime(2026, 3, 10),
        endDate: DateTime(2026, 3, 9),
      ),
      throwsArgumentError,
    );
  });

  test('creates, pauses, updates, and deletes recurring schedules', () async {
    await repository.createAccount(
      name: 'Bank', accountType: 'bank', currencyCode: 'PKR');
    final account = (await repository.getAccounts()).single;
    await repository.createCategory(name: 'Rent', transactionType: 'expense');
    final category = (await repository.getCategories()).single;
    await repository.createRecurringTransaction(
      accountId: account.id,
      categoryId: category.id,
      transactionType: 'expense',
      amountMinorUnits: 250000,
      currencyCode: 'PKR',
      frequency: 'monthly',
      nextDueDate: DateTime(2026, 4, 5),
    );
    var recurring = (await repository.getRecurringTransactions()).single;
    expect(recurring.frequency, 'monthly');
    expect(recurring.isActive, isTrue);

    await repository.setRecurringTransactionActive(recurring.id, false);
    recurring = (await repository.getRecurringTransactions()).single;
    expect(recurring.isActive, isFalse);

    await repository.updateRecurringTransaction(
      id: recurring.id,
      accountId: account.id,
      categoryId: category.id,
      transactionType: 'expense',
      amountMinorUnits: 300000,
      currencyCode: 'PKR',
      frequency: 'weekly',
      nextDueDate: DateTime(2026, 4, 12),
    );
    recurring = (await repository.getRecurringTransactions()).single;
    expect(recurring.amountMinorUnits, 300000);
    expect(recurring.frequency, 'weekly');

    await repository.deleteRecurringTransaction(recurring.id);
    expect(await repository.getRecurringTransactions(), isEmpty);
  });

  test('rejects recurring schedules with invalid frequency or currency', () async {
    await repository.createAccount(
      name: 'Cash', accountType: 'cash', currencyCode: 'PKR');
    final account = (await repository.getAccounts()).single;
    expect(
      () => repository.createRecurringTransaction(
        accountId: account.id,
        transactionType: 'expense',
        amountMinorUnits: 1000,
        currencyCode: 'PKR',
        frequency: 'every-so-often',
        nextDueDate: DateTime(2026, 4, 1),
      ),
      throwsArgumentError,
    );
    expect(
      () => repository.createRecurringTransaction(
        accountId: account.id,
        transactionType: 'expense',
        amountMinorUnits: 1000,
        currencyCode: 'USD',
        frequency: 'monthly',
        nextDueDate: DateTime(2026, 4, 1),
      ),
      throwsArgumentError,
    );
  });

}
