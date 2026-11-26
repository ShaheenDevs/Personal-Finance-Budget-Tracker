import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/transactions/transactions_viewmodel.dart';

void main() {
  late AppDatabase database;
  late LocalFinanceRepository repository;
  late TransactionsViewModel viewModel;
  late String accountId;
  late String categoryId;
  late String tagId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
    viewModel = TransactionsViewModel(repository: repository);
    await repository.createAccount(
      name: 'Main account',
      accountType: 'bank',
      currencyCode: 'PKR',
    );
    accountId = (await repository.getAccounts()).single.id;
    await repository.createCategory(
      name: 'Food',
      transactionType: 'expense',
    );
    categoryId = (await repository.getCategories()).single.id;
    await repository.createTag(name: 'Essential');
    tagId = (await repository.getTags()).single.id;
  });

  tearDown(() async {
    await repository.close();
  });

  test('creates and lists an expense with its category and tags', () async {
    await viewModel.initialise();

    final saved = await viewModel.saveTransaction(
      accountId: accountId,
      categoryId: categoryId,
      transactionType: 'expense',
      amountMinorUnits: 2550,
      transactionDate: DateTime(2026, 3, 10),
      note: 'Groceries',
      tagIds: [tagId],
    );

    expect(saved, isTrue);
    expect(viewModel.transactionItems, hasLength(1));
    expect(viewModel.transactionItems.single.accountName, 'Main account');
    expect(viewModel.transactionItems.single.categoryName, 'Food');
    expect(viewModel.transactionItems.single.tagNames, ['Essential']);
    expect(viewModel.formatAmount('PKR', 2550), 'PKR 25.50');
  });

  test('updates and deletes a transaction', () async {
    await viewModel.initialise();
    await viewModel.saveTransaction(
      accountId: accountId,
      transactionType: 'expense',
      amountMinorUnits: 1000,
      transactionDate: DateTime(2026, 3, 10),
      note: 'Old note',
    );
    final id = viewModel.transactionItems.single.transaction.id;

    final updated = await viewModel.saveTransaction(
      id: id,
      accountId: accountId,
      transactionType: 'income',
      amountMinorUnits: 2000,
      transactionDate: DateTime(2026, 3, 11),
      note: 'Refund',
    );

    expect(updated, isTrue);
    expect(viewModel.transactionItems.single.transaction.transactionType, 'income');
    expect(viewModel.transactionItems.single.transaction.note, 'Refund');

    final deleted = await viewModel.deleteTransaction(id);
    expect(deleted, isTrue);
    expect(viewModel.transactionItems, isEmpty);

    final stored = await (database.select(database.transactions)
          ..where((row) => row.id.equals(id)))
        .getSingle();
    expect(stored.deletedAt, isNotNull);
  });

  test('rejects transactions on archived accounts', () async {
    await repository.archiveAccount(accountId);
    await viewModel.initialise();

    final saved = await viewModel.saveTransaction(
      accountId: accountId,
      transactionType: 'expense',
      amountMinorUnits: 100,
      transactionDate: DateTime(2026, 3, 10),
    );

    expect(saved, isFalse);
    expect(viewModel.errorMessage, isNotNull);
  });
}
