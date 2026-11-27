import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/accounts/accounts_view.dart';
import 'package:personal_finance_budget_tracker/ui/views/dashboard/dashboard_view.dart';
import 'package:personal_finance_budget_tracker/ui/views/categories_tags/categories_tags_view.dart';
import 'package:personal_finance_budget_tracker/ui/views/budgets/budgets_view.dart';
import 'package:personal_finance_budget_tracker/ui/views/transactions/transactions_view.dart';
import 'package:personal_finance_budget_tracker/ui/views/reports/reports_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// Stacked configuration source. Regenerate locator/router with build_runner
// when routes or registered dependencies change.
@StackedApp(
  routes: [
    MaterialRoute(page: DashboardView, initial: true),
    MaterialRoute(page: AccountsView),
    MaterialRoute(page: TransactionsView),
    MaterialRoute(page: CategoriesTagsView),
    MaterialRoute(page: BudgetsView),
    MaterialRoute(page: ReportsView),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: LocalFinanceRepository),
  ],
)
class App {}