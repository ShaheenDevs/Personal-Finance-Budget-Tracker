import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/services/app_security_service.dart';
import 'package:stacked/stacked.dart';

class SettingsViewModel extends BaseViewModel {
  SettingsViewModel({AppSecurityService? securityService})
      : _security = securityService ?? locator<AppSecurityService>();

  final AppSecurityService _security;
  bool lockEnabled = false;
  String? errorMessage;
  String? successMessage;

  Future<void> initialise() async {
    setBusy(true);
    errorMessage = null;
    try {
      lockEnabled = await _security.isLockEnabled;
    } catch (_) {
      errorMessage = 'Could not read secure settings. Please try again.';
    } finally {
      setBusy(false);
    }
  }

  Future<bool> enableWithPin(String pin) async {
    setBusy(true);
    errorMessage = null;
    successMessage = null;
    try {
      await _security.enableWithPin(pin);
      lockEnabled = true;
      successMessage = 'App lock is enabled.';
      return true;
    } catch (error) {
      errorMessage = error is ArgumentError
          ? 'Enter exactly 6 digits for your PIN.'
          : 'Could not enable app lock. Please try again.';
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> disableWithPin(String pin) async {
    setBusy(true);
    errorMessage = null;
    successMessage = null;
    try {
      final valid = await _security.verifyPin(pin);
      if (!valid) {
        errorMessage = 'Incorrect PIN.';
        return false;
      }
      await _security.disableLock();
      lockEnabled = false;
      successMessage = 'App lock is disabled.';
      return true;
    } catch (_) {
      errorMessage = 'Could not update app lock. Please try again.';
      return false;
    } finally {
      setBusy(false);
    }
  }
}
