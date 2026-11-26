import 'package:drift/drift.dart';
import 'accounts.dart';
import 'categories.dart';

class RecurringTransactions extends Table {
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
  TextColumn get frequency => text().withLength(min: 1, max: 20)();
  DateTimeColumn get nextDueDate => dateTime()();
  TextColumn get timeZoneId => text().withDefault(const Constant('UTC'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
