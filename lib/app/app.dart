import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/dashboard/dashboard_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// Stacked configuration source. Regenerate locator/router with build_runner
// when routes or registered dependencies change.
@StackedApp(
  routes: [
    MaterialRoute(page: DashboardView, initial: true),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: AppDatabase),
    LazySingleton(classType: LocalFinanceRepository),
  ],
)
class App {}
