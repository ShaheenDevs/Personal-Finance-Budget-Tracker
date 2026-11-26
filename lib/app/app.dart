import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/dashboard/dashboard_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_shared/stacked_shared.dart';

// Stacked configuration source. Regenerate locator/router with build_runner
// when routes or registered dependencies change.
@StackedApp(
  routes: [
    MaterialRoute(page: DashboardView, initial: true),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: AppDatabase),
    LazySingleton(
      classType: LocalFinanceRepository,
      resolveUsing: resolveLocalFinanceRepository,
    ),
  ],
)
class App {}

LocalFinanceRepository resolveLocalFinanceRepository() {
  final locator = StackedLocator.instance;
  return LocalFinanceRepository(locator<AppDatabase>());
}
