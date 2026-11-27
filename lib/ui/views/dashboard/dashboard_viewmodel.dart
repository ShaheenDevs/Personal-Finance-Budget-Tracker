import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:stacked/stacked.dart';

class DashboardCurrencySummary {
  const DashboardCurrencySummary({
    required this.currencyCode,
    required this.balanceMinorUnits,
    required this.monthIncomeMinorUnits,
    required this.monthExpenseMinorUnits,
    required this.accountCount,
  });

  final String currencyCode;
  final int balanceMinorUnits;
  final int monthIncomeMinorUnits;
  final int monthExpenseMinorUnits;
  final int accountCount;

  int get netCashFlowMinorUnits =>
      monthIncomeMinorUnits - monthExpenseMinorUnits;
}

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel({LocalFinanceRepository? repository})
      : _repository = repository ?? locator<LocalFinanceRepository>();

  final LocalFinanceRepository _repository;

  List<DashboardCurrencySummary> summaries = [];
  String? errorMessage;

  String get greeting => 'Your money, clearly organized';
  String get setupMessage => summaries.isEmpty
      ? 'Add an account and your first transaction to see your financial overview.'
      : 'Balances and this month’s cash flow are calculated from your local records.';

  Future<void> initialise() => loadSummary();

  Future<void> loadSummary() async {
    setBusy(true);
    errorMessage = null;
    try {
      final accounts = await _repository.getAccounts();
      final transactions = await _repository.getTransactions();
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month);
      final nextMonth = DateTime(now.year, now.month + 1);
      final currencies = <String>{...accounts.map((a) => a.currencyCode)};
      final totals = <String, List<int>>{};
      final counts = <String, int>{};
      for (final account in accounts) {
        final values = totals.putIfAbsent(account.currencyCode, () => [0, 0, 0]);
        values[0] += await _repository.getAccountBalanceMinorUnits(account.id);
        counts.update(account.currencyCode, (value) => value + 1,
            ifAbsent: () => 1);
      }
      for (final transaction in transactions) {
        currencies.add(transaction.currencyCode);
        if (!transaction.transactionDate.isBefore(monthStart) &&
            transaction.transactionDate.isBefore(nextMonth)) {
          final values = totals.putIfAbsent(
              transaction.currencyCode, () => [0, 0, 0]);
          if (transaction.transactionType == 'income') {
            values[1] += transaction.amountMinorUnits;
          } else {
            values[2] += transaction.amountMinorUnits;
          }
        }
      }
      final sortedCurrencies = currencies.toList()..sort();
      summaries = sortedCurrencies.map((currency) {
        final values = totals[currency] ?? [0, 0, 0];
        return DashboardCurrencySummary(
          currencyCode: currency,
          balanceMinorUnits: values[0],
          monthIncomeMinorUnits: values[1],
          monthExpenseMinorUnits: values[2],
          accountCount: counts[currency] ?? 0,
        );
      }).toList();
    } catch (_) {
      errorMessage = 'Could not load your financial overview. Please try again.';
    } finally {
      setBusy(false);
    }
  }

  String formatAmount(String currencyCode, int minorUnits) {
    final absolute = minorUnits.abs();
    final sign = minorUnits < 0 ? '-' : '';
    return '$currencyCode $sign${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
  }
}
