import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_budget_tracker/services/app_security_service.dart';
import 'package:personal_finance_budget_tracker/ui/views/app_lock/app_lock_gate.dart';

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
  testWidgets('locks on startup and again when app moves to background', (tester) async {
    final security = AppSecurityService(
      store: MemorySecureStore(),
      iterations: 1000,
    );
    await security.enableWithPin('135790');

    await tester.pumpWidget(
      MaterialApp(
        home: AppLockGate(
        securityService: security,
          child: const Scaffold(body: Text('Private dashboard')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App locked'), findsOneWidget);
    expect(find.text('Private dashboard'), findsNothing);

    await tester.enterText(find.byType(TextField), '135790');
    await tester.tap(find.text('Unlock'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Private dashboard'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(find.text('App locked'), findsOneWidget);
  });
}
