import 'package:flutter_test/flutter_test.dart';
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

void main() {
  late MemorySecureStore store;
  late AppSecurityService service;

  setUp(() {
    store = MemorySecureStore();
    service = AppSecurityService(store: store);
  });

  test('rejects a PIN that is not exactly six digits', () async {
    await expectLater(service.enableWithPin('1234'), throwsArgumentError);
    expect(await service.isLockEnabled, isFalse);
  });

  test('stores a salted hash and verifies only the correct PIN', () async {
    await service.enableWithPin('123456');

    expect(await service.isLockEnabled, isTrue);
    expect(store.values.containsValue('123456'), isFalse);
    expect(await service.verifyPin('123456'), isTrue);
    expect(await service.verifyPin('654321'), isFalse);
  });

  test('disabling app lock removes the stored PIN material', () async {
    await service.enableWithPin('123456');
    await service.disableLock();

    expect(await service.isLockEnabled, isFalse);
    expect(await service.verifyPin('123456'), isFalse);
    expect(store.values, isEmpty);
  });
}
