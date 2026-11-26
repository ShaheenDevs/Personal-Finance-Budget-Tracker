// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Initial locator implementation following the Stacked service-locator
// conventions used by the Edge Market Flutter reference repository.
// Regenerate after changing dependency declarations in app.dart.

import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:stacked_shared/stacked_shared.dart';
import 'package:stacked_services/stacked_services.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
  locator.registerEnvironment(
    environment: environment,
    environmentFilter: environmentFilter,
  );

  locator.registerLazySingleton<NavigationService>(
    () => NavigationService(),
  );
  locator.registerLazySingleton<LocalFinanceRepository>(
    () => LocalFinanceRepository.create(),
  );
}
