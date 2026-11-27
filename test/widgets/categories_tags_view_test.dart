import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/categories_tags/categories_tags_view.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int attempts = 30,
}) async {
  for (var i = 0; i < attempts; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Widget not found after waiting: $finder');
}

void main() {
  late AppDatabase database;
  late LocalFinanceRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalFinanceRepository(database);
  });

  tearDown(() async {
    await repository.close();
  });

  testWidgets('creates income category and tag from the management screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CategoriesTagsView(repository: repository)),
    );
    await pumpUntilFound(tester, find.text('Income categories'));

    await tester.tap(find.byTooltip('Add Income categories'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Salary');
    await tester.tap(find.text('Add category'));
    await pumpUntilFound(tester, find.text('Salary'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add Tags'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Essential');
    await tester.tap(find.text('Add tag').last);
    await tester.pumpAndSettle();
    expect(find.text('Essential'), findsOneWidget);

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Essential'), findsOneWidget);
  });
  testWidgets('renames and deletes an unused category', (tester) async {
    await repository.createCategory(name: 'Temporary', transactionType: 'expense');
    await tester.pumpWidget(MaterialApp(home: CategoriesTagsView(repository: repository)));
    await pumpUntilFound(tester, find.text('Temporary'));
    await tester.tap(find.byTooltip('Manage Temporary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Groceries');
    await tester.tap(find.text('Save'));
    await pumpUntilFound(tester, find.text('Groceries'));
    expect(find.text('Temporary'), findsNothing);
    await tester.tap(find.byTooltip('Manage Groceries'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('Groceries'), findsNothing);
  });

}
