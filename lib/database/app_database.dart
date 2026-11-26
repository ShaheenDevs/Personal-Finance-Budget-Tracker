import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/accounts.dart';
import 'tables/app_preferences.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/recurring_transactions.dart';
import 'tables/tags.dart';
import 'tables/transaction_tags.dart';
import 'tables/transactions.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    Tags,
    TransactionTags,
    Budgets,
    RecurringTransactions,
    AppPreferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'personal_finance'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
