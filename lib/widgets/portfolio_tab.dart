import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/portfolio_service.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';
import '../utils/theme.dart';
import '../utils/currency_formatter.dart';
import '../models/portfolio_item.dart';

class PortfolioTab extends StatelessWidget {
  const PortfolioTab({super.key});

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Overview with Asset Allocation
            if (portfolioService.portfolioItems.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Portfolio Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currencyFormatter.getCurrencyCode(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (portfolioService.isRefreshingPrices || portfolioService.priceRefreshStatus != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (portfolioService.isRefreshingPrices) ...[
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      portfolioService.priceRefreshStatus ?? 'Updating prices...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;

                  if (isWideScreen) {
                    // Wide screen: side-by-side layout
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Total Portfolio Details
                            Expanded(
                              child: _buildPortfolioStats(
                                context,
                                portfolioService,
                                currencyFormatter,
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Asset Allocation Chart
                            Expanded(
                              flex: 2,
                              child: _buildAssetAllocation(
                                context,
                                portfolioService,
                                currencyFormatter,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Mobile: stacked layout
                    return Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: _buildPortfolioStats(
                              context,
                              portfolioService,
                              currencyFormatter,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: _buildAssetAllocation(
                              context,
                              portfolioService,
                              currencyFormatter,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ] else ...[
              // Show just the total when no items
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Portfolio Value',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              currencyFormatter.getCurrencyCode(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(
                          portfolioService.totalPortfolioValue,
                        ),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Portfolio Value Over Time
            if (portfolioService.portfolioItems
                .where((item) => item.dateSold == null)
                .isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildPortfolioValueChart(
                portfolioService,
                currencyFormatter,
                currencyService,
                context,
              ),
            ],

            const SizedBox(height: 24),

            // Asset Type Summary
            if (portfolioService.portfolioItems.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Assets by Type',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      currencyFormatter.getCurrencyCode(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._buildAssetTypeSummary(portfolioService, currencyFormatter, currencyService),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioStats(
    BuildContext context,
    PortfolioService portfolioService,
    CurrencyFormatter currencyFormatter,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          // Wide screen: vertical stack
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Total Portfolio Value',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      currencyFormatter.getCurrencyCode(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(portfolioService.totalPortfolioValue),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              _StatItem(
                label: 'Cost',
                value: currencyFormatter.format(
                  portfolioService.totalPortfolioCost,
                ),
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              _StatItem(
                label: 'Gain/Loss',
                value: currencyFormatter.format(portfolioService.totalGainLoss),
                color: portfolioService.totalGainLoss >= 0
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
              ),
            ],
          );
        } else {
          // Mobile: use full width with horizontal stats
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Total Portfolio Value',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      currencyFormatter.getCurrencyCode(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(portfolioService.totalPortfolioValue),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Cost',
                      value: currencyFormatter.format(
                        portfolioService.totalPortfolioCost,
                      ),
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _StatItem(
                      label: 'Gain/Loss',
                      value: currencyFormatter.format(
                        portfolioService.totalGainLoss,
                      ),
                      color: portfolioService.totalGainLoss >= 0
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildAssetAllocation(
    BuildContext context,
    PortfolioService portfolioService,
    CurrencyFormatter currencyFormatter,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          // Wide screen: pie chart and legend side-by-side
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asset Allocation',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 280,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(
                            portfolioService.portfolioByType,
                            portfolioService.totalPortfolioValue,
                          ),
                          sectionsSpace: 2,
                          centerSpaceRadius: 55,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildLegend(
                        portfolioService.portfolioByType,
                        currencyFormatter,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          // Mobile: pie chart and legend stacked vertically
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asset Allocation',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(
                      portfolioService.portfolioByType,
                      portfolioService.totalPortfolioValue,
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(portfolioService.portfolioByType, currencyFormatter),
            ],
          );
        }
      },
    );
  }

  Widget _buildPortfolioValueChart(
    PortfolioService portfolioService,
    CurrencyFormatter currencyFormatter,
    CurrencyService currencyService,
    BuildContext context,
  ) {
    final activeItems = portfolioService.portfolioItems
        .where((item) => item.dateSold == null)
        .toList();

    activeItems.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));

    if (activeItems.isEmpty) return const SizedBox.shrink();

    return _PortfolioValueChart(
      activeItems: activeItems,
      currencyFormatter: currencyFormatter,
      currencyService: currencyService,
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> portfolioByType,
    double total,
  ) {
    final entries = portfolioByType.entries.toList();
    return entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total) * 100 : 0;
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: AppTheme.getPortfolioTypeColor(entry.key),
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(
    Map<String, double> portfolioByType,
    CurrencyFormatter currencyFormatter,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: portfolioByType.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.getPortfolioTypeColor(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(entry.value),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
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

  List<Widget> _buildAssetTypeSummary(
    PortfolioService portfolioService,
    CurrencyFormatter currencyFormatter,
    CurrencyService currencyService,
  ) {
    // Group items by type and calculate totals
    final itemsByType = <String, List<PortfolioItem>>{};
    for (final item in portfolioService.portfolioItems) {
      itemsByType.putIfAbsent(item.type, () => []).add(item);
    }

    // Calculate totals for each type
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
      final totalCost = items.fold<double>(
        0,
        (sum, item) {
          // Convert item's cost from its currency to USD
          final costInUSD = currencyService.convertBetween(
            item.totalCost,
            item.currency,
            'USD',
          );
          return sum + costInUSD;
        },
      );

      typeData.add({
        'type': type,
        'items': items,
        'totalValue': totalValue,
        'totalCost': totalCost,
      });
    }

    // Sort by total value descending (highest first)
    typeData.sort((a, b) => (b['totalValue'] as double).compareTo(a['totalValue'] as double));

    final widgets = <Widget>[];

    for (final data in typeData) {
      final type = data['type'] as String;
      final items = data['items'] as List<PortfolioItem>;
      final totalValue = data['totalValue'] as double;
      final totalCost = data['totalCost'] as double;

      widgets.add(
        _ExpandableTypeCard(
          type: type,
          items: items,
          totalValue: totalValue,
          totalCost: totalCost,
          currencyFormatter: currencyFormatter,
          currencyService: currencyService,
          icon: _getIconForType(type),
        ),
      );
    }

    return widgets;
  }
}

class _ExpandableTypeCard extends StatefulWidget {
  final String type;
  final List<PortfolioItem> items;
  final double totalValue;
  final double totalCost;
  final CurrencyFormatter currencyFormatter;
  final CurrencyService currencyService;
  final IconData icon;

  const _ExpandableTypeCard({
    required this.type,
    required this.items,
    required this.totalValue,
    required this.totalCost,
    required this.currencyFormatter,
    required this.currencyService,
    required this.icon,
  });

  @override
  State<_ExpandableTypeCard> createState() => _ExpandableTypeCardState();
}

class _ExpandableTypeCardState extends State<_ExpandableTypeCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalGainLoss = widget.totalValue - widget.totalCost;
    final gainLossColor = totalGainLoss >= 0
        ? AppTheme.successColor
        : AppTheme.errorColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.getPortfolioTypeColor(
                        widget.type,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppTheme.getPortfolioTypeColor(widget.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.type,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.items.map((e) => e.name).toSet().length} ${widget.items.map((e) => e.name).toSet().length == 1 ? 'item' : 'items'}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.currencyFormatter.format(widget.totalValue),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: gainLossColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${totalGainLoss >= 0 ? '+' : ''}${widget.currencyFormatter.format(totalGainLoss)}',
                          style: TextStyle(
                            color: gainLossColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    children: [
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                      ..._buildAggregatedItems(context),
                      const SizedBox(height: 4),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAggregatedItems(BuildContext context) {
    // Group items by name to aggregate duplicates
    final grouped = <String, List<PortfolioItem>>{};
    for (final item in widget.items) {
      grouped.putIfAbsent(item.name, () => []).add(item);
    }

    final rows = grouped.entries.map((entry) {
      final items = entry.value;
      double totalValueUSD = 0;
      double totalCostUSD = 0;
      double totalQty = 0;

      for (final item in items) {
        totalValueUSD += widget.currencyService.convertBetween(
          item.totalValue,
          item.currency,
          'USD',
        );
        totalCostUSD += widget.currencyService.convertBetween(
          item.totalCost,
          item.currency,
          'USD',
        );
        totalQty += item.quantity;
      }

      return (
        name: entry.key,
        qty: totalQty,
        valueUSD: totalValueUSD,
        gainLoss: totalValueUSD - totalCostUSD,
      );
    }).toList();

    // Sort by value descending
    rows.sort((a, b) => b.valueUSD.compareTo(a.valueUSD));

    return rows.map((row) {
      final gainLossColor =
          row.gainLoss >= 0 ? AppTheme.successColor : AppTheme.errorColor;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 72),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Qty: ${row.qty % 1 == 0 ? row.qty.toInt() : row.qty}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.currencyFormatter.format(row.valueUSD),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: gainLossColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${row.gainLoss >= 0 ? '+' : ''}${widget.currencyFormatter.format(row.gainLoss)}',
                    style: TextStyle(
                      color: gainLossColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PortfolioValueChart extends StatefulWidget {
  final List<PortfolioItem> activeItems;
  final CurrencyFormatter currencyFormatter;
  final CurrencyService currencyService;

  const _PortfolioValueChart({
    required this.activeItems,
    required this.currencyFormatter,
    required this.currencyService,
  });

  @override
  State<_PortfolioValueChart> createState() => _PortfolioValueChartState();
}

class _PortfolioValueChartState extends State<_PortfolioValueChart> {
  final Set<String> _hiddenTypes = {};

  @override
  Widget build(BuildContext context) {
    final items = widget.activeItems;
    final currencyFormatter = widget.currencyFormatter;
    final currencyService = widget.currencyService;

    // Collect all unique types in order of appearance
    final typeOrder = <String>[];
    for (final item in items) {
      if (!typeOrder.contains(item.type)) typeOrder.add(item.type);
    }

    // Build cumulative value per type at each timeline point
    final Map<String, List<FlSpot>> typeSpots = {
      for (final type in typeOrder) type: [],
    };
    final Map<String, double> runningTotals = {
      for (final type in typeOrder) type: 0,
    };

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final valueUsd = currencyService.convertBetween(
        item.totalValue,
        item.currency,
        'USD',
      );
      runningTotals[item.type] = runningTotals[item.type]! + valueUsd;

      for (final type in typeOrder) {
        typeSpots[type]!.add(FlSpot(i.toDouble(), runningTotals[type]!));
      }
    }

    // Visible types only
    final visibleTypes =
        typeOrder.where((t) => !_hiddenTypes.contains(t)).toList();

    double maxY = 0;
    for (final type in visibleTypes) {
      maxY = math.max(maxY, runningTotals[type]!);
    }
    final chartMax = maxY == 0 ? 100.0 : maxY * 1.15;

    // Build line data for visible types only
    final lineBars = <LineChartBarData>[];
    for (final type in visibleTypes) {
      final color = AppTheme.getPortfolioTypeColor(type);
      lineBars.add(
        LineChartBarData(
          spots: typeSpots[type]!,
          isCurved: true,
          curveSmoothness: 0.3,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3.5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: color,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.area_chart_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Portfolio Value Over Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: typeOrder.map((type) {
                final isVisible = !_hiddenTypes.contains(type);
                final color = AppTheme.getPortfolioTypeColor(type);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isVisible) {
                        _hiddenTypes.add(type);
                      } else {
                        _hiddenTypes.remove(type);
                      }
                    });
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isVisible ? 1.0 : 0.4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isVisible
                            ? color.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isVisible
                              ? color.withValues(alpha: 0.4)
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isVisible ? color : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isVisible
                                  ? color
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: visibleTypes.isEmpty
                  ? Center(
                      child: Text(
                        'Tap a type above to show its line',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: chartMax,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final type = visibleTypes[spot.barIndex];
                                final color =
                                    AppTheme.getPortfolioTypeColor(type);
                                return LineTooltipItem(
                                  '$type\n${currencyFormatter.format(spot.y)}',
                                  TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: chartMax / 4,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withValues(alpha: 0.15),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              interval: math.max(1,
                                  (items.length / 5).ceil().toDouble()),
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= items.length) {
                                  return const SizedBox.shrink();
                                }
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 6,
                                  child: Text(
                                    DateFormat('MMM yy')
                                        .format(items[index].purchaseDate),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  currencyFormatter.formatCompact(value),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: lineBars,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

