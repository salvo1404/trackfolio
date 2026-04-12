import 'dart:convert';

class ShareTransaction {
  final String id;
  final String shareName;
  final String symbol;
  final String type; // 'buy' or 'sell'
  final double quantity;
  final double pricePerShare;
  final DateTime transactionDate;
  final String notes;
  final DateTime createdAt;

  ShareTransaction({
    required this.id,
    required this.shareName,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.pricePerShare,
    required this.transactionDate,
    required this.notes,
    required this.createdAt,
  });

  double get totalAmount => quantity * pricePerShare;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shareName': shareName,
      'symbol': symbol,
      'type': type,
      'quantity': quantity,
      'pricePerShare': pricePerShare,
      'transactionDate': transactionDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShareTransaction.fromJson(Map<String, dynamic> json) {
    return ShareTransaction(
      id: json['id'],
      shareName: json['shareName'],
      symbol: json['symbol'],
      type: json['type'],
      quantity: (json['quantity'] as num).toDouble(),
      pricePerShare: (json['pricePerShare'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ShareTransaction.fromJsonString(String jsonString) {
    return ShareTransaction.fromJson(jsonDecode(jsonString));
  }

  ShareTransaction copyWith({
    String? id,
    String? shareName,
    String? symbol,
    String? type,
    double? quantity,
    double? pricePerShare,
    DateTime? transactionDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return ShareTransaction(
      id: id ?? this.id,
      shareName: shareName ?? this.shareName,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
