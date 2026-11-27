import 'package:flutter/material.dart';
import 'package:personal_finance_budget_tracker/app/app_theme.dart';
import 'package:personal_finance_budget_tracker/repositories/local_finance_repository.dart';
import 'package:personal_finance_budget_tracker/ui/views/categories_tags/categories_tags_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CategoriesTagsView extends StackedView<CategoriesTagsViewModel> {
  const CategoriesTagsView({super.key, this.repository});

  final LocalFinanceRepository? repository;

  @override
  CategoriesTagsViewModel viewModelBuilder(BuildContext context) =>
      CategoriesTagsViewModel(repository: repository);

  @override
  void onViewModelReady(CategoriesTagsViewModel viewModel) {
    viewModel.initialise();
  }

  @override
  Widget builder(
    BuildContext context,
    CategoriesTagsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories & tags')),
      body: SafeArea(
        child: viewModel.isBusy && viewModel.categories.isEmpty && viewModel.tags.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: viewModel.loadData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (viewModel.errorMessage != null)
                      _MessageBanner(
                        message: viewModel.errorMessage!,
                        isError: true,
                      ),
                    if (viewModel.successMessage != null)
                      _MessageBanner(
                        message: viewModel.successMessage!,
                        isError: false,
                      ),
                    _SectionCard(
                      title: 'Income categories',
                      subtitle: 'Used when recording money received',
                      icon: Icons.south_west,
                      items: viewModel.incomeCategories.map((item) => item.name).toList(),
                      emptyText: 'No income categories yet.',
                      onAdd: () => _showCategoryDialog(
                        context,
                        viewModel,
                        transactionType: 'income',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Expense categories',
                      subtitle: 'Used when recording money spent',
                      icon: Icons.north_east,
                      items: viewModel.expenseCategories.map((item) => item.name).toList(),
                      emptyText: 'No expense categories yet.',
                      onAdd: () => _showCategoryDialog(
                        context,
                        viewModel,
                        transactionType: 'expense',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Tags',
                      subtitle: 'Add labels such as Essential, Travel, or Work',
                      icon: Icons.sell_outlined,
                      items: viewModel.tags.map((item) => item.name).toList(),
                      emptyText: 'No tags yet.',
                      onAdd: () => _showTagDialog(context, viewModel),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Categories and tags are stored on this device. Existing records are not changed when you add new labels.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    CategoriesTagsViewModel viewModel, {
    required String transactionType,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _NameEntryDialog(
        title: 'Add ${transactionType == 'income' ? 'income' : 'expense'} category',
        label: 'Category name',
        submitLabel: 'Add category',
        maxLength: 60,
        onSubmit: (name) => viewModel.addCategory(
          name: name,
          transactionType: transactionType,
        ),
      ),
    );
  }

  Future<void> _showTagDialog(
    BuildContext context,
    CategoriesTagsViewModel viewModel,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _NameEntryDialog(
        title: 'Add tag',
        label: 'Tag name',
        submitLabel: 'Add tag',
        maxLength: 40,
        onSubmit: viewModel.addTag,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
    required this.emptyText,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> items;
  final String emptyText;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Add $title',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(
                emptyText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items
                    .map(
                      (item) => Chip(
                        avatar: const Icon(Icons.label_outline, size: 16),
                        label: Text(item),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Theme.of(context).colorScheme.error : AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(message, style: TextStyle(color: color)),
    );
  }
}


class _NameEntryDialog extends StatefulWidget {
  const _NameEntryDialog({
    required this.title,
    required this.label,
    required this.submitLabel,
    required this.maxLength,
    required this.onSubmit,
  });

  final String title;
  final String label;
  final String submitLabel;
  final int maxLength;
  final Future<bool> Function(String name) onSubmit;

  @override
  State<_NameEntryDialog> createState() => _NameEntryDialogState();
}

class _NameEntryDialogState extends State<_NameEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final saved = await widget.onSubmit(_controller.text);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: widget.maxLength,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: widget.label),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a name'
              : null,
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
              : Text(widget.submitLabel),
        ),
      ],
    );
  }
}
