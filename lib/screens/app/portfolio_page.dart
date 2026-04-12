import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/portfolio_item.dart';
import '../../services/portfolio_service.dart';
import '../../services/auth_service.dart';
import '../../services/currency_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/currency_formatter.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioService = context.watch<PortfolioService>();
    final authService = context.watch<AuthService>();
    final currencyService = context.read<CurrencyService>();
    final currencyFormatter = CurrencyFormatter(currencyService, authService.currentUser);

    // Group items by type
    final itemsByType = <String, List<PortfolioItem>>{};
    for (final item in portfolioService.portfolioItems) {
      itemsByType.putIfAbsent(item.type, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
      body: portfolioService.portfolioItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No assets yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first asset'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: itemsByType.entries.map((entry) {
                final type = entry.key;
                final items = entry.value;
                final totalValue = items.fold<double>(
                  0,
                  (sum, item) => sum + item.totalValue,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            color: AppTheme.getPortfolioTypeColor(type),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            type,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            currencyFormatter.format(totalValue),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...items.map(
                      (item) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            'Qty: ${item.quantity} | Cost: ${currencyFormatter.format(item.totalCost)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                currencyFormatter.format(item.totalValue),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${item.gainLoss >= 0 ? '+' : ''}${currencyFormatter.format(item.gainLoss)}',
                                style: TextStyle(
                                  color: item.gainLoss >= 0
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showEditItemDialog(context, item),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _PortfolioItemDialog(),
    );
  }

  void _showEditItemDialog(BuildContext context, PortfolioItem item) {
    showDialog(
      context: context,
      builder: (context) => _PortfolioItemDialog(item: item),
    );
  }
}

class _PortfolioItemDialog extends StatefulWidget {
  final PortfolioItem? item;

  const _PortfolioItemDialog({this.item});

  @override
  State<_PortfolioItemDialog> createState() => _PortfolioItemDialogState();
}

class _PortfolioItemDialogState extends State<_PortfolioItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _currentValueController;

  @override
  void initState() {
    super.initState();
    _type = widget.item?.type ?? AppConstants.portfolioTypes.first;
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '',
    );
    _purchasePriceController = TextEditingController(
      text: widget.item?.purchasePrice.toString() ?? '',
    );
    _currentValueController = TextEditingController(
      text: widget.item?.currentValue.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final portfolioService = context.read<PortfolioService>();
    final item = PortfolioItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      name: _nameController.text,
      quantity: double.parse(_quantityController.text),
      purchasePrice: double.parse(_purchasePriceController.text),
      currentValue: double.parse(_currentValueController.text),
      purchaseDate: widget.item?.purchaseDate ?? DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    if (widget.item == null) {
      portfolioService.addPortfolioItem(item);
    } else {
      portfolioService.updatePortfolioItem(item);
    }

    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.item != null) {
      context.read<PortfolioService>().deletePortfolioItem(widget.item!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Asset' : 'Edit Asset'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: AppConstants.portfolioTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(labelText: 'Purchase Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentValueController,
                decoration: const InputDecoration(labelText: 'Current Value'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.item != null)
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
