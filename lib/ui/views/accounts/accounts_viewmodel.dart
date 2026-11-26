import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:stacked/stacked.dart';

class AccountSummary {
  const AccountSummary({
    required this.account,
    required this.balanceMinorUnits,
  });

  final Account account;
  final int balanceMinorUnits;
}

class AccountsViewModel extends BaseViewModel {
  AccountsViewModel({LocalFinanceRepository? repository})
      : _repository = repository ?? locator<LocalFinanceRepository>();

  final LocalFinanceRepository _repository;

  List<AccountSummary> accountSummaries = [];
  String? errorMessage;

  Future<void> initialise() => loadAccounts();

  Future<void> loadAccounts() async {
    setBusy(true);
    errorMessage = null;
    try {
      final accounts = await _repository.getAccounts();
      accountSummaries = await Future.wait(
        accounts.map(
          (account) async => AccountSummary(
            account: account,
            balanceMinorUnits:
                await _repository.getAccountBalanceMinorUnits(account.id),
          ),
        ),
      );
    } catch (error) {
      errorMessage = _friendlyError(error);
    } finally {
      setBusy(false);
    }
  }

  Future<bool> saveAccount({
    String? id,
    required String name,
    required String accountType,
    required String currencyCode,
    int openingBalanceMinorUnits = 0,
  }) async {
    errorMessage = null;
    try {
      if (id == null) {
        await _repository.createAccount(
          name: name,
          accountType: accountType,
          currencyCode: currencyCode,
          openingBalanceMinorUnits: openingBalanceMinorUnits,
        );
      } else {
        await _repository.updateAccount(
          id: id,
          name: name,
          accountType: accountType,
          currencyCode: currencyCode,
        );
      }
      await loadAccounts();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> archiveAccount(String id) async {
    errorMessage = null;
    try {
      await _repository.archiveAccount(id);
      await loadAccounts();
      return errorMessage == null;
    } catch (error) {
      errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  String formatBalance(String currencyCode, int amountMinorUnits) {
    final absoluteAmount = amountMinorUnits.abs();
    final whole = absoluteAmount ~/ 100;
    final fraction = (absoluteAmount % 100).toString().padLeft(2, '0');
    final sign = amountMinorUnits < 0 ? '-' : '';
    return '$currencyCode $sign$whole.$fraction';
  }

  String _friendlyError(Object error) {
    if (error is ArgumentError || error is StateError) {
      return error.toString().replaceFirst(RegExp(r'^(Invalid argument\(s\): |Bad state: )'), '');
    }
    return 'Something went wrong. Please try again.';
  }
}
