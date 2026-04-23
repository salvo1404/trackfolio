import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/share_transaction.dart';
import '../models/portfolio_item.dart';
import '../services/portfolio_service.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';
import '../services/stock_api_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';

class ShareTrackerTab extends StatefulWidget {
  const ShareTrackerTab({super.key});

  @override
  State<ShareTrackerTab> createState() => _ShareTrackerTabState();
}

class _ShareTrackerTabState extends State<ShareTrackerTab> {
  final Set<String> _collapsedTypes = {};

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
                  ..._buildGroupedPortfolioItems(context, portfolioService, currencyFormatter, currencyService),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildGroupedPortfolioItems(
    BuildContext context,
    PortfolioService portfolioService,
    CurrencyFormatter currencyFormatter,
    CurrencyService currencyService,
  ) {
    // Group items by type
    final itemsByType = <String, List<PortfolioItem>>{};
    for (final item in portfolioService.portfolioItems) {
      itemsByType.putIfAbsent(item.type, () => []).add(item);
    }

    // Calculate total values for each type and sort
    final typeData = <Map<String, dynamic>>[];
    for (final entry in itemsByType.entries) {
      final type = entry.key;
      final items = entry.value;
      final totalValue = items.fold<double>(
        0,
        (sum, item) {
          // Convert item's value from its currency to USD
          final valueInUSD = currencyService.convertBetween(
            item.totalValue,
            item.currency,
            'USD',
          );
          return sum + valueInUSD;
        },
      );

      typeData.add({
        'type': type,
        'items': items,
        'totalValue': totalValue,
      });
    }

    // Sort by total value descending (highest first)
    typeData.sort((a, b) => (b['totalValue'] as double).compareTo(a['totalValue'] as double));

    final widgets = <Widget>[];

    for (final data in typeData) {
      final type = data['type'] as String;
      final items = data['items'] as List<PortfolioItem>;
      final totalValue = data['totalValue'] as double;

      final isCollapsed = _collapsedTypes.contains(type);

      // Category header (tappable to collapse/expand)
      widgets.add(
        InkWell(
          onTap: () {
            setState(() {
              if (isCollapsed) {
                _collapsedTypes.remove(type);
              } else {
                _collapsedTypes.add(type);
              }
            });
          },
          child: Padding(
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
                const SizedBox(width: 8),
                Icon(
                  isCollapsed ? Icons.expand_more : Icons.expand_less,
                  color: Colors.grey[600],
                  size: 20,
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
        ),
      );

      // Items in this category (hidden when collapsed)
      if (!isCollapsed) {
        final isStockOrCrypto = type == AppConstants.typeStocksAndETFs ||
            type == AppConstants.typeCrypto;

        for (final item in items) {
          final gainLossColor = item.gainLoss >= 0
              ? AppTheme.successColor
              : AppTheme.errorColor;

          widgets.add(
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showEditItemDialog(context, item),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Builder(
                    builder: (context) {
                      final sym = currencyService.getSymbol(item.currency);
                      final dec = item.currency == 'JPY' ? 0 : 2;
                      String fmt(double v) => NumberFormat.currency(symbol: sym, decimalDigits: dec).format(v);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name (+ symbol) + currency badge + edit icon
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (item.symbol != null && item.symbol!.isNotEmpty)
                                              TextSpan(
                                                text: '  ${item.symbol}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[500],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.currency,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (isStockOrCrypto) ...[
                            // Row 1: Date, Qty, Price, Total Cost
                            Row(
                              children: [
                                _detailChip('Date', DateFormat('MMM dd, yyyy').format(item.purchaseDate)),
                                const SizedBox(width: 12),
                                _detailChip('Qty', item.quantity.toStringAsFixed(2)),
                                const SizedBox(width: 12),
                                _detailChip('Price', fmt(item.purchasePrice)),
                                const SizedBox(width: 12),
                                _detailChip('Total Cost', fmt(item.totalCost)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Row 2: Date Sold, Fees, Current Value, Total Value
                            Row(
                              children: [
                                _detailChip('Date Sold', item.dateSold != null
                                    ? DateFormat('MMM dd, yyyy').format(item.dateSold!)
                                    : '-'),
                                const SizedBox(width: 12),
                                _detailChip('Fees', fmt(item.fees ?? 0.0)),
                                const SizedBox(width: 12),
                                _detailChip('Current', fmt(item.currentValue)),
                                const SizedBox(width: 12),
                                _detailChipColored(
                                  'Total Value',
                                  fmt(item.totalValue),
                                  gainLossColor,
                                ),
                              ],
                            ),
                          ] else ...[
                            // Simplified layout for other types
                            Row(
                              children: [
                                _detailChip('Date', DateFormat('MMM dd, yyyy').format(item.purchaseDate)),
                                const SizedBox(width: 12),
                                _detailChip('Cost', fmt(item.totalCost)),
                                const SizedBox(width: 12),
                                _detailChipColored(
                                  'Total Value',
                                  fmt(item.totalValue),
                                  gainLossColor,
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }
      }

      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  Widget _detailChip(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _detailChipColored(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'stocks & etfs':
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
      builder: (context) => const PortfolioItemDialog(),
    );
  }

  void _showEditItemDialog(BuildContext context, PortfolioItem item) {
    showDialog(
      context: context,
      builder: (context) => PortfolioItemDialog(item: item),
    );
  }
}

class PortfolioItemDialog extends StatefulWidget {
  final PortfolioItem? item;

  const PortfolioItemDialog({super.key, this.item});

  @override
  State<PortfolioItemDialog> createState() => _PortfolioItemDialogState();
}

class _PortfolioItemDialogState extends State<PortfolioItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _stockApiService = StockApiService();
  late String _type;
  late String _currency;
  late TextEditingController _nameController;
  late TextEditingController _symbolController;
  late TextEditingController _quantityController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _currentValueController;
  late TextEditingController _feesController;
  late DateTime _purchaseDate;
  DateTime? _dateSold;
  double? _suggestedPrice;
  bool _isLoadingPrice = false;
  String? _symbolLookupMessage;
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  final List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR',
    'AUD', 'CAD', 'CHF', 'BRL', 'ZAR', 'MXN', 'AED'
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.item?.type ?? AppConstants.portfolioTypes.first;
    _currency = widget.item?.currency ?? 'USD';
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _symbolController = TextEditingController(text: widget.item?.symbol ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '',
    );
    _purchasePriceController = TextEditingController(
      text: widget.item?.purchasePrice.toString() ?? '',
    );
    _currentValueController = TextEditingController(
      text: widget.item?.currentValue.toString() ?? '',
    );
    _feesController = TextEditingController(
      text: (widget.item?.fees ?? 0.0).toString(),
    );
    _purchaseDate = widget.item?.purchaseDate ?? DateTime.now();
    _dateSold = widget.item?.dateSold;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  double get _totalCost {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_purchasePriceController.text) ?? 0;
    final fees = double.tryParse(_feesController.text) ?? 0;
    return quantity * price + fees;
  }

  Future<void> _searchSymbols(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showSearchResults = false;
        _suggestedPrice = null;
        _symbolLookupMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _suggestedPrice = null;
      _symbolLookupMessage = null;
    });

    try {
      final results = await _stockApiService.searchSymbols(keyword);

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
        _showSearchResults = results.isNotEmpty;
        if (results.isEmpty) {
          _symbolLookupMessage = 'No results found. Try a different keyword.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showSearchResults = false;
        _symbolLookupMessage = 'Error searching. Please try again.';
      });
    }
  }

  Future<void> _selectSymbol(Map<String, String> match) async {
    final symbol = match['symbol'] ?? '';
    final name = match['name'] ?? symbol;
    final currency = match['currency'] ?? '';

    setState(() {
      _symbolController.text = symbol;
      _showSearchResults = false;
      _searchResults = [];
      _isLoadingPrice = true;
      _symbolLookupMessage = null;

      if (_nameController.text.isEmpty) {
        _nameController.text = name;
      }

      // Auto-set currency if it matches a supported one
      if (currency.isNotEmpty && _currencies.contains(currency)) {
        _currency = currency;
      }
    });

    try {
      final stockData = await _stockApiService.lookupStock(symbol);

      if (!mounted) return;

      setState(() {
        if (stockData != null && stockData['price'] != null) {
          _suggestedPrice = stockData['price'] as double;
          _currentValueController.text = _suggestedPrice!.toStringAsFixed(2);
          _symbolLookupMessage = '$name - ${_suggestedPrice!.toStringAsFixed(2)} $currency';
        } else {
          _suggestedPrice = null;
          _symbolLookupMessage = '$name selected. Enter current value manually.';
        }
        _isLoadingPrice = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _suggestedPrice = null;
        _symbolLookupMessage = '$name selected. Enter current value manually.';
        _isLoadingPrice = false;
      });
    }
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
      currentValue: _type == AppConstants.typeCash
          ? double.parse(_purchasePriceController.text)
          : double.tryParse(_currentValueController.text) ?? 0.0,
      purchaseDate: _purchaseDate,
      lastUpdated: DateTime.now(),
      currency: _currency,
      fees: double.tryParse(_feesController.text) ?? 0.0,
      symbol: _symbolController.text.isNotEmpty ? _symbolController.text : null,
      dateSold: _dateSold,
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
            'Symbol',
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
              hintText: 'Search by name or symbol (e.g. AAPL, VUAA)',
              helperText: _isLoadingPrice
                  ? 'Fetching price...'
                  : _symbolLookupMessage,
              helperStyle: TextStyle(
                color: _suggestedPrice != null
                    ? Colors.green[700]
                    : (_symbolLookupMessage != null ? Colors.orange[700] : null),
                fontWeight: _symbolLookupMessage != null
                    ? FontWeight.w600
                    : null,
              ),
              helperMaxLines: 2,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: _isSearching || _isLoadingPrice
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _suggestedPrice != null
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 24,
                        )
                      : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                _searchSymbols(value);
              } else {
                setState(() {
                  _searchResults = [];
                  _showSearchResults = false;
                  _suggestedPrice = null;
                  _symbolLookupMessage = null;
                  _isLoadingPrice = false;
                });
              }
            },
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          if (_showSearchResults && _searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                itemBuilder: (context, index) {
                  final match = _searchResults[index];
                  final typeLabel = match['type'] == 'ETF' ? 'ETF' : 'Stock';
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      '${match['symbol']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${match['name']}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '$typeLabel  ${match['region']}  ${match['currency']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () => _selectSymbol(match),
                  );
                },
              ),
            ),
        ],
      ),
      const SizedBox(height: 20),

      // Asset Name
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name',
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(color: Theme.of(context).colorScheme.outline),
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

      // Date Sold (optional)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Sold (optional)',
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
                initialDate: _dateSold ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _dateSold = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _dateSold != null
                        ? DateFormat('MMM dd, yyyy').format(_dateSold!)
                        : 'Not sold',
                    style: TextStyle(
                      fontSize: 16,
                      color: _dateSold != null ? null : Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (_dateSold != null)
                    GestureDetector(
                      onTap: () => setState(() => _dateSold = null),
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Fees
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fees',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _feesController,
            decoration: InputDecoration(
              hintText: 'Transaction fees',
              prefixIcon: Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Total Cost (calculated: price x quantity + fees)
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
                Expanded(
                  child: Text(
                    '\$${_totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '(${_quantityController.text.isEmpty ? '0' : _quantityController.text} × \$${_purchasePriceController.text.isEmpty ? '0' : _purchasePriceController.text} + \$${_feesController.text.isEmpty ? '0' : _feesController.text})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(color: Theme.of(context).colorScheme.outline),
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
      // Current Value (hidden for Cash - always equals purchase price)
      if (_type != AppConstants.typeCash) ...[
        const SizedBox(height: 20),
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
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
      ],
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                        initialValue: _type,
                        decoration: InputDecoration(
                          hintText: 'Select asset type',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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

                  // Currency
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Currency',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: InputDecoration(
                          hintText: 'Select currency',
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        items: _currencies
                            .map((currency) => DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _currency = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dynamic fields based on asset type
                  if (_type == AppConstants.typeStocksAndETFs || _type == AppConstants.typeCrypto)
                    ..._buildSharesFields(context)
                  else if (_isSimplifiedAssetType())
                    ..._buildSimplifiedFields(context)
                  else
                    ..._buildGenericFields(context),

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Theme.of(context).dividerColor)),
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
                        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
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

// Helper widget for displaying detail items in tracker tab
