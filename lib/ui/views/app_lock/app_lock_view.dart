import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_budget_tracker/services/app_security_service.dart';

class AppLockView extends StatefulWidget {
  const AppLockView({
    super.key,
    required this.securityService,
    required this.onUnlocked,
    this.loadError,
    this.onRetry,
  });

  final AppSecurityService securityService;
  final VoidCallback onUnlocked;
  final String? loadError;
  final VoidCallback? onRetry;

  @override
  State<AppLockView> createState() => _AppLockViewState();
}

class _AppLockViewState extends State<AppLockView> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final valid = await widget.securityService.verifyPin(_pinController.text);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _error = valid ? null : 'Incorrect PIN. Please try again.';
    });
    if (valid) widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 64),
                  const SizedBox(height: 20),
                  Text('App locked', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Enter your 6-digit PIN to access your finances.'),
                  if (widget.loadError != null) ...[
                    const SizedBox(height: 16),
                    Text(widget.loadError!, textAlign: TextAlign.center),
                    TextButton(onPressed: widget.onRetry, child: const Text('Retry')),
                  ],
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pinController,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: '6-digit PIN',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _checking || widget.loadError != null ? null : _unlock,
                      child: _checking
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Unlock'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
