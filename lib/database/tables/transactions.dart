import 'package:drift/drift.dart';
import 'accounts.dart';
import 'categories.dart';

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

  @override
  List<Set<Column<Object>>> get indexes => [
        {accountId, transactionDate},
        {categoryId, transactionDate},
      ];
}
