import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:personal_finance_budget_tracker/services/transaction_export_service.dart';
import 'package:personal_finance_budget_tracker/app/app_theme.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/transactions/transactions_viewmodel.dart';
import 'package:stacked/stacked.dart';

class TransactionsView extends StackedView<TransactionsViewModel> {
  const TransactionsView({super.key, this.repository});

  final LocalFinanceRepository? repository;

  @override
  TransactionsViewModel viewModelBuilder(BuildContext context) =>
      TransactionsViewModel(repository: repository);

  @override
  void onViewModelReady(TransactionsViewModel viewModel) {
    viewModel.initialise();
  }

  @override
  Widget builder(
    BuildContext context,
    TransactionsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.activeAccounts.isEmpty
            ? null
            : () => _showTransactionForm(context, viewModel),
        icon: const Icon(Icons.add),
        label: const Text('Add transaction'),
      ),
      body: SafeArea(
        child: viewModel.isBusy && viewModel.transactionItems.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: viewModel.loadTransactions,
                child: viewModel.transactionItems.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          if (viewModel.errorMessage != null) ...[
                            _ErrorBanner(message: viewModel.errorMessage!),
                            TextButton.icon(
                              onPressed: viewModel.loadTransactions,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                          const SizedBox(height: 100),
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 56,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.activeAccounts.isEmpty
                                ? 'Add an account first'
                                : 'No transactions yet',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            viewModel.activeAccounts.isEmpty
                                ? 'Create a cash, bank, or wallet account before recording a transaction.'
                                : 'Record your first income or expense to start tracking your activity.',
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
                          TextField(
                            decoration: const InputDecoration(labelText: 'Search transactions', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                            onChanged: viewModel.updateSearch,
                          ),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, runSpacing: 4, children: [
                            for (final option in const [('all', 'All'), ('income', 'Income'), ('expense', 'Expense')])
                              ChoiceChip(label: Text(option.$2), selected: viewModel.selectedType == option.$1, onSelected: (_) => viewModel.updateType(option.$1)),
                            ActionChip(avatar: const Icon(Icons.date_range, size: 18), label: Text(viewModel.dateFrom == null ? 'Date range' : '${viewModel.dateFrom!.toLocal().toString().split(' ').first} – ${viewModel.dateTo!.toLocal().toString().split(' ').first}'), onPressed: () async {
                              final range = await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 3650)), initialDateRange: viewModel.dateFrom == null ? null : DateTimeRange(start: viewModel.dateFrom!, end: viewModel.dateTo!));
                              if (range != null) viewModel.updateDateRange(start: range.start, end: range.end);
                            }),
                            ActionChip(avatar: Icon(viewModel.newestFirst ? Icons.south : Icons.north, size: 18), label: Text(viewModel.newestFirst ? 'Newest' : 'Oldest'), onPressed: viewModel.toggleSortOrder),
                            ActionChip(label: const Text('Clear filters'), onPressed: viewModel.clearFilters),
                          ]),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: viewModel.selectedAccountId,
                            decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder(), isDense: true),
                            items: [
                              const DropdownMenuItem<String>(value: null, child: Text('All accounts')),
                              for (final account in viewModel.accounts) DropdownMenuItem(value: account.id, child: Text(account.name)),
                            ],
                            onChanged: viewModel.updateAccount,
                          ),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: OutlinedButton.icon(onPressed: () => _exportCsv(context, viewModel), icon: const Icon(Icons.table_view), label: const Text('Export CSV'))),
                            const SizedBox(width: 8),
                            Expanded(child: OutlinedButton.icon(onPressed: () => _exportPdf(context, viewModel), icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF'))),
                          ]),
                          const SizedBox(height: 12),
                          Text(
                            '${viewModel.filteredTransactionItems.length} transactions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (viewModel.filteredTransactionItems.isEmpty)
                            const Padding(padding: EdgeInsets.all(24), child: Text('No transactions match these filters.')),
                          for (final item in viewModel.filteredTransactionItems)
                            _TransactionCard(
                              item: item,
                              viewModel: viewModel,
                              onEdit: viewModel.accounts.any(
                                (account) =>
                                    account.id == item.transaction.accountId &&
                                    !account.archived,
                              )
                                  ? () => _showTransactionForm(
                                        context,
                                        viewModel,
                                        item: item,
                                      )
                                  : null,
                              onDelete: () =>
                                  _confirmDelete(context, viewModel, item),
                            ),
                        ],
                      ),
              ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, TransactionsViewModel viewModel) async {
    try {
      final csv = const TransactionExportService().buildCsv(viewModel.filteredTransactionItems);
      await SharePlus.instance.share(ShareParams(files: [XFile.fromData(utf8.encode(csv), mimeType: 'text/csv', name: 'transactions.csv')], subject: 'Transaction export'));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not export the CSV file.')));
    }
  }

  Future<void> _exportPdf(BuildContext context, TransactionsViewModel viewModel) async {
    try {
      final bytes = await const TransactionExportService().buildPdf(viewModel.filteredTransactionItems);
      await Printing.sharePdf(bytes: bytes, filename: 'transactions.pdf');
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not export the PDF file.')));
    }
  }
  Future<void> _showTransactionForm(
    BuildContext context,
    TransactionsViewModel viewModel, {
    TransactionListItem? item,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _TransactionFormDialog(
        viewModel: viewModel,
        item: item,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TransactionsViewModel viewModel,
    TransactionListItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text(
          'This transaction will be removed from normal views. Its record is retained locally as a soft-deleted item.',
        ),
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
    );
    if (confirmed == true) {
      final success =
          await viewModel.deleteTransaction(item.transaction.id);
      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.errorMessage ?? 'Could not delete transaction.',
            ),
          ),
        );
      }
    }
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.item,
    required this.viewModel,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionListItem item;
  final TransactionsViewModel viewModel;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final transaction = item.transaction;
    final income = transaction.transactionType == 'income';
    final color = income ? AppTheme.primary : Theme.of(context).colorScheme.error;
    final date = transaction.transactionDate.toLocal().toString().split(' ').first;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.10),
          foregroundColor: color,
          child: Icon(income ? Icons.south_west : Icons.north_east),
        ),
        title: Text(
          transaction.note?.isNotEmpty == true
              ? transaction.note!
              : (item.categoryName ?? (income ? 'Income' : 'Expense')),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${item.accountName} • $date${item.tagNames.isEmpty ? '' : '\n${item.tagNames.join(', ')}'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${income ? '+' : '-'}${viewModel.formatAmount(transaction.currencyCode, transaction.amountMinorUnits)}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Transaction actions',
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionFormDialog extends StatefulWidget {
  const _TransactionFormDialog({
    required this.viewModel,
    this.item,
  });

  final TransactionsViewModel viewModel;
  final TransactionListItem? item;

  @override
  State<_TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<_TransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String? _accountId;
  late String _transactionType;
  String? _categoryId;
  late DateTime _transactionDate;
  late List<String> _selectedTagIds;
  bool _saving = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final transaction = item?.transaction;
    _accountId = transaction?.accountId ??
        (widget.viewModel.activeAccounts.isEmpty
            ? null
            : widget.viewModel.activeAccounts.first.id);
    _transactionType = transaction?.transactionType ?? 'expense';
    _categoryId = transaction?.categoryId;
    _amountController = TextEditingController(
      text: transaction == null
          ? ''
          : (transaction.amountMinorUnits / 100).toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _transactionDate = transaction?.transactionDate ?? DateTime.now();
    _selectedTagIds = List.of(item?.tagIds ?? const []);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _accountId == null) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || !amount.isFinite || amount <= 0) return;

    setState(() => _saving = true);
    final success = await widget.viewModel.saveTransaction(
      id: widget.item?.transaction.id,
      accountId: _accountId!,
      categoryId: _categoryId,
      transactionType: _transactionType,
      amountMinorUnits: (amount * 100).round(),
      transactionDate: _transactionDate,
      note: _noteController.text,
      tagIds: _selectedTagIds,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.viewModel.categories
        .where((category) => category.transactionType == _transactionType)
        .toList();
    final selectedCategoryExists =
        categories.any((category) => category.id == _categoryId);
    return AlertDialog(
      title: Text(_isEditing ? 'Edit transaction' : 'Add transaction'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _accountId,
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: widget.viewModel.activeAccounts
                      .map(
                        (account) => DropdownMenuItem(
                          value: account.id,
                          child: Text('${account.name} • ${account.currencyCode}'),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _accountId = value),
                  validator: (value) =>
                      value == null ? 'Choose an account' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _transactionType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _transactionType = value;
                            _categoryId = null;
                          });
                        },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || !amount.isFinite || amount <= 0
                        ? 'Enter an amount greater than zero'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: selectedCategoryExists ? _categoryId : null,
                  decoration: const InputDecoration(labelText: 'Category (optional)'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No category'),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem<String?>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Date: ${_transactionDate.toLocal().toString().split(' ').first}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _transactionDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(
                                const Duration(days: 3650),
                              ),
                            );
                            if (picked != null) {
                              setState(() => _transactionDate = picked);
                            }
                          },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: const Text('Choose date'),
                  ),
                ),
                if (widget.viewModel.tags.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Tags'),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final tag in widget.viewModel.tags)
                        FilterChip(
                          label: Text(tag.name),
                          selected: _selectedTagIds.contains(tag.id),
                          onSelected: _saving
                              ? null
                              : (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedTagIds.add(tag.id);
                                    } else {
                                      _selectedTagIds.remove(tag.id);
                                    }
                                  });
                                },
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    counterText: '',
                  ),
                ),
                if (widget.viewModel.errorMessage != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.viewModel.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
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
              : Text(_isEditing ? 'Save changes' : 'Save transaction'),
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
