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
                      items: viewModel.incomeCategories.map((item) => _ManageableItem(id: item.id, name: item.name)).toList(),
                      emptyText: 'No income categories yet.',
                      onAdd: () => _showCategoryDialog(
                        context,
                        viewModel,
                        transactionType: 'income',
                      ),
                      onRename: (item) => _showRenameDialog(context, viewModel, item, isCategory: true),
                      onDelete: (item) => _confirmDelete(context, viewModel, item, isCategory: true),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Expense categories',
                      subtitle: 'Used when recording money spent',
                      icon: Icons.north_east,
                      items: viewModel.expenseCategories.map((item) => _ManageableItem(id: item.id, name: item.name)).toList(),
                      emptyText: 'No expense categories yet.',
                      onAdd: () => _showCategoryDialog(
                        context,
                        viewModel,
                        transactionType: 'expense',
                      ),
                      onRename: (item) => _showRenameDialog(context, viewModel, item, isCategory: true),
                      onDelete: (item) => _confirmDelete(context, viewModel, item, isCategory: true),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Tags',
                      subtitle: 'Add labels such as Essential, Travel, or Work',
                      icon: Icons.sell_outlined,
                      items: viewModel.tags.map((item) => _ManageableItem(id: item.id, name: item.name)).toList(),
                      emptyText: 'No tags yet.',
                      onAdd: () => _showTagDialog(context, viewModel),
                      onRename: (item) => _showRenameDialog(context, viewModel, item, isCategory: false),
                      onDelete: (item) => _confirmDelete(context, viewModel, item, isCategory: false),
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

  Future<void> _showRenameDialog(BuildContext context, CategoriesTagsViewModel viewModel, _ManageableItem item, {required bool isCategory}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _NameEntryDialog(
        title: isCategory ? 'Rename category' : 'Rename tag',
        label: isCategory ? 'Category name' : 'Tag name',
        submitLabel: 'Save',
        initialValue: item.name,
        maxLength: isCategory ? 60 : 40,
        onSubmit: (name) => isCategory
            ? viewModel.renameCategory(id: item.id, name: name)
            : viewModel.renameTag(id: item.id, name: name),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoriesTagsViewModel viewModel, _ManageableItem item, {required bool isCategory}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isCategory ? 'Delete category?' : 'Delete tag?'),
        content: Text('Deletion is blocked while existing records use this item.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    if (isCategory) {
      await viewModel.deleteCategory(item.id);
    } else {
      await viewModel.deleteTag(item.id);
    }
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
        onSubmit: (name) => viewModel.addTag(name: name),
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
    required this.onRename,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<_ManageableItem> items;
  final String emptyText;
  final VoidCallback onAdd;
  final Future<void> Function(_ManageableItem item) onRename;
  final Future<void> Function(_ManageableItem item) onDelete;

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
                children: items.map((item) => PopupMenuButton<String>(
                  tooltip: 'Manage ${item.name}',
                  onSelected: (action) {
                    if (action == 'rename') onRename(item);
                    if (action == 'delete') onDelete(item);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.label_outline, size: 16),
                    label: Text(item.name),
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ManageableItem {
  const _ManageableItem({required this.id, required this.name});
  final String id;
  final String name;
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
    this.initialValue = '',
  });

  final String title;
  final String label;
  final String submitLabel;
  final int maxLength;
  final Future<bool> Function(String name) onSubmit;
  final String initialValue;

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
    _controller = TextEditingController(text: widget.initialValue);
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
