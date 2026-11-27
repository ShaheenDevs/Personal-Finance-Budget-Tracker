// ignore_for_file: require_trailing_commas

import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:stacked/stacked.dart';

class WeeklyCashFlow {
  const WeeklyCashFlow({required this.label, required this.income, required this.expense});
  final String label;
  final int income;
  final int expense;
}

class CategoryExpense {
  const CategoryExpense({required this.name, required this.amountMinorUnits});
  final String name;
  final int amountMinorUnits;
}

class ReportsViewModel extends BaseViewModel {
  ReportsViewModel({LocalFinanceRepository? repository})
      : _repository = repository ?? locator<LocalFinanceRepository>();

  final LocalFinanceRepository _repository;
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String? selectedCurrency;
  String? errorMessage;
  List<FinanceTransaction> _transactions = [];
  Map<String, String> _categoryNames = {};
  List<String> currencies = [];
  int incomeMinorUnits = 0;
  int expenseMinorUnits = 0;
  List<WeeklyCashFlow> weeklyCashFlow = [];
  List<CategoryExpense> categoryExpenses = [];

  int get netMinorUnits => incomeMinorUnits - expenseMinorUnits;
  String get monthLabel =>
      '${_monthNames[selectedMonth.month - 1]} ${selectedMonth.year}';

  static const _monthNames = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  Future<void> initialise() => loadReport();

  Future<void> loadReport() async {
    setBusy(true);
    errorMessage = null;
    try {
      final results = await Future.wait([
        _repository.getTransactions(),
        _repository.getCategories(),
      ]);
      _transactions = results[0] as List<FinanceTransaction>;
      final categories = results[1] as List<Category>;
      _categoryNames = {for (final category in categories) category.id: category.name};
      currencies = _transactions.map((row) => row.currencyCode).toSet().toList()..sort();
      if (selectedCurrency == null || !currencies.contains(selectedCurrency)) {
        selectedCurrency = currencies.isEmpty ? null : currencies.first;
      }
      _recalculate();
    } catch (_) {
      errorMessage = 'Could not load the report. Please try again.';
    } finally {
      setBusy(false);
    }
  }

  void selectCurrency(String? currency) {
    selectedCurrency = currency;
    _recalculate();
    notifyListeners();
  }

  void changeMonth(int offset) {
    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + offset);
    _recalculate();
    notifyListeners();
  }

  void _recalculate() {
    incomeMinorUnits = 0;
    expenseMinorUnits = 0;
    final weekly = List.generate(5, (_) => [0, 0]);
    final categories = <String, int>{};
    if (selectedCurrency == null) {
      weeklyCashFlow = [];
      categoryExpenses = [];
      return;
    }
    final start = selectedMonth;
    final end = DateTime(start.year, start.month + 1);
    for (final transaction in _transactions) {
      final date = transaction.transactionDate;
      if (transaction.currencyCode != selectedCurrency ||
          date.year != start.year || date.month != start.month) {
        continue;
      }
      final weekIndex = ((date.day - 1) ~/ 7).clamp(0, 4).toInt();
      if (transaction.transactionType == 'income') {
        incomeMinorUnits += transaction.amountMinorUnits;
        weekly[weekIndex][0] += transaction.amountMinorUnits;
      } else {
        expenseMinorUnits += transaction.amountMinorUnits;
        weekly[weekIndex][1] += transaction.amountMinorUnits;
        final name = transaction.categoryId == null
            ? 'Uncategorized'
            : (_categoryNames[transaction.categoryId!] ?? 'Uncategorized');
        categories.update(name, (value) => value + transaction.amountMinorUnits,
            ifAbsent: () => transaction.amountMinorUnits);
      }
    }
    weeklyCashFlow = List.generate(5, (index) => WeeklyCashFlow(
      label: 'W${index + 1}', income: weekly[index][0], expense: weekly[index][1],
    ));
    categoryExpenses = categories.entries.map((entry) =>
      CategoryExpense(name: entry.key, amountMinorUnits: entry.value)).toList()
      ..sort((a, b) => b.amountMinorUnits.compareTo(a.amountMinorUnits));
  }

  String formatAmount(int minorUnits) {
    final absolute = minorUnits.abs();
    final sign = minorUnits < 0 ? '-' : '';
    return '${selectedCurrency ?? ''} $sign${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
  }
}
