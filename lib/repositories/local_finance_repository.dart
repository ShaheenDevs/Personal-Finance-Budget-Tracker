import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class LocalFinanceRepository {
  LocalFinanceRepository([AppDatabase? database])
      : _database = database ?? AppDatabase();

  final AppDatabase _database;
  static const Uuid _uuid = Uuid();
  static const Set<String> _transactionTypes = {'income', 'expense'};
  static const Set<String> _accountTypes = {'cash', 'bank', 'wallet'};

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
    final normalizedName = name.trim();
    final normalizedCurrency = currencyCode.trim().toUpperCase();
    _validateAccountType(accountType);
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Account name is required.');
    }
    if (!_isCurrencyCode(normalizedCurrency)) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Use a three-letter ISO currency code.',
      );
    }

    return _database.into(_database.accounts).insert(
          AccountsCompanion.insert(
            id: _uuid.v4(),
            name: normalizedName,
            accountType: accountType,
            currencyCode: normalizedCurrency,
            openingBalanceMinorUnits: Value(openingBalanceMinorUnits),
          ),
        );
  }

  Future<int> updateAccount({
    required String id,
    required String name,
    required String accountType,
    required String currencyCode,
  }) async {
    final normalizedName = name.trim();
    final normalizedCurrency = currencyCode.trim().toUpperCase();
    _validateAccountType(accountType);
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Account name is required.');
    }
    if (!_isCurrencyCode(normalizedCurrency)) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Use a three-letter ISO currency code.',
      );
    }

    final existing = await (_database.select(_database.accounts)
          ..where((account) => account.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      throw ArgumentError.value(id, 'id', 'Account not found.');
    }
    if (existing.currencyCode != normalizedCurrency) {
      final existingTransactions = await (_database.select(_database.transactions)
            ..where((row) => row.accountId.equals(id)))
          .get();
      if (existingTransactions.isNotEmpty) {
        throw StateError(
          'Account currency cannot change after transactions are recorded.',
        );
      }
    }

    return (_database.update(_database.accounts)
          ..where((account) => account.id.equals(id)))
        .write(
      AccountsCompanion(
        name: Value(normalizedName),
        accountType: Value(accountType),
        currencyCode: Value(normalizedCurrency),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> archiveAccount(String id) {
    return (_database.update(_database.accounts)
          ..where((account) => account.id.equals(id)))
        .write(
      AccountsCompanion(
        archived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> getAccountBalanceMinorUnits(String accountId) async {
    final account = await (_database.select(_database.accounts)
          ..where((row) => row.id.equals(accountId)))
        .getSingleOrNull();
    if (account == null) {
      throw ArgumentError.value(accountId, 'accountId', 'Account not found.');
    }

    final transactions = await (_database.select(_database.transactions)
          ..where(
            (row) =>
                row.accountId.equals(accountId) & row.deletedAt.isNull(),
          ))
        .get();

    return transactions.fold<int>(
      account.openingBalanceMinorUnits,
      (balance, transaction) => transaction.transactionType == 'income'
          ? balance + transaction.amountMinorUnits
          : balance - transaction.amountMinorUnits,
    );
  }

  Stream<List<Category>> watchCategories({String? transactionType}) {
    final query = _database.select(_database.categories)
      ..orderBy([(category) => OrderingTerm.asc(category.name)]);
    if (transactionType != null) {
      query.where((category) => category.transactionType.equals(transactionType));
    }
    return query.watch();
  }

  Future<List<Category>> getCategories({String? transactionType}) {
    final query = _database.select(_database.categories)
      ..orderBy([(category) => OrderingTerm.asc(category.name)]);
    if (transactionType != null) {
      query.where((category) => category.transactionType.equals(transactionType));
    }
    return query.get();
  }

  Future<int> createCategory({
    required String name,
    required String transactionType,
    bool isBuiltIn = false,
  }) {
    final normalizedName = name.trim();
    _validateTransactionType(transactionType);
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name is required.');
    }

    return _database.into(_database.categories).insert(
          CategoriesCompanion.insert(
            id: _uuid.v4(),
            name: normalizedName,
            transactionType: transactionType,
            isBuiltIn: Value(isBuiltIn),
          ),
        );
  }

  Future<int> renameCategory({required String id, required String name}) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name is required.');
    }
    final category = await (_database.select(_database.categories)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (category == null) {
      throw ArgumentError.value(id, 'id', 'Category not found.');
    }
    return (_database.update(_database.categories)
          ..where((row) => row.id.equals(id)))
        .write(CategoriesCompanion(name: Value(normalizedName)));
  }

  Future<int> deleteCategory(String id) async {
    final category = await (_database.select(_database.categories)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (category == null) {
      throw ArgumentError.value(id, 'id', 'Category not found.');
    }
    if (category.isBuiltIn) {
      throw StateError('Built-in categories cannot be deleted.');
    }
    final linkedTransactions = await (_database.select(_database.transactions)
          ..where((row) => row.categoryId.equals(id)))
        .get();
    if (linkedTransactions.isNotEmpty) {
      throw StateError('This category is used by transactions and cannot be deleted.');
    }
    return (_database.delete(_database.categories)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  Stream<List<Tag>> watchTags() {
    return (_database.select(_database.tags)
          ..orderBy([(tag) => OrderingTerm.asc(tag.name)]))
        .watch();
  }

  Future<List<Tag>> getTags() {
    return (_database.select(_database.tags)
          ..orderBy([(tag) => OrderingTerm.asc(tag.name)]))
        .get();
  }

  Future<List<String>> getTagIdsForTransaction(String transactionId) async {
    final links = await (_database.select(_database.transactionTags)
          ..where((row) => row.transactionId.equals(transactionId)))
        .get();
    return links.map((link) => link.tagId).toList();
  }

  Future<int> createTag({required String name}) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Tag name is required.');
    }

    return _database.into(_database.tags).insert(
          TagsCompanion.insert(
            id: _uuid.v4(),
            name: normalizedName,
          ),
        );
  }

  Future<int> renameTag({required String id, required String name}) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Tag name is required.');
    }
    final tag = await (_database.select(_database.tags)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (tag == null) {
      throw ArgumentError.value(id, 'id', 'Tag not found.');
    }
    return (_database.update(_database.tags)
          ..where((row) => row.id.equals(id)))
        .write(TagsCompanion(name: Value(normalizedName)));
  }

  Future<int> deleteTag(String id) async {
    final tag = await (_database.select(_database.tags)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (tag == null) {
      throw ArgumentError.value(id, 'id', 'Tag not found.');
    }
    final linkedTransactions = await (_database.select(_database.transactionTags)
          ..where((row) => row.tagId.equals(id)))
        .get();
    if (linkedTransactions.isNotEmpty) {
      throw StateError('This tag is used by transactions and cannot be deleted.');
    }
    return (_database.delete(_database.tags)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  Stream<List<FinanceTransaction>> watchTransactions({String? accountId}) {
    final query = _database.select(_database.transactions)
      ..where(
        (row) =>
            row.deletedAt.isNull() &
            (accountId == null
                ? const Constant(true)
                : row.accountId.equals(accountId)),
      )
      ..orderBy([
        (row) => OrderingTerm.desc(row.transactionDate),
        (row) => OrderingTerm.desc(row.createdAt),
      ]);
    return query.watch();
  }

  Future<List<FinanceTransaction>> getTransactions({String? accountId}) {
    final query = _database.select(_database.transactions)
      ..where(
        (row) =>
            row.deletedAt.isNull() &
            (accountId == null
                ? const Constant(true)
                : row.accountId.equals(accountId)),
      )
      ..orderBy([
        (row) => OrderingTerm.desc(row.transactionDate),
        (row) => OrderingTerm.desc(row.createdAt),
      ]);
    return query.get();
  }

  Future<int> createTransaction({
    required String accountId,
    String? categoryId,
    required String transactionType,
    required int amountMinorUnits,
    required String currencyCode,
    required DateTime transactionDate,
    String? note,
    List<String> tagIds = const [],
  }) {
    return _database.transaction(() async {
      await _validateTransactionInput(
        accountId: accountId,
        categoryId: categoryId,
        transactionType: transactionType,
        amountMinorUnits: amountMinorUnits,
        currencyCode: currencyCode,
        tagIds: tagIds,
      );

      final transactionId = _uuid.v4();
      final rowId = await _database.into(_database.transactions).insert(
            TransactionsCompanion.insert(
              id: transactionId,
              accountId: accountId,
              categoryId: Value(categoryId),
              transactionType: transactionType,
              amountMinorUnits: amountMinorUnits,
              currencyCode: currencyCode.trim().toUpperCase(),
              note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
              transactionDate: transactionDate,
            ),
          );
      await _replaceTransactionTags(transactionId, tagIds);
      return rowId;
    });
  }

  Future<int> updateTransaction({
    required String id,
    required String accountId,
    String? categoryId,
    required String transactionType,
    required int amountMinorUnits,
    required String currencyCode,
    required DateTime transactionDate,
    String? note,
    List<String> tagIds = const [],
  }) {
    return _database.transaction(() async {
      final existing = await (_database.select(_database.transactions)
            ..where((row) => row.id.equals(id) & row.deletedAt.isNull()))
          .getSingleOrNull();
      if (existing == null) {
        throw ArgumentError.value(id, 'id', 'Transaction not found.');
      }

      await _validateTransactionInput(
        accountId: accountId,
        categoryId: categoryId,
        transactionType: transactionType,
        amountMinorUnits: amountMinorUnits,
        currencyCode: currencyCode,
        tagIds: tagIds,
      );

      final changed = await (_database.update(_database.transactions)
            ..where((row) => row.id.equals(id) & row.deletedAt.isNull()))
          .write(
        TransactionsCompanion(
          accountId: Value(accountId),
          categoryId: Value(categoryId),
          transactionType: Value(transactionType),
          amountMinorUnits: Value(amountMinorUnits),
          currencyCode: Value(currencyCode.trim().toUpperCase()),
          note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
          transactionDate: Value(transactionDate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _replaceTransactionTags(id, tagIds);
      return changed;
    });
  }

  Future<int> deleteTransaction(String id) {
    return (_database.update(_database.transactions)
          ..where((row) => row.id.equals(id) & row.deletedAt.isNull()))
        .write(
      TransactionsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _validateTransactionInput({
    required String accountId,
    required String? categoryId,
    required String transactionType,
    required int amountMinorUnits,
    required String currencyCode,
    required List<String> tagIds,
  }) async {
    _validateTransactionType(transactionType);
    if (amountMinorUnits <= 0) {
      throw ArgumentError.value(
        amountMinorUnits,
        'amountMinorUnits',
        'Transaction amount must be greater than zero.',
      );
    }

    final account = await (_database.select(_database.accounts)
          ..where((row) => row.id.equals(accountId)))
        .getSingleOrNull();
    if (account == null) {
      throw ArgumentError.value(accountId, 'accountId', 'Account not found.');
    }
    if (account.archived) {
      throw StateError('Archived accounts cannot receive new transactions.');
    }
    if (account.currencyCode != currencyCode.trim().toUpperCase()) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Transaction currency must match the account currency.',
      );
    }

    if (categoryId != null) {
      final category = await (_database.select(_database.categories)
            ..where((row) => row.id.equals(categoryId)))
          .getSingleOrNull();
      if (category == null || category.transactionType != transactionType) {
        throw ArgumentError.value(
          categoryId,
          'categoryId',
          'Category must exist and match the transaction type.',
        );
      }
    }

    final uniqueTagIds = tagIds.toSet();
    if (uniqueTagIds.isNotEmpty) {
      final tags = await (_database.select(_database.tags)
            ..where((row) => row.id.isIn(uniqueTagIds)))
          .get();
      if (tags.length != uniqueTagIds.length) {
        throw ArgumentError.value(tagIds, 'tagIds', 'One or more tags do not exist.');
      }
    }
  }

  Future<void> _replaceTransactionTags(
    String transactionId,
    List<String> tagIds,
  ) async {
    await (_database.delete(_database.transactionTags)
          ..where((row) => row.transactionId.equals(transactionId)))
        .go();

    for (final tagId in tagIds.toSet()) {
      await _database.into(_database.transactionTags).insert(
            TransactionTagsCompanion.insert(
              transactionId: transactionId,
              tagId: tagId,
            ),
          );
    }
  }

  bool _isCurrencyCode(String currencyCode) {
    return currencyCode.length == 3 &&
        currencyCode.codeUnits.every((code) => code >= 65 && code <= 90);
  }

  void _validateAccountType(String accountType) {
    if (!_accountTypes.contains(accountType)) {
      throw ArgumentError.value(
        accountType,
        'accountType',
        'Account type must be cash, bank, or wallet.',
      );
    }
  }

  void _validateTransactionType(String transactionType) {
    if (!_transactionTypes.contains(transactionType)) {
      throw ArgumentError.value(
        transactionType,
        'transactionType',
        'Transaction type must be income or expense.',
      );
    }
  }

  Future<void> close() => _database.close();
}
