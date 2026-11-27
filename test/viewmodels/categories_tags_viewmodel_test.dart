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
}
