import 'dart:convert';

class PortfolioItem {
  final String id;
  final String type; // shares, crypto, real-estate, watches, cash
  final String name;
  final double quantity;
  final double purchasePrice;
  final double currentValue;
  final DateTime purchaseDate;
  final DateTime lastUpdated;
  final String currency; // Currency code (USD, EUR, etc.)
  final double? fees; // Transaction fees
  final String? symbol; // Ticker symbol (for stocks/ETFs/crypto)
  final DateTime? dateSold; // Date the asset was sold
  final double? mortgagePrincipal; // Original mortgage amount
  final int? mortgageLengthYears; // Mortgage term in years
  final double? monthlyRepayment; // Monthly mortgage payment

  PortfolioItem({
    required this.id,
    required this.type,
    required this.name,
    required this.quantity,
    required this.purchasePrice,
    required this.currentValue,
    required this.purchaseDate,
    required this.lastUpdated,
    this.currency = 'USD', // Default to USD
    this.fees = 0.0,
    this.symbol,
    this.dateSold,
    this.mortgagePrincipal,
    this.mortgageLengthYears,
    this.monthlyRepayment,
  });

  double get totalValue => quantity * currentValue;
  double get totalCost => quantity * purchasePrice + (fees ?? 0.0);
  double get gainLoss => totalValue - totalCost;
  double get gainLossPercent => totalCost > 0 ? (gainLoss / totalCost) * 100 : 0;

  double? get mortgageRemaining {
    if (mortgagePrincipal == null || monthlyRepayment == null) return null;
    final now = DateTime.now();
    final monthsPassed =
        (now.year - purchaseDate.year) * 12 + (now.month - purchaseDate.month);
    final remaining = mortgagePrincipal! - (monthlyRepayment! * monthsPassed);
    return remaining < 0 ? 0 : remaining;
  }

  double get netEquityValue {
    final remaining = mortgageRemaining;
    if (remaining == null) return totalValue;
    final equity = totalValue - remaining;
    return equity < 0 ? 0 : equity;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'currentValue': currentValue,
      'purchaseDate': purchaseDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'currency': currency,
      'fees': fees ?? 0.0,
      'symbol': symbol,
      'dateSold': dateSold?.toIso8601String(),
      'mortgagePrincipal': mortgagePrincipal,
      'mortgageLengthYears': mortgageLengthYears,
      'monthlyRepayment': monthlyRepayment,
    };
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'],
      type: json['type'] == 'Shares' ? 'Stocks & ETFs' : json['type'],
      name: json['name'],
      quantity: (json['quantity'] as num).toDouble(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      currency: json['currency'] ?? 'USD', // Default to USD if not present
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      symbol: json['symbol'] as String?,
      dateSold: json['dateSold'] != null ? DateTime.parse(json['dateSold']) : null,
      mortgagePrincipal: (json['mortgagePrincipal'] as num?)?.toDouble(),
      mortgageLengthYears: (json['mortgageLengthYears'] as num?)?.toInt(),
      monthlyRepayment: (json['monthlyRepayment'] as num?)?.toDouble(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory PortfolioItem.fromJsonString(String jsonString) {
    return PortfolioItem.fromJson(jsonDecode(jsonString));
  }

  PortfolioItem copyWith({
    String? id,
    String? type,
    String? name,
    double? quantity,
    double? purchasePrice,
    double? currentValue,
    DateTime? purchaseDate,
    DateTime? lastUpdated,
    String? currency,
    double? fees,
    String? symbol,
    DateTime? dateSold,
    double? mortgagePrincipal,
    int? mortgageLengthYears,
    double? monthlyRepayment,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currency: currency ?? this.currency,
      fees: fees ?? this.fees,
      symbol: symbol ?? this.symbol,
      dateSold: dateSold ?? this.dateSold,
      mortgagePrincipal: mortgagePrincipal ?? this.mortgagePrincipal,
      mortgageLengthYears: mortgageLengthYears ?? this.mortgageLengthYears,
      monthlyRepayment: monthlyRepayment ?? this.monthlyRepayment,
    );
  }
}
