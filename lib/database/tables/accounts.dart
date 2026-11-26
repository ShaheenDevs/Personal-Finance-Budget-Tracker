import 'package:drift/drift.dart';

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get accountType => text().withLength(min: 1, max: 30)();
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();
  IntColumn get openingBalanceMinorUnits => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
