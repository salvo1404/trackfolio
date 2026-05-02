import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/budget.dart';
import '../../services/portfolio_service.dart';
import '../../utils/constants.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioService = context.watch<PortfolioService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
      body: portfolioService.budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first budget'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: portfolioService.budgets.length,
              itemBuilder: (context, index) {
                final budget = portfolioService.budgets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
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
                                    'Amount',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${budget.currency} ${budget.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (budget.paymentMethod.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Payment',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      budget.paymentMethod,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
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
    showDialog(
      context: context,
      builder: (context) => const _BudgetDialog(),
    );
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
  late String _currency;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _paymentMethodController;

  final List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR',
    'AUD', 'CAD', 'CHF', 'BRL', 'ZAR', 'MXN', 'AED',
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.budget?.category ?? AppConstants.budgetCategories.first;
    _period = widget.budget?.period ?? 'monthly';
    _currency = widget.budget?.currency ?? 'USD';
    _nameController = TextEditingController(
      text: widget.budget?.name ?? '',
    );
    _amountController = TextEditingController(
      text: widget.budget?.amount.toString() ?? '',
    );
    _paymentMethodController = TextEditingController(
      text: widget.budget?.paymentMethod ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final portfolioService = context.read<PortfolioService>();
    final budget = Budget(
      id: widget.budget?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      category: _category,
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      period: _period,
      currency: _currency,
      paymentMethod: _paymentMethodController.text.trim(),
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
                items: [
                  if (!AppConstants.budgetCategories.contains(_category))
                    DropdownMenuItem(value: _category, child: Text(_category)),
                  ...AppConstants.budgetCategories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          )),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _period,
                decoration: const InputDecoration(labelText: 'Period'),
                items: ['weekly', 'monthly', 'quarterly', 'yearly']
                    .map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _period = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: _currencies
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _currency = value);
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
                controller: _paymentMethodController,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                textCapitalization: TextCapitalization.words,
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
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
