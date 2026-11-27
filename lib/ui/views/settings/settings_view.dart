import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_budget_tracker/ui/views/settings/settings_viewmodel.dart';
import 'package:stacked/stacked.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({super.key});

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) => SettingsViewModel();

  @override
  void onViewModelReady(SettingsViewModel viewModel) => viewModel.initialise();

  Future<String?> _requestPin(BuildContext context, {required bool confirm}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(confirm ? 'Confirm current PIN' : 'Set a 6-digit PIN'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(
            labelText: '6-digit PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(confirm ? 'Turn off' : 'Enable lock'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Security', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              value: viewModel.lockEnabled,
              onChanged: viewModel.isBusy
                  ? null
                  : (enabled) async {
                      if (enabled) {
                        final pin = await _requestPin(context, confirm: false);
                        if (pin != null) await viewModel.enableWithPin(pin);
                      } else {
                        final pin = await _requestPin(context, confirm: true);
                        if (pin != null) await viewModel.disableWithPin(pin);
                      }
                    },
              title: const Text('App lock'),
              subtitle: Text(viewModel.lockEnabled
                  ? 'Require your PIN when you return to the app.'
                  : 'Protect this app with a secure 6-digit PIN.'),
              secondary: const Icon(Icons.lock_outline),
            ),
          ),
          if (viewModel.isBusy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          if (viewModel.successMessage != null) ...[
            const SizedBox(height: 12),
            Text(viewModel.successMessage!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
          const SizedBox(height: 24),
          Text('More settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.tune),
              title: Text('Preferences and premium access'),
              subtitle: Text('Additional settings and feature access controls are planned for the next M7 steps.'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your PIN is protected using Android secure storage and a salted PBKDF2-SHA256 hash. It is not stored as plain text.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
