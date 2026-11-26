import 'package:drift/drift.dart';
import 'tags.dart';
import 'transactions.dart';

class TransactionTags extends Table {
  TextColumn get transactionId => text().references(
        Transactions,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get tagId => text().references(
        Tags,
        #id,
        onDelete: KeyAction.cascade,
      )();

  @override
  Set<Column<Object>> get primaryKey => {transactionId, tagId};
}
