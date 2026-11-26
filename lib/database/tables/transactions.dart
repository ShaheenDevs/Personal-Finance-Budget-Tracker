import 'package:drift/drift.dart';
import 'accounts.dart';
import 'categories.dart';

@TableIndex(name: 'transactions_account_date', columns: {#accountId, #transactionDate})
@TableIndex(name: 'transactions_category_date', columns: {#categoryId, #transactionDate})
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().references(
        Accounts,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get categoryId => text().nullable().references(
        Categories,
        #id,
        onDelete: KeyAction.setNull,
      )();
  TextColumn get transactionType => text().withLength(min: 1, max: 20)();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
