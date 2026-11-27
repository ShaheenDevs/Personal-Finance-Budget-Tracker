import 'package:flutter/material.dart';
import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/services/app_security_service.dart';
import 'package:personal_finance_budget_tracker/ui/views/app_lock/app_lock_view.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child, this.securityService});

  final AppSecurityService? securityService;

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  late final AppSecurityService _security;
  bool _loading = true;
  bool _enabled = false;
  bool _locked = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _security = widget.securityService ?? locator<AppSecurityService>();
    WidgetsBinding.instance.addObserver(this);
    _loadLockState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_enabled &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden)) {
      if (mounted && !_locked) {
        setState(() => _locked = true);
      }
    }
  }

  Future<void> _loadLockState() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final enabled = await _security.isLockEnabled;
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
        _locked = enabled;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enabled = true;
        _locked = true;
        _loading = false;
        _loadError = 'Secure storage is unavailable. Your financial data remains locked.';
      });
    }
  }

  Future<void> _unlock() async {
    if (!mounted) return;
    setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Material(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_locked) {
      return AppLockView(
        securityService: _security,
        loadError: _loadError,
        onRetry: _loadLockState,
        onUnlocked: _unlock,
      );
    }
    return widget.child;
  }
}
