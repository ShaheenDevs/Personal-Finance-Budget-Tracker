// ignore_for_file: require_trailing_commas

import 'package:flutter/material.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/budgets/budgets_viewmodel.dart';
import 'package:stacked/stacked.dart';

class BudgetsView extends StackedView<BudgetsViewModel> {
  const BudgetsView({super.key, this.repository});

  final LocalFinanceRepository? repository;

  @override
  BudgetsViewModel viewModelBuilder(BuildContext context) =>
      BudgetsViewModel(repository: repository);

  @override
  void onViewModelReady(BudgetsViewModel viewModel) => viewModel.initialise();

  @override
  Widget builder(BuildContext context, BudgetsViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets & recurring')),
      body: SafeArea(
        child: viewModel.isBusy && viewModel.budgets.isEmpty && viewModel.recurringItems.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: viewModel.loadData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    if (viewModel.errorMessage != null)
                      _ErrorMessage(message: viewModel.errorMessage!),
                    _SectionHeading(
                      title: 'Budgets',
                      subtitle: 'Track spending against monthly or custom limits',
                      actionLabel: 'Add budget',
                      onAdd: viewModel.activeAccounts.isEmpty
                          ? null
                          : () => _showBudgetDialog(context, viewModel),
                    ),
                    if (viewModel.budgets.isEmpty)
                      const _EmptySection(message: 'No budgets yet. Add a budget to set a spending limit.')
                    else
                      for (final item in viewModel.budgets)
                        _BudgetCard(
                          item: item,
                          viewModel: viewModel,
                          onEdit: () => _showBudgetDialog(context, viewModel, item: item),
                        ),
                    const SizedBox(height: 24),
                    _SectionHeading(
                      title: 'Recurring transactions',
                      subtitle: 'Scheduled income and expenses (not posted automatically)',
                      actionLabel: 'Add schedule',
                      onAdd: viewModel.activeAccounts.isEmpty
                          ? null
                          : () => _showRecurringDialog(context, viewModel),
                    ),
                    if (viewModel.recurringItems.isEmpty)
                      const _EmptySection(message: 'No recurring schedules yet. Add rent, bills, salary, or other regular entries.')
                    else
                      for (final item in viewModel.recurringItems)
                        _RecurringCard(
                          item: item,
                          viewModel: viewModel,
                          onEdit: () => _showRecurringDialog(context, viewModel, item: item),
                        ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _showBudgetDialog(
    BuildContext context,
    BudgetsViewModel viewModel, {
    BudgetListItem? item,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _BudgetFormDialog(
        viewModel: viewModel,
        item: item,
      ),
    );
  }

  Future<void> _showRecurringDialog(
    BuildContext context,
    BudgetsViewModel viewModel, {
    RecurringListItem? item,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _RecurringFormDialog(
        viewModel: viewModel,
        item: item,
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      );
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.item,
    required this.viewModel,
    required this.onEdit,
  });

  final BudgetListItem item;
  final BudgetsViewModel viewModel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final budget = item.budget;
    final percent = item.progress.clamp(0.0, 1.0);
    final exceeded = item.spentMinorUnits > budget.amountMinorUnits;
    final period = budget.periodType == 'monthly'
        ? 'Monthly · ${_date(budget.startDate)}'
        : 'Custom · ${_date(budget.startDate)} – ${_date(budget.endDate!)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.categoryName ?? 'All expenses',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') {
                      final confirmed = await _confirmDelete(context, 'Delete this budget?');
                      if (!context.mounted) return;
                      if (confirmed) await viewModel.deleteBudget(budget.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            Text(period, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(viewModel.formatAmount(budget.currencyCode, item.spentMinorUnits)),
                Text('of ${viewModel.formatAmount(budget.currencyCode, budget.amountMinorUnits)}'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: percent, color: exceeded ? Colors.red : null),
            const SizedBox(height: 6),
            Text(
              exceeded
                  ? 'Over budget by ${viewModel.formatAmount(budget.currencyCode, -item.remainingMinorUnits)}'
                  : '${viewModel.formatAmount(budget.currencyCode, item.remainingMinorUnits)} remaining',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: exceeded ? Colors.red : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({
    required this.item,
    required this.viewModel,
    required this.onEdit,
  });

  final RecurringListItem item;
  final BudgetsViewModel viewModel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final row = item.recurring;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(row.transactionType == 'expense'
              ? Icons.south_west
              : Icons.north_east),
        ),
        title: Text(item.categoryName ?? (row.transactionType == 'expense' ? 'Expense' : 'Income')),
        subtitle: Text(
          '${row.frequency[0].toUpperCase()}${row.frequency.substring(1)} · ${item.accountName} · Due ${_date(row.nextDueDate)} · ${row.isActive ? 'Active' : 'Paused'}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              onEdit();
              return;
            }
            if (value == 'toggle') {
              await viewModel.toggleRecurring(row);
              return;
            }
            if (value == 'delete') {
              final confirmed = await _confirmDelete(
                context,
                'Delete this recurring schedule?',
              );
              if (!context.mounted) return;
              if (confirmed) await viewModel.deleteRecurring(row.id);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(row.isActive ? 'Pause' : 'Activate'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _BudgetFormDialog extends StatefulWidget {
  const _BudgetFormDialog({required this.viewModel, this.item});
  final BudgetsViewModel viewModel;
  final BudgetListItem? item;

  @override
  State<_BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<_BudgetFormDialog> {
  late final TextEditingController _amountController;
  String? _categoryId;
  late String _currencyCode;
  late String _periodType;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final budget = widget.item?.budget;
    _amountController = TextEditingController(
      text: budget == null
          ? ''
          : (budget.amountMinorUnits / 100).toStringAsFixed(2),
    );
    _categoryId = budget?.categoryId;
    _currencyCode = budget?.currencyCode ??
        widget.viewModel.activeAccounts.first.currencyCode;
    _periodType = budget?.periodType ?? 'monthly';
    _startDate = budget?.startDate ?? DateTime.now();
    _endDate = budget?.endDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool end}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: end ? (_endDate ?? _startDate) : _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (end) {
        _endDate = picked;
      } else {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    final amount = _parseMinorUnits(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount greater than zero.');
      return;
    }
    if (_periodType == 'custom' && _endDate == null) {
      setState(() => _error = 'Select an end date for the custom period.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final success = await widget.viewModel.saveBudget(
      id: widget.item?.budget.id,
      categoryId: _categoryId,
      amountMinorUnits: amount,
      currencyCode: _currencyCode,
      periodType: _periodType,
      startDate: _startDate,
      endDate: _endDate,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() { _saving = false; _error = widget.viewModel.errorMessage; });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.item == null ? 'Create budget' : 'Edit budget'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Budget amount', prefixText: ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category (optional)'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All expenses')),
                  for (final category in widget.viewModel.expenseCategories)
                    DropdownMenuItem<String?>(value: category.id, child: Text(category.name)),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _currencyCode,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: widget.viewModel.accounts
                    .map((account) => account.currencyCode)
                    .toSet()
                    .map((code) => DropdownMenuItem(value: code, child: Text(code)))
                    .toList(),
                onChanged: (value) => setState(() => _currencyCode = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _periodType,
                decoration: const InputDecoration(labelText: 'Period'),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom range')),
                ],
                onChanged: (value) => setState(() => _periodType = value!),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start date'),
                subtitle: Text(_date(_startDate)),
                trailing: IconButton(
                  onPressed: () => _pickDate(end: false),
                  icon: const Icon(Icons.calendar_month),
                ),
              ),
              if (_periodType == 'custom')
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End date'),
                  subtitle: Text(_endDate == null ? 'Select end date' : _date(_endDate!)),
                  trailing: IconButton(
                    onPressed: () => _pickDate(end: true),
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
              if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save')),
        ],
      );
}

class _RecurringFormDialog extends StatefulWidget {
  const _RecurringFormDialog({required this.viewModel, this.item});
  final BudgetsViewModel viewModel;
  final RecurringListItem? item;

  @override
  State<_RecurringFormDialog> createState() => _RecurringFormDialogState();
}

class _RecurringFormDialogState extends State<_RecurringFormDialog> {
  late final TextEditingController _amountController;
  late String _accountId;
  String? _categoryId;
  late String _type;
  late String _frequency;
  late DateTime _dueDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final row = widget.item?.recurring;
    _amountController = TextEditingController(
      text: row == null ? '' : (row.amountMinorUnits / 100).toStringAsFixed(2),
    );
    _accountId = row?.accountId ?? widget.viewModel.activeAccounts.first.id;
    _categoryId = row?.categoryId;
    _type = row?.transactionType ?? 'expense';
    _frequency = row?.frequency ?? 'monthly';
    _dueDate = row?.nextDueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final amount = _parseMinorUnits(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount greater than zero.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final success = await widget.viewModel.saveRecurring(
      id: widget.item?.recurring.id,
      accountId: _accountId,
      categoryId: _categoryId,
      transactionType: _type,
      amountMinorUnits: amount,
      frequency: _frequency,
      nextDueDate: _dueDate,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() { _saving = false; _error = widget.viewModel.errorMessage; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.viewModel.categories
        .where((category) => category.transactionType == _type)
        .toList();
    return AlertDialog(
      title: Text(widget.item == null ? 'Add recurring transaction' : 'Edit recurring transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
                DropdownMenuItem(value: 'income', child: Text('Income')),
              ],
              onChanged: (value) => setState(() { _type = value!; _categoryId = null; }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _accountId,
              decoration: const InputDecoration(labelText: 'Account'),
              items: widget.viewModel.accounts
                  .map((account) => DropdownMenuItem(
                        value: account.id,
                        child: Text('${account.name} · ${account.currencyCode}${account.archived ? ' (archived)' : ''}'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _accountId = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category (optional)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('No category')),
                for (final category in categories)
                  DropdownMenuItem<String?>(value: category.id, child: Text(category.name)),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(labelText: 'Repeat'),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (value) => setState(() => _frequency = value!),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Next due date'),
              subtitle: Text(_date(_dueDate)),
              trailing: IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_month)),
            ),
            if (_error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save')),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(message, textAlign: TextAlign.center),
        ),
      );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(message),
        ),
      );
}

Future<bool> _confirmDelete(BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirm deletion'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
}

int? _parseMinorUnits(String input) {
  final normalized = input.trim();
  if (!RegExp(r'^\d+(?:\.\d{1,2})?
    return null;
  }
  final parts = normalized.split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null) return null;
  final fraction = parts.length == 1
      ? 0
      : int.parse(parts[1].padRight(2, '0'));
  return whole * 100 + fraction;
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
).hasMatch(normalized)) {
    return null;
  }
  final parts = normalized.split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null) return null;
  final fraction = parts.length == 1
      ? 0
      : int.parse(parts[1].padRight(2, '0'));
  return whole * 100 + fraction;
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
).hasMatch(normalized)) {
    return null;
  }
  final parts = normalized.split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null) return null;
  final fraction = parts.length == 1
      ? 0
      : int.parse(parts[1].padRight(2, '0'));
  return whole * 100 + fraction;
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
).hasMatch(normalized)) {
    return null;
  }
  final parts = normalized.split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null) return null;
  final fraction = parts.length == 1
      ? 0
      : int.parse(parts[1].padRight(2, '0'));
  return whole * 100 + fraction;
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
