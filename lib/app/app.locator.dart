// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This initial locator follows the generated locator conventions in the
// Edge Market Flutter reference repository. Re-run build_runner after
// changing the @StackedApp dependency declarations in app.dart.

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
}
