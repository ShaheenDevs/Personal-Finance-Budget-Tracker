import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:stacked/stacked.dart';

class TransactionListItem {
  const TransactionListItem({
    required this.transaction,
    required this.accountName,
    required this.categoryName,
    required this.tagIds,
    required this.tagNames,
  });

  final FinanceTransaction transaction;
  final String accountName;
  final String? categoryName;
  final List<String> tagIds;
  final List<String> tagNames;
}

class TransactionsViewModel extends BaseViewModel {
  TransactionsViewModel({LocalFinanceRepository? repository})
      : _repository = repository ?? locator<LocalFinanceRepository>();

  final LocalFinanceRepository _repository;

  List<Account> accounts = [];
  List<Category> categories = [];
  List<Tag> tags = [];
  List<TransactionListItem> transactionItems = [];
  String? errorMessage;
  String searchQuery = '';
  String selectedType = 'all';
  String? selectedAccountId;
  DateTime? dateFrom;
  DateTime? dateTo;
  bool newestFirst = true;

  List<TransactionListItem> get filteredTransactionItems {
    final query = searchQuery.trim().toLowerCase();
    final items = transactionItems.where((item) {
      final transaction = item.transaction;
      if (selectedType != 'all' && transaction.transactionType != selectedType) {
        return false;
      }
      if (selectedAccountId != null && transaction.accountId != selectedAccountId) {
        return false;
      }
      final date = transaction.transactionDate;
      if (dateFrom != null &&
          date.isBefore(DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day))) {
        return false;
      }
      if (dateTo != null &&
          date.isAfter(DateTime(dateTo!.year, dateTo!.month, dateTo!.day, 23, 59, 59))) {
        return false;
      }
      if (query.isEmpty) return true;
      final searchable = [
        transaction.note ?? '',
        item.accountName,
        item.categoryName ?? '',
        transaction.currencyCode,
        ...item.tagNames,
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
    items.sort((a, b) {
      final comparison = a.transaction.transactionDate.compareTo(
        b.transaction.transactionDate,
      );
      return newestFirst ? -comparison : comparison;
    });
    return items;
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void updateType(String value) {
    selectedType = value;
    notifyListeners();
  }

  void updateAccount(String? value) {
    selectedAccountId = value;
    notifyListeners();
  }

  void updateDateRange(DateTimeRange? range) {
    dateFrom = range?.start;
    dateTo = range?.end;
    notifyListeners();
  }

  void toggleSortOrder() {
    newestFirst = !newestFirst;
    notifyListeners();
  }

  void clearFilters() {
    searchQuery = '';
    selectedType = 'all';
    selectedAccountId = null;
    dateFrom = null;
    dateTo = null;
    newestFirst = true;
    notifyListeners();
  }

  List<Account> get activeAccounts =>
      accounts.where((account) => !account.archived).toList();

  Future<void> initialise() => loadTransactions();

  Future<void> loadTransactions() async {
    setBusy(true);
    errorMessage = null;
    try {
      final results = await Future.wait([
        _repository.getAccounts(),
        _repository.getCategories(),
        _repository.getTags(),
        _repository.getTransactions(),
      ]);
      accounts = results[0] as List<Account>;
      categories = results[1] as List<Category>;
      tags = results[2] as List<Tag>;
      final transactions = results[3] as List<FinanceTransaction>;

      final accountNames = {for (final account in accounts) account.id: account.name};
      final categoryNames = {
        for (final category in categories) category.id: category.name,
      };
      final tagNames = {for (final tag in tags) tag.id: tag.name};

      transactionItems = await Future.wait(
        transactions.map((transaction) async {
          final tagIds =
              await _repository.getTagIdsForTransaction(transaction.id);
          return TransactionListItem(
            transaction: transaction,
            accountName: accountNames[transaction.accountId] ?? 'Unknown account',
            categoryName: transaction.categoryId == null
                ? null
                : categoryNames[transaction.categoryId],
            tagIds: tagIds,
            tagNames: tagIds
                .map((tagId) => tagNames[tagId])
                .whereType<String>()
                .toList(),
          );
        }),
      );
    } catch (error) {
      errorMessage = _friendlyError(error);
    } finally {
      setBusy(false);
    }
  }

  Future<bool> saveTransaction({
    String? id,
    required String accountId,
    String? categoryId,
    required String transactionType,
    required int amountMinorUnits,
    required DateTime transactionDate,
    String? note,
    List<String> tagIds = const [],
  }) async {
    errorMessage = null;
    try {
      final account = accounts.firstWhere(
        (item) => item.id == accountId,
        orElse: () => throw ArgumentError('Select a valid account.'),
      );
      if (id == null) {
        await _repository.createTransaction(
          accountId: accountId,
          categoryId: categoryId,
          transactionType: transactionType,
          amountMinorUnits: amountMinorUnits,
          currencyCode: account.currencyCode,
          transactionDate: transactionDate,
          note: note,
          tagIds: tagIds,
        );
      } else {
        await _repository.updateTransaction(
          id: id,
          accountId: accountId,
          categoryId: categoryId,
          transactionType: transactionType,
          amountMinorUnits: amountMinorUnits,
          currencyCode: account.currencyCode,
          transactionDate: transactionDate,
          note: note,
          tagIds: tagIds,
        );
      }
      await loadTransactions();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    errorMessage = null;
    try {
      await _repository.deleteTransaction(id);
      await loadTransactions();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  String formatAmount(String currencyCode, int amountMinorUnits) {
    final absoluteAmount = amountMinorUnits.abs();
    final whole = absoluteAmount ~/ 100;
    final fraction = (absoluteAmount % 100).toString().padLeft(2, '0');
    final sign = amountMinorUnits < 0 ? '-' : '';
    return '$currencyCode $sign$whole.$fraction';
  }

  String _friendlyError(Object error) {
    if (error is ArgumentError || error is StateError) {
      return error.toString().replaceFirst(
            RegExp(r'^(Invalid argument\(s\): |Bad state: )'),
            '',
          );
    }
    return 'Something went wrong. Please try again.';
  }
}
