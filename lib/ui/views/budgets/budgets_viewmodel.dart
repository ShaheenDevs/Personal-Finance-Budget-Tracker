import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:stacked/stacked.dart';

class BudgetListItem {
  const BudgetListItem({
    required this.budget,
    required this.spentMinorUnits,
    required this.categoryName,
  });

  final Budget budget;
  final int spentMinorUnits;
  final String? categoryName;

  int get remainingMinorUnits =>
      budget.amountMinorUnits - spentMinorUnits;
  double get progress => budget.amountMinorUnits == 0
      ? 0
      : spentMinorUnits / budget.amountMinorUnits;
}

class RecurringListItem {
  const RecurringListItem({
    required this.recurring,
    required this.accountName,
    required this.categoryName,
  });

  final RecurringTransaction recurring;
  final String accountName;
  final String? categoryName;
}

class BudgetsViewModel extends BaseViewModel {
  BudgetsViewModel({LocalFinanceRepository? repository})
      : _repository = repository ?? locator<LocalFinanceRepository>();

  final LocalFinanceRepository _repository;

  List<Account> accounts = [];
  List<Category> categories = [];
  List<BudgetListItem> budgets = [];
  List<RecurringListItem> recurringItems = [];
  String? errorMessage;

  List<Account> get activeAccounts =>
      accounts.where((account) => !account.archived).toList();
  List<Category> get expenseCategories =>
      categories.where((category) => category.transactionType == 'expense').toList();

  Future<void> initialise() => loadData();

  Future<void> loadData() async {
    setBusy(true);
    errorMessage = null;
    try {
      final results = await Future.wait([
        _repository.getAccounts(),
        _repository.getCategories(),
        _repository.getBudgets(),
        _repository.getRecurringTransactions(),
      ]);
      accounts = results[0] as List<Account>;
      categories = results[1] as List<Category>;
      final budgetRows = results[2] as List<Budget>;
      final recurringRows = results[3] as List<RecurringTransaction>;
      final categoryNames = {for (final item in categories) item.id: item.name};
      final accountNames = {for (final item in accounts) item.id: item.name};
      budgets = await Future.wait(budgetRows.map((budget) async => BudgetListItem(
            budget: budget,
            spentMinorUnits: await _repository.getBudgetSpentMinorUnits(budget),
            categoryName: budget.categoryId == null
                ? null
                : categoryNames[budget.categoryId],
          )));
      recurringItems = recurringRows.map((item) => RecurringListItem(
        recurring: item,
        accountName: accountNames[item.accountId] ?? 'Unknown account',
        categoryName: item.categoryId == null
            ? null
            : categoryNames[item.categoryId],
      )).toList();
    } catch (error) {
      errorMessage = _friendlyError(error);
    } finally {
      setBusy(false);
    }
  }

  Future<bool> saveBudget({
    String? id,
    String? categoryId,
    required int amountMinorUnits,
    required String currencyCode,
    required String periodType,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    errorMessage = null;
    try {
      if (id == null) {
        await _repository.createBudget(
          categoryId: categoryId,
          amountMinorUnits: amountMinorUnits,
          currencyCode: currencyCode,
          periodType: periodType,
          startDate: startDate,
          endDate: endDate,
        );
      } else {
        await _repository.updateBudget(
          id: id,
          categoryId: categoryId,
          amountMinorUnits: amountMinorUnits,
          currencyCode: currencyCode,
          periodType: periodType,
          startDate: startDate,
          endDate: endDate,
        );
      }
      await loadData();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    errorMessage = null;
    try {
      await _repository.deleteBudget(id);
      await loadData();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveRecurring({
    String? id,
    required String accountId,
    String? categoryId,
    required String transactionType,
    required int amountMinorUnits,
    required String frequency,
    required DateTime nextDueDate,
  }) async {
    errorMessage = null;
    try {
      final account = activeAccounts.firstWhere(
        (item) => item.id == accountId,
        orElse: () => throw ArgumentError('Select an active account.'),
      );
      if (id == null) {
        await _repository.createRecurringTransaction(
          accountId: accountId,
          categoryId: categoryId,
          transactionType: transactionType,
          amountMinorUnits: amountMinorUnits,
          currencyCode: account.currencyCode,
          frequency: frequency,
          nextDueDate: nextDueDate,
        );
      } else {
        await _repository.updateRecurringTransaction(
          id: id,
          accountId: accountId,
          categoryId: categoryId,
          transactionType: transactionType,
          amountMinorUnits: amountMinorUnits,
          currencyCode: account.currencyCode,
          frequency: frequency,
          nextDueDate: nextDueDate,
        );
      }
      await loadData();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleRecurring(RecurringTransaction item) async {
    errorMessage = null;
    try {
      await _repository.setRecurringTransactionActive(item.id, !item.isActive);
      await loadData();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecurring(String id) async {
    errorMessage = null;
    try {
      await _repository.deleteRecurringTransaction(id);
      await loadData();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  String formatAmount(String currencyCode, int amountMinorUnits) {
    final amount = amountMinorUnits.abs();
    final sign = amountMinorUnits < 0 ? '-' : '';
    return '$currencyCode $sign${amount ~/ 100}.${(amount % 100).toString().padLeft(2, '0')}';
  }

  String _friendlyError(Object error) {
    if (error is ArgumentError || error is StateError) {
      return error.toString().replaceFirst(
        RegExp(r'^(Invalid argument\\(s\\): |Bad state: )'),
        '',
      );
    }
    return 'Something went wrong. Please try again.';
  }
}
