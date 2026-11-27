import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/services/app_security_service.dart';
import 'package:personal_finance_budget_tracker/ui/views/settings/settings_viewmodel.dart';

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

void main() {
  late AppSecurityService security;
  late SettingsViewModel viewModel;

  setUp(() {
    security = AppSecurityService(store: MemorySecureStore());
    viewModel = SettingsViewModel(securityService: security);
  });

  test('loads disabled state and enables app lock with a valid PIN', () async {
    await viewModel.initialise();
    expect(viewModel.lockEnabled, isFalse);

    expect(await viewModel.enableWithPin('246810'), isTrue);
    expect(viewModel.lockEnabled, isTrue);
    expect(await security.verifyPin('246810'), isTrue);
  });

  test('requires the current PIN before disabling app lock', () async {
    await security.enableWithPin('246810');
    await viewModel.initialise();

    expect(await viewModel.disableWithPin('000000'), isFalse);
    expect(viewModel.lockEnabled, isTrue);
    expect(viewModel.errorMessage, 'Incorrect PIN.');

    expect(await viewModel.disableWithPin('246810'), isTrue);
    expect(viewModel.lockEnabled, isFalse);
  });
}
