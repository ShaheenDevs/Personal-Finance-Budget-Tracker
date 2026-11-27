// ignore_for_file: require_trailing_commas

import 'package:flutter/material.dart';
import 'package:personal_finance_budget_tracker/app/app.locator.dart';
import 'package:personal_finance_budget_tracker/app/app.router.dart';
import 'package:personal_finance_budget_tracker/app/app_theme.dart';
import 'package:personal_finance_budget_tracker/ui/views/dashboard/dashboard_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DashboardView extends StackedView<DashboardViewModel> {
  const DashboardView({super.key});

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) =>
      DashboardViewModel();

  @override
  void onViewModelReady(DashboardViewModel viewModel) => viewModel.initialise();

  @override
  Widget builder(BuildContext context, DashboardViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => locator<NavigationService>()
                .navigateTo(Routes.settingsView),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Refresh overview',
            onPressed: viewModel.loadSummary,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.loadSummary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(viewModel.greeting,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('A private, offline-first view of your finances.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary)),
              const SizedBox(height: 20),
              if (viewModel.isBusy)
                const Center(child: Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                ))
              else if (viewModel.errorMessage != null)
                Card(child: ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                  title: Text(viewModel.errorMessage!),
                  trailing: IconButton(
                    onPressed: viewModel.loadSummary,
                    icon: const Icon(Icons.refresh),
                  ),
                ))
              else if (viewModel.summaries.isEmpty)
                Card(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: AppTheme.primary, size: 30),
                      const SizedBox(height: 12),
                      Text('Your financial overview starts here',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(viewModel.setupMessage),
                    ],
                  ),
                ))
              else ...[
                Text('This month', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                for (final summary in viewModel.summaries)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(summary.currencyCode,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text('${summary.accountCount} accounts',
                                style: Theme.of(context).textTheme.bodySmall),
                          ]),
                          const SizedBox(height: 12),
                          Text('Total balance',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(viewModel.formatAmount(
                              summary.currencyCode, summary.balanceMinorUnits),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const Divider(height: 24),
                          Row(children: [
                            Expanded(child: _Metric(
                              label: 'Income',
                              value: viewModel.formatAmount(summary.currencyCode,
                                  summary.monthIncomeMinorUnits),
                              color: Colors.green,
                            )),
                            Expanded(child: _Metric(
                              label: 'Expenses',
                              value: viewModel.formatAmount(summary.currencyCode,
                                  summary.monthExpenseMinorUnits),
                              color: Colors.redAccent,
                            )),
                          ]),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => locator<NavigationService>()
                    .navigateTo(Routes.accountsView),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('Manage accounts'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => locator<NavigationService>()
                    .navigateTo(Routes.transactionsView),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Manage transactions'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => locator<NavigationService>()
                    .navigateTo(Routes.categoriesTagsView),
                icon: const Icon(Icons.category_outlined),
                label: const Text('Manage categories & tags'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => locator<NavigationService>()
                    .navigateTo(Routes.budgetsView),
                icon: const Icon(Icons.savings_outlined),
                label: const Text('Budgets & recurring'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => locator<NavigationService>()
                    .navigateTo(Routes.reportsView),
                icon: const Icon(Icons.insert_chart_outlined),
                label: const Text('Financial reports'),
              ),
              const SizedBox(height: 16),
              const _PrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    ],
  );
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppTheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: AppTheme.primary),
          SizedBox(width: 12),
          Expanded(child: Text(
            'Your core financial data stays on this device. No account or internet connection is required.',
            style: TextStyle(height: 1.45),
          )),
        ],
      ),
    ),
  );
}
