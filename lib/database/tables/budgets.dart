import 'package:drift/drift.dart';
import 'categories.dart';

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable().references(
        Categories,
        #id,
        onDelete: KeyAction.setNull,
      )();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();
  TextColumn get periodType => text().withLength(min: 1, max: 20)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
