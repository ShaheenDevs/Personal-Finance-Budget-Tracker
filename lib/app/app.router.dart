import 'package:flutter/material.dart';
import 'package:personal_finance_budget_tracker/ui/views/dashboard/dashboard_view.dart';

class Routes {
  static const dashboardView = '/dashboard-view';

  static const all = <String>{dashboardView};
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.dashboardView:
      case Navigator.defaultRouteName:
        return MaterialPageRoute<void>(
          builder: (_) => const DashboardView(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
