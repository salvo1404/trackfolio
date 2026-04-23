import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../services/portfolio_service.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/currency_formatter.dart';

class BudgetsTab extends StatelessWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioService = context.watch<PortfolioService>();
    final authService = context.watch<AuthService>();
    final currencyService = context.read<CurrencyService>();
    final currencyFormatter = CurrencyFormatter(
      currencyService,
      authService.currentUser,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: portfolioService.budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No budgets yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create budgets to manage your spending',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBudgetDialog(context),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Create Your First Budget',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: portfolioService.budgets.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budgets',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddBudgetDialog(context),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text(
                            'Add',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final budget = portfolioService.budgets[index - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showEditBudgetDialog(context, budget),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                budget.category,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Chip(
                                label: Text(budget.period),
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Spent',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(budget.spent),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: budget.isOverBudget
                                          ? AppTheme.errorColor
                                          : AppTheme.successColor,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Budget',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(budget.amount),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Remaining',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(budget.remaining),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: budget.remaining >= 0
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (budget.percentUsed / 100).clamp(0.0, 1.0),
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              budget.isOverBudget
                                  ? AppTheme.errorColor
                                  : AppTheme.successColor,
                            ),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${budget.percentUsed.toStringAsFixed(1)}% used',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const _BudgetDialog());
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => _BudgetDialog(budget: budget),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  final Budget? budget;

  const _BudgetDialog({this.budget});

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late String _period;
  late TextEditingController _amountController;
  late TextEditingController _spentController;

  @override
  void initState() {
    super.initState();
    _category = widget.budget?.category ?? AppConstants.budgetCategories.first;
    _period = widget.budget?.period ?? 'monthly';
    _amountController = TextEditingController(
      text: widget.budget?.amount.toString() ?? '',
    );
    _spentController = TextEditingController(
      text: widget.budget?.spent.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _spentController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final portfolioService = context.read<PortfolioService>();
    final budget = Budget(
      id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: _category,
      amount: double.parse(_amountController.text),
      period: _period,
      spent: double.parse(_spentController.text),
      createdAt: widget.budget?.createdAt ?? DateTime.now(),
    );

    if (widget.budget == null) {
      portfolioService.addBudget(budget);
    } else {
      portfolioService.updateBudget(budget);
    }

    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.budget != null) {
      context.read<PortfolioService>().deleteBudget(widget.budget!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppConstants.budgetCategories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _period,
                decoration: const InputDecoration(labelText: 'Period'),
                items: ['monthly', 'quarterly', 'yearly']
                    .map(
                      (period) =>
                          DropdownMenuItem(value: period, child: Text(period)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _period = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Budget Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _spentController,
                decoration: const InputDecoration(labelText: 'Spent'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.budget != null)
          TextButton(
            onPressed: _delete,
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
