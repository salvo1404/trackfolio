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
            Theme.of(context).colorScheme.primary.withOpacity(0.02),
            Theme.of(context).colorScheme.secondary.withOpacity(0.02),
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
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
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
                              ).colorScheme.primary.withOpacity(0.1),
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
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
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
                      ).colorScheme.primary.withOpacity(0.1),
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
                      ).colorScheme.primary.withOpacity(0.1),
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
      final totalGainLoss = totalValue - totalCost;
      final gainLossColor = totalGainLoss >= 0
          ? AppTheme.successColor
          : AppTheme.errorColor;

      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.getPortfolioTypeColor(
                      type,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(type),
                    color: AppTheme.getPortfolioTypeColor(type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormatter.format(totalValue),
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
                        color: gainLossColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${totalGainLoss >= 0 ? '+' : ''}${currencyFormatter.format(totalGainLoss)}',
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
        ),
      );
    }

    return widgets;
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
