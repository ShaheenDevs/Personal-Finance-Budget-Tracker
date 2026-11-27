import 'package:flutter/material.dart';
import 'package:personal_finance_budget_tracker/ui/views/reports/reports_viewmodel.dart';
import 'package:stacked/stacked.dart';

class ReportsView extends StackedView<ReportsViewModel> {
  const ReportsView({super.key});

  @override
  ReportsViewModel viewModelBuilder(BuildContext context) => ReportsViewModel();

  @override
  void onViewModelReady(ReportsViewModel viewModel) => viewModel.initialise();

  @override
  Widget builder(BuildContext context, ReportsViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial reports')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.loadReport,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                IconButton(tooltip: 'Previous month',
                  onPressed: () => viewModel.changeMonth(-1),
                  icon: const Icon(Icons.chevron_left)),
                Expanded(child: Center(child: Text(viewModel.monthLabel,
                    style: Theme.of(context).textTheme.titleLarge))),
                IconButton(tooltip: 'Next month',
                  onPressed: () => viewModel.changeMonth(1),
                  icon: const Icon(Icons.chevron_right)),
              ]),
              if (viewModel.currencies.length > 1)
                DropdownButtonFormField<String>(
                  value: viewModel.selectedCurrency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: viewModel.currencies.map((currency) =>
                    DropdownMenuItem(value: currency, child: Text(currency))).toList(),
                  onChanged: viewModel.selectCurrency,
                ),
              const SizedBox(height: 12),
              if (viewModel.isBusy)
                const Center(child: Padding(
                  padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (viewModel.errorMessage != null)
                Card(child: ListTile(
                  title: Text(viewModel.errorMessage!),
                  trailing: IconButton(onPressed: viewModel.loadReport,
                      icon: const Icon(Icons.refresh)),
                ))
              else if (viewModel.selectedCurrency == null)
                const Card(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Add transactions to see your financial reports.'),
                ))
              else ...[
                Card(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Monthly cash flow',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _SummaryLine(label: 'Income', value: viewModel.formatAmount(
                        viewModel.incomeMinorUnits), color: Colors.green),
                    const SizedBox(height: 8),
                    _SummaryLine(label: 'Expenses', value: viewModel.formatAmount(
                        viewModel.expenseMinorUnits), color: Colors.redAccent),
                    const Divider(height: 24),
                    _SummaryLine(label: 'Net', value: viewModel.formatAmount(
                        viewModel.netMinorUnits), color: Theme.of(context).colorScheme.primary),
                  ]),
                )),
                const SizedBox(height: 12),
                Card(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Weekly comparison',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    for (final week in viewModel.weeklyCashFlow)
                      _WeeklyBar(week: week, formatter: viewModel.formatAmount),
                    const SizedBox(height: 8),
                    const Wrap(spacing: 16, children: [
                      _Legend(color: Colors.green, label: 'Income'),
                      _Legend(color: Colors.redAccent, label: 'Expenses'),
                    ]),
                  ]),
                )),
                const SizedBox(height: 12),
                Card(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Expense categories',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (viewModel.categoryExpenses.isEmpty)
                      const Text('No expenses recorded for this month.')
                    else
                      for (final item in viewModel.categoryExpenses)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            Expanded(child: Text(item.name)),
                            Text(viewModel.formatAmount(item.amountMinorUnits),
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ]),
                        ),
                  ]),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label)),
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
  ]);
}

class _WeeklyBar extends StatelessWidget {
  const _WeeklyBar({required this.week, required this.formatter});
  final WeeklyCashFlow week;
  final String Function(int) formatter;
  @override
  Widget build(BuildContext context) {
    final maxValue = [week.income, week.expense].reduce((a, b) => a > b ? a : b);
    final incomeFraction = maxValue == 0 ? 0.0 : week.income / maxValue;
    final expenseFraction = maxValue == 0 ? 0.0 : week.expense / maxValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(week.label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 5),
        Row(children: [
          Expanded(flex: 3, child: Column(children: [
            FractionallySizedBox(alignment: Alignment.centerLeft,
              widthFactor: incomeFraction, child: Container(height: 8,
                decoration: BoxDecoration(color: Colors.green,
                  borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 4),
            FractionallySizedBox(alignment: Alignment.centerLeft,
              widthFactor: expenseFraction, child: Container(height: 8,
                decoration: BoxDecoration(color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8)))),
          ])),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(
            '${formatter(week.income)} / ${formatter(week.expense)}',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelSmall,
          )),
        ]),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 9, height: 9, decoration: BoxDecoration(
      color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 5),
    Text(label, style: Theme.of(context).textTheme.labelSmall),
  ]);
}
