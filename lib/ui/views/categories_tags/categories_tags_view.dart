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
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var saving = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add ${transactionType == 'income' ? 'income' : 'expense'} category',
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Category name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a category name'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => saving = true);
                      final saved = await viewModel.addCategory(
                        name: controller.text,
                        transactionType: transactionType,
                      );
                      if (!dialogContext.mounted) return;
                      if (saved) {
                        Navigator.pop(dialogContext);
                      } else {
                        setDialogState(() => saving = false);
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add category'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _showTagDialog(
    BuildContext context,
    CategoriesTagsViewModel viewModel,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var saving = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add tag'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Tag name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a tag name'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => saving = true);
                      final saved = await viewModel.addTag(name: controller.text);
                      if (!dialogContext.mounted) return;
                      if (saved) {
                        Navigator.pop(dialogContext);
                      } else {
                        setDialogState(() => saving = false);
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add tag'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
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
