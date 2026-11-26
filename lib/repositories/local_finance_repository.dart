import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class LocalFinanceRepository {
  LocalFinanceRepository([AppDatabase? database])
      : _database = database ?? AppDatabase();

  final AppDatabase _database;
  static const Uuid _uuid = Uuid();

  Stream<List<Account>> watchAccounts() {
    return (_database.select(_database.accounts)
          ..orderBy([(account) => OrderingTerm.asc(account.name)]))
        .watch();
  }

  Future<List<Account>> getAccounts() {
    return (_database.select(_database.accounts)
          ..orderBy([(account) => OrderingTerm.asc(account.name)]))
        .get();
  }

  Future<int> createAccount({
    required String name,
    required String accountType,
    required String currencyCode,
    int openingBalanceMinorUnits = 0,
  }) {
    return _database.into(_database.accounts).insert(
          AccountsCompanion.insert(
            id: _uuid.v4(),
            name: name.trim(),
            accountType: accountType,
            currencyCode: currencyCode.toUpperCase(),
            openingBalanceMinorUnits: Value(openingBalanceMinorUnits),
          ),
        );
  }

  Future<int> createCategory({
    required String name,
    required String transactionType,
    bool isBuiltIn = false,
  }) {
    return _database.into(_database.categories).insert(
          CategoriesCompanion.insert(
            id: _uuid.v4(),
            name: name.trim(),
            transactionType: transactionType,
            isBuiltIn: Value(isBuiltIn),
          ),
        );
  }

  Future<int> createTransaction({
    required String accountId,
    String? categoryId,
    required String transactionType,
    required int amountMinorUnits,
    required String currencyCode,
    required DateTime transactionDate,
    String? note,
  }) {
    if (amountMinorUnits <= 0) {
      throw ArgumentError.value(
        amountMinorUnits,
        'amountMinorUnits',
        'Transaction amount must be greater than zero.',
      );
    }

    return _database.into(_database.transactions).insert(
          TransactionsCompanion.insert(
            id: _uuid.v4(),
            accountId: accountId,
            categoryId: Value(categoryId),
            transactionType: transactionType,
            amountMinorUnits: amountMinorUnits,
            currencyCode: currencyCode.toUpperCase(),
            note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
            transactionDate: transactionDate,
          ),
        );
  }

  Future<void> close() => _database.close();
}
