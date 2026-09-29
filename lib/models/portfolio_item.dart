import 'dart:convert';
import 'dart:math' as math;
import '../utils/constants.dart';

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
  final double? interestRate; // Annual loan interest rate in % (SBLOC)

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
    this.interestRate,
  });

  double get totalValue => quantity * currentValue;
  double get totalCost => quantity * purchasePrice + (fees ?? 0.0);
  double get gainLoss => totalValue - totalCost;
  double get gainLossPercent => totalCost > 0 ? (gainLoss / totalCost) * 100 : 0;

  bool get isSbloc => type == AppConstants.typeSBLOC;

  /// Asset category this item rolls up into in summaries (SBLOC counts against Stocks & ETFs).
  String get summaryType => isSbloc ? AppConstants.typeStocksAndETFs : type;

  /// Monthly payment for a fully amortizing loan.
  static double amortizedMonthlyPayment(double principal, double annualRatePercent, int years) {
    final months = years * 12;
    if (principal <= 0 || months <= 0) return 0;
    final r = annualRatePercent / 100 / 12;
    if (r <= 0) return principal / months;
    final g = math.pow(1 + r, months).toDouble();
    return principal * r * g / (g - 1);
  }

  /// Outstanding balance after [months] payments.
  static double loanBalanceAfter(double principal, double monthly, double annualRatePercent, int months) {
    final r = annualRatePercent / 100 / 12;
    final double remaining;
    if (r > 0) {
      final g = math.pow(1 + r, months).toDouble();
      remaining = principal * g - monthly * (g - 1) / r;
    } else {
      remaining = principal - monthly * months;
    }
    return remaining < 0 ? 0 : remaining;
  }

  double? get mortgageRemaining {
    if (mortgagePrincipal == null || monthlyRepayment == null) return null;
    final now = DateTime.now();
    final monthsPassed =
        (now.year - purchaseDate.year) * 12 + (now.month - purchaseDate.month);
    return loanBalanceAfter(
      mortgagePrincipal!,
      monthlyRepayment!,
      interestRate ?? 0,
      monthsPassed < 0 ? 0 : monthsPassed,
    );
  }

  double get netEquityValue {
    final remaining = mortgageRemaining;
    if (remaining == null) return totalValue;
    final equity = totalValue - remaining;
    return equity < 0 ? 0 : equity;
  }

  /// Value counted in portfolio totals: net equity for real estate, negative balance for SBLOC.
  double get netValue {
    if (isSbloc) return -(mortgageRemaining ?? 0);
    if (type == AppConstants.typeRealEstate) return netEquityValue;
    return totalValue;
  }

  /// Cost counted in portfolio totals: own equity for real estate, negative principal for SBLOC.
  double get netCost {
    if (isSbloc) return -(mortgagePrincipal ?? purchasePrice);
    if (type == AppConstants.typeRealEstate && mortgagePrincipal != null) {
      final cost = purchasePrice - mortgagePrincipal!;
      return cost < 0 ? 0 : cost;
    }
    return totalCost;
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
      'interestRate': interestRate,
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
      interestRate: (json['interestRate'] as num?)?.toDouble(),
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
    double? interestRate,
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
      interestRate: interestRate ?? this.interestRate,
    );
  }
}
