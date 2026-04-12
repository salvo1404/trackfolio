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
                    onPressed: () => _showAddItemDialog(context),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Assets',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddItemDialog(context),
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
      case 'retirement fund':
        return Icons.savings_outlined;
      default:
        return Icons.account_balance_wallet;
    }
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
  late TextEditingController _symbolController;
  late TextEditingController _quantityController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _currentValueController;
  late DateTime _purchaseDate;
  double? _suggestedPrice;
  bool _isLoadingPrice = false;

  @override
  void initState() {
    super.initState();
    _type = widget.item?.type ?? AppConstants.portfolioTypes.first;
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _symbolController = TextEditingController(text: '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '',
    );
    _purchasePriceController = TextEditingController(
      text: widget.item?.purchasePrice.toString() ?? '',
    );
    _currentValueController = TextEditingController(
      text: widget.item?.currentValue.toString() ?? '',
    );
    _purchaseDate = widget.item?.purchaseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    super.dispose();
  }

  double get _totalCost {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_purchasePriceController.text) ?? 0;
    return quantity * price;
  }

  Future<void> _lookupStockSymbol(String symbol) async {
    if (symbol.isEmpty) return;

    setState(() {
      _isLoadingPrice = true;
      _suggestedPrice = null;
    });

    // Simulate API call for demo purposes
    // In production, use a real stock API like Alpha Vantage, Yahoo Finance, or IEX Cloud
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data for common stocks
    final mockPrices = {
      'AAPL': 175.50,
      'GOOGL': 140.25,
      'MSFT': 378.90,
      'AMZN': 145.30,
      'TSLA': 242.80,
      'META': 485.20,
      'NVDA': 875.60,
      'AMD': 165.40,
      'NFLX': 490.30,
      'DIS': 112.50,
    };

    setState(() {
      _suggestedPrice = mockPrices[symbol.toUpperCase()];
      _isLoadingPrice = false;
      if (_suggestedPrice != null) {
        _currentValueController.text = _suggestedPrice.toString();
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final portfolioService = context.read<PortfolioService>();

    // For simplified assets, quantity is always 1 (since we don't ask for it)
    final quantity = _isSimplifiedAssetType()
        ? 1.0
        : double.parse(_quantityController.text);

    final item = PortfolioItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      name: _nameController.text,
      quantity: quantity,
      purchasePrice: double.parse(_purchasePriceController.text),
      currentValue: double.parse(_currentValueController.text),
      purchaseDate: _purchaseDate,
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

  List<Widget> _buildSharesFields(BuildContext context) {
    return [
      // Asset Symbol
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Symbol',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _symbolController,
            decoration: InputDecoration(
              hintText: 'e.g., AAPL, GOOGL',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: _isLoadingPrice
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _suggestedPrice != null
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Chip(
                            label: Text(
                              '\$${_suggestedPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.green[100],
                            padding: EdgeInsets.zero,
                          ),
                        )
                      : null,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              if (value.length >= 2) {
                _lookupStockSymbol(value);
              }
            },
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Asset Name
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g., Apple Inc.',
              prefixIcon: Icon(
                Icons.business,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Quantity
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
              hintText: 'Number of shares',
              prefixIcon: Icon(
                Icons.numbers,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Purchase Price
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Price (per share)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _purchasePriceController,
            decoration: InputDecoration(
              hintText: 'Price per share',
              prefixIcon: Icon(
                Icons.attach_money,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Purchase Date
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _purchaseDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _purchaseDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_purchaseDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Total Cost (calculated)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Cost',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '\$${_totalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_quantityController.text.isEmpty ? '0' : _quantityController.text} × \$${_purchasePriceController.text.isEmpty ? '0' : _purchasePriceController.text})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Current Value per share
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Value (per share)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _currentValueController,
            decoration: InputDecoration(
              hintText: 'Current price per share',
              prefixIcon: Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildSimplifiedFields(BuildContext context) {
    // For Real Estate, Watches, Cash, Retirement Fund
    return [
      // Asset Name
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: _getHintForType(),
              prefixIcon: Icon(
                Icons.label_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Purchase Price
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Price',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _purchasePriceController,
            decoration: InputDecoration(
              hintText: 'Total purchase price',
              prefixIcon: Icon(
                Icons.attach_money,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Purchase Date
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _purchaseDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _purchaseDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_purchaseDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Current Value
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _currentValueController,
            decoration: InputDecoration(
              hintText: 'Current total value',
              prefixIcon: Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildGenericFields(BuildContext context) {
    // For Crypto - needs quantity
    return [
      // Asset Name
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g., Bitcoin, Ethereum',
              prefixIcon: Icon(
                Icons.label_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Quantity
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
              hintText: 'Number of units',
              prefixIcon: Icon(
                Icons.numbers,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Purchase Price
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Price',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _purchasePriceController,
            decoration: InputDecoration(
              hintText: 'Price per unit',
              prefixIcon: Icon(
                Icons.shopping_cart_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Current Value
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _currentValueController,
            decoration: InputDecoration(
              hintText: 'Current price per unit',
              prefixIcon: Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
        ],
      ),
    ];
  }

  String _getHintForType() {
    switch (_type) {
      case AppConstants.typeRealEstate:
        return 'e.g., Downtown Apartment';
      case AppConstants.typeWatches:
        return 'e.g., Rolex Submariner';
      case AppConstants.typeCash:
        return 'e.g., Savings Account';
      case AppConstants.typeRetirementFund:
        return 'e.g., 401k Plan';
      default:
        return 'Enter asset name';
    }
  }

  bool _isSimplifiedAssetType() {
    return _type == AppConstants.typeRealEstate ||
        _type == AppConstants.typeWatches ||
        _type == AppConstants.typeCash ||
        _type == AppConstants.typeRetirementFund;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.02),
              Theme.of(context).colorScheme.secondary.withOpacity(0.02),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.item == null
                            ? Icons.add_circle_outline
                            : Icons.edit_outlined,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.item == null ? 'Add New Asset' : 'Edit Asset',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item == null
                        ? 'Add a new asset to your portfolio'
                        : 'Update asset details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Asset Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asset Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: InputDecoration(
                          hintText: 'Select asset type',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dynamic fields based on asset type
                  if (_type == AppConstants.typeShares)
                    ..._buildSharesFields(context)
                  else if (_isSimplifiedAssetType())
                    ..._buildSimplifiedFields(context)
                  else
                    ..._buildGenericFields(context),

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      if (widget.item != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ACTIONS',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.item != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _delete,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: widget.item != null ? 1 : 2,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: Icon(
                            widget.item == null ? Icons.add : Icons.check,
                            size: 18,
                          ),
                          label: Text(
                            widget.item == null ? 'Add Asset' : 'Save',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
