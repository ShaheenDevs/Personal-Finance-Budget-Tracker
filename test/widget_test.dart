import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/main.dart';
import 'package:personal_finance_budget_tracker/services/app_security_service.dart';

class MemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

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
  testWidgets('dashboard opens the account screen and add-account form', (tester) async {
    await setupLocator();
    final security = AppSecurityService(store: MemorySecureStore());
    await tester.pumpWidget(PersonalFinanceApp(securityService: security));

    await pumpUntilFound(tester, find.text('Personal Finance'));
    await pumpUntilFound(tester, find.text('Manage accounts'));

    await tester.tap(find.text('Manage accounts'));
    await pumpUntilFound(tester, find.text('Accounts'));

    await tester.tap(find.text('Add account'));
    await tester.pump();

    expect(find.text('Account name'), findsOneWidget);
    expect(find.text('Account type'), findsOneWidget);
    expect(find.text('Currency code'), findsOneWidget);
    expect(find.text('Opening balance'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('Create account'), findsNothing);
  });
}
