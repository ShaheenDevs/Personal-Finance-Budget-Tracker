import 'package:personal_finance_budget_tracker/ui/views/dashboard/dashboard_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// Stacked configuration source. Generated locator and router files are kept
// alongside this file to match the reference repository's conventions.
@StackedApp(
  routes: [
    MaterialRoute(page: DashboardView, initial: true),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
  ],
)
class App {}
