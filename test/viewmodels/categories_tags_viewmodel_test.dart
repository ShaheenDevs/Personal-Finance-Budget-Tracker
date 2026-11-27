import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/categories_tags/categories_tags_viewmodel.dart';

void main() {
  late AppDatabase database;
  late LocalFinanceRepository repository;
  late CategoriesTagsViewModel viewModel;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
    viewModel = CategoriesTagsViewModel(repository: repository);
  });

  tearDown(() async {
    await repository.close();
  });

  test('loads and separates income and expense categories', () async {
    await repository.createCategory(name: 'Salary', transactionType: 'income');
    await repository.createCategory(name: 'Food', transactionType: 'expense');

    await viewModel.initialise();

    expect(viewModel.incomeCategories.map((item) => item.name), ['Salary']);
    expect(viewModel.expenseCategories.map((item) => item.name), ['Food']);
  });

  test('creates categories and tags and refreshes screen data', () async {
    await viewModel.initialise();

    final categorySaved = await viewModel.addCategory(
      name: 'Transport',
      transactionType: 'expense',
    );
    final tagSaved = await viewModel.addTag(name: 'Essential');

    expect(categorySaved, isTrue);
    expect(tagSaved, isTrue);
    expect(viewModel.expenseCategories.single.name, 'Transport');
    expect(viewModel.tags.single.name, 'Essential');
    expect(viewModel.successMessage, 'Tag added.');
  });

  test('reports duplicate category and tag errors without losing existing data', () async {
    await repository.createCategory(name: 'Food', transactionType: 'expense');
    await repository.createTag(name: 'Work');
    await viewModel.initialise();

    final categorySaved = await viewModel.addCategory(
      name: 'Food',
      transactionType: 'expense',
    );
    final tagSaved = await viewModel.addTag(name: 'Work');

    expect(categorySaved, isFalse);
    expect(tagSaved, isFalse);
    expect(viewModel.errorMessage, contains('already exist'));
    expect(viewModel.expenseCategories, hasLength(1));
    expect(viewModel.tags, hasLength(1));
  });
  test('renames categories and tags while retaining their identifiers', () async {
    await repository.createCategory(name: 'Food', transactionType: 'expense');
    await repository.createTag(name: 'Work');
    await viewModel.initialise();
    final category = viewModel.expenseCategories.single;
    final tag = viewModel.tags.single;
    expect(await viewModel.renameCategory(id: category.id, name: 'Groceries'), isTrue);
    expect(await viewModel.renameTag(id: tag.id, name: 'Office'), isTrue);
    expect(viewModel.expenseCategories.single.id, category.id);
    expect(viewModel.expenseCategories.single.name, 'Groceries');
    expect(viewModel.tags.single.id, tag.id);
    expect(viewModel.tags.single.name, 'Office');
  });

  test('blocks deletion of categories and tags linked to transaction history', () async {
    await repository.createAccount(name: 'Cash', accountType: 'cash', currencyCode: 'PKR');
    final account = (await repository.getAccounts()).single;
    await repository.createCategory(name: 'Food', transactionType: 'expense');
    await repository.createTag(name: 'Essential');
    final category = (await repository.getCategories()).single;
    final tag = (await repository.getTags()).single;
    await repository.createTransaction(accountId: account.id, categoryId: category.id, transactionType: 'expense', amountMinorUnits: 100, currencyCode: 'PKR', transactionDate: DateTime(2026, 2, 1), tagIds: [tag.id]);
    await viewModel.initialise();
    expect(await viewModel.deleteCategory(category.id), isFalse);
    expect(viewModel.errorMessage, contains('used by transactions'));
    expect(await viewModel.deleteTag(tag.id), isFalse);
    expect(viewModel.errorMessage, contains('used by transactions'));
    expect(await repository.getCategories(), hasLength(1));
    expect(await repository.getTags(), hasLength(1));
  });

  test('deletes unused custom categories and tags', () async {
    await repository.createCategory(name: 'Temporary', transactionType: 'expense');
    await repository.createTag(name: 'Temporary');
    await viewModel.initialise();
    final categoryId = viewModel.expenseCategories.single.id;
    final tagId = viewModel.tags.single.id;
    expect(await viewModel.deleteCategory(categoryId), isTrue);
    expect(await viewModel.deleteTag(tagId), isTrue);
    expect(viewModel.categories, isEmpty);
    expect(viewModel.tags, isEmpty);
  });
}
