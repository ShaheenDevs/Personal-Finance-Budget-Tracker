import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/main.dart';

void main() {
  testWidgets('app displays the initial dashboard', (tester) async {
    await tester.pumpWidget(const PersonalFinanceApp());

    expect(find.text('Personal Finance'), findsOneWidget);
    expect(find.text('Your financial overview starts here'), findsOneWidget);
  });
}
