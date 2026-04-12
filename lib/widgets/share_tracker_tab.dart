import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/share_transaction.dart';
import '../models/portfolio_item.dart';
import '../services/portfolio_service.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';

class ShareTrackerTab extends StatelessWidget {
  const ShareTrackerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioService = context.watch<PortfolioService>();
    final authService = context.watch<AuthService>();
    final currencyService = context.read<CurrencyService>();
    final currencyFormatter = CurrencyFormatter(currencyService, authService.currentUser);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.02),
            Theme.of(context).colorScheme.secondary.withOpacity(0.02),
          ],
        ),
      ),
      child: portfolioService.portfolioItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No portfolio items yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add your first asset to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/portfolio');
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Add Your First Asset',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Assets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildGroupedPortfolioItems(context, portfolioService, currencyFormatter),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildGroupedPortfolioItems(
    BuildContext context,
    PortfolioService portfolioService,
    CurrencyFormatter currencyFormatter,
  ) {
    // Group items by type
    final itemsByType = <String, List<PortfolioItem>>{};
    for (final item in portfolioService.portfolioItems) {
      itemsByType.putIfAbsent(item.type, () => []).add(item);
    }

    final widgets = <Widget>[];

    for (final entry in itemsByType.entries) {
      final type = entry.key;
      final items = entry.value;
      final totalValue = items.fold<double>(
        0,
        (sum, item) => sum + item.totalValue,
      );

      // Category header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.getPortfolioTypeColor(type),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                _getIconForType(type),
                color: AppTheme.getPortfolioTypeColor(type),
                size: 20,
              ),
              const SizedBox(width: 8),
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
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );

      // Items in this category
      for (final item in items) {
        final gainLossColor = item.gainLoss >= 0
            ? AppTheme.successColor
            : AppTheme.errorColor;

        widgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showEditItemDialog(context, item),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item.quantity.toStringAsFixed(2)} units',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                currencyFormatter.format(item.totalValue),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: gainLossColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${item.gainLoss >= 0 ? '+' : ''}${currencyFormatter.format(item.gainLoss)} (${item.gainLossPercent.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    color: gainLossColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.grey[400],
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'shares':
        return Icons.show_chart;
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'real-estate':
        return Icons.home;
      case 'watches':
        return Icons.watch;
      case 'cash':
        return Icons.attach_money;
      default:
        return Icons.account_balance_wallet;
    }
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
