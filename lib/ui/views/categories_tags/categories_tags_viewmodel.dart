import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:stacked/stacked.dart';

class CategoriesTagsViewModel extends BaseViewModel {
  CategoriesTagsViewModel({LocalFinanceRepository? repository})
      : _repository = repository ?? locator<LocalFinanceRepository>();

  final LocalFinanceRepository _repository;

  List<Category> categories = [];
  List<Tag> tags = [];
  String? errorMessage;
  String? successMessage;

  List<Category> get incomeCategories =>
      categories.where((category) => category.transactionType == 'income').toList();

  List<Category> get expenseCategories =>
      categories.where((category) => category.transactionType == 'expense').toList();

  Future<void> initialise() => loadData();

  Future<void> loadData() async {
    setBusy(true);
    errorMessage = null;
    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getTags(),
      ]);
      categories = results[0] as List<Category>;
      tags = results[1] as List<Tag>;
    } catch (_) {
      errorMessage = 'Could not load categories and tags. Please try again.';
    } finally {
      setBusy(false);
    }
  }

  Future<bool> addCategory({
    required String name,
    required String transactionType,
  }) async {
    errorMessage = null;
    successMessage = null;
    try {
      await _repository.createCategory(
        name: name,
        transactionType: transactionType,
      );
      await loadData();
      successMessage = 'Category added.';
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = _friendlyError(error, item: 'category');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTag({required String name}) async {
    errorMessage = null;
    successMessage = null;
    try {
      await _repository.createTag(name: name);
      await loadData();
      successMessage = 'Tag added.';
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = _friendlyError(error, item: 'tag');
      notifyListeners();
      return false;
    }
  }

  String _friendlyError(Object error, {required String item}) {
    if (error is ArgumentError) {
      return error.toString().replaceFirst('Invalid argument(s): ', '');
    }
    return 'Could not add this $item. It may already exist.';
  }
}
