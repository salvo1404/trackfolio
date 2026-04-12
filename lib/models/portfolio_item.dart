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
  });

  double get totalValue => quantity * currentValue;
  double get totalCost => quantity * purchasePrice;
  double get gainLoss => totalValue - totalCost;
  double get gainLossPercent => totalCost > 0 ? (gainLoss / totalCost) * 100 : 0;

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
    };
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      quantity: (json['quantity'] as num).toDouble(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      currency: json['currency'] ?? 'USD', // Default to USD if not present
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
    );
  }
}
