import 'package:flutter/material.dart';
import 'package:personal_finance_budget_tracker/app/app_theme.dart';
import 'package:personal_finance_budget_tracker/database/app_database.dart';
import 'package:personal_finance_budget_tracker/ui/views/accounts/accounts_viewmodel.dart';
import 'package:stacked/stacked.dart';

class AccountsView extends StackedView<AccountsViewModel> {
  const AccountsView({super.key});

  @override
  AccountsViewModel viewModelBuilder(BuildContext context) =>
      AccountsViewModel();

  @override
  void onViewModelReady(AccountsViewModel viewModel) {
    viewModel.initialise();
  }

  @override
  Widget builder(
    BuildContext context,
    AccountsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountForm(context, viewModel),
        icon: const Icon(Icons.add),
        label: const Text('Add account'),
      ),
      body: SafeArea(
        child: viewModel.isBusy && viewModel.accountSummaries.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: viewModel.loadAccounts,
                child: viewModel.accountSummaries.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 100),
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 56,
                            color: AppTheme.primary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No accounts yet',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a cash, bank, or wallet account to start tracking your money.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        children: [
                          if (viewModel.errorMessage != null)
                            _ErrorBanner(message: viewModel.errorMessage!),
                          Text(
                            'Your money accounts',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          for (final summary in viewModel.accountSummaries)
                            _AccountCard(
                              summary: summary,
                              viewModel: viewModel,
                              onEdit: () => _showAccountForm(
                                context,
                                viewModel,
                                account: summary.account,
                              ),
                              onArchive: () =>
                                  _confirmArchive(context, viewModel, summary.account),
                            ),
                        ],
                      ),
              ),
      ),
    );
  }

  Future<void> _showAccountForm(
    BuildContext context,
    AccountsViewModel viewModel, {
    Account? account,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AccountFormDialog(
        viewModel: viewModel,
        account: account,
      ),
    );
  }

  Future<void> _confirmArchive(
    BuildContext context,
    AccountsViewModel viewModel,
    Account account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive account?'),
        content: Text(
          '“${account.name}” will be hidden from new transaction entry. Its existing transactions and balance history will remain saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await viewModel.archiveAccount(account.id);
      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? 'Could not archive account.')),
        );
      }
    }
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.summary,
    required this.viewModel,
    required this.onEdit,
    required this.onArchive,
  });

  final AccountSummary summary;
  final AccountsViewModel viewModel;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final account = summary.account;
    final archived = account.archived;
    final icon = switch (account.accountType) {
      'cash' => Icons.payments_outlined,
      'bank' => Icons.account_balance_outlined,
      _ => Icons.account_balance_wallet_outlined,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primary.withValues(alpha: 0.10),
              foregroundColor: AppTheme.primary,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${account.accountType.toUpperCase()} • ${account.currencyCode}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.formatBalance(
                      account.currencyCode,
                      summary.balanceMinorUnits,
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: summary.balanceMinorUnits < 0
                              ? Theme.of(context).colorScheme.error
                              : AppTheme.primary,
                        ),
                  ),
                  if (archived)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Archived', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                ],
              ),
            ),
            if (!archived)
              PopupMenuButton<String>(
                tooltip: 'Account actions',
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'archive') onArchive();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'archive', child: Text('Archive')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AccountFormDialog extends StatefulWidget {
  const _AccountFormDialog({
    required this.viewModel,
    this.account,
  });

  final AccountsViewModel viewModel;
  final Account? account;

  @override
  State<_AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends State<_AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _currencyController;
  late final TextEditingController _openingBalanceController;
  late String _accountType;
  bool _saving = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _nameController = TextEditingController(text: account?.name ?? '');
    _currencyController = TextEditingController(text: account?.currencyCode ?? 'PKR');
    _openingBalanceController = TextEditingController(text: '0.00');
    _accountType = account?.accountType ?? 'cash';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final openingBalance = double.tryParse(_openingBalanceController.text.trim());
    if (!_isEditing && (openingBalance == null || !openingBalance.isFinite)) return;

    setState(() => _saving = true);
    final success = await widget.viewModel.saveAccount(
      id: widget.account?.id,
      name: _nameController.text,
      accountType: _accountType,
      currencyCode: _currencyController.text,
      openingBalanceMinorUnits:
          _isEditing ? 0 : (openingBalance! * 100).round(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.viewModel.errorMessage;
    return AlertDialog(
      title: Text(_isEditing ? 'Edit account' : 'Add account'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Account name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an account name'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _accountType,
                decoration: const InputDecoration(labelText: 'Account type'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'bank', child: Text('Bank')),
                  DropdownMenuItem(value: 'wallet', child: Text('Digital wallet')),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) setState(() => _accountType = value);
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currencyController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 3,
                decoration: const InputDecoration(
                  labelText: 'Currency code',
                  hintText: 'PKR',
                  counterText: '',
                ),
                validator: (value) => value == null ||
                        !RegExp(r'^[A-Za-z]{3}$').hasMatch(value.trim())
                    ? 'Enter a 3-letter code'
                    : null,
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _openingBalanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(
                    labelText: 'Opening balance',
                    prefixText: '',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || !amount.isFinite
                        ? 'Enter a valid amount'
                        : null;
                  },
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    error,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save changes' : 'Create account'),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
