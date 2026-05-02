import 'dart:convert';

class Budget {
  final String id;
  final String category;
  final String name;
  final double amount;
  final String period; // weekly, monthly, quarterly, yearly
  final String currency;
  final String paymentMethod;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.category,
    this.name = '',
    required this.amount,
    required this.period,
    this.currency = 'USD',
    this.paymentMethod = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'amount': amount,
      'period': period,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      name: json['name'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      period: json['period'],
      currency: json['currency'] ?? 'USD',
      paymentMethod: json['paymentMethod'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Budget.fromJsonString(String jsonString) {
    return Budget.fromJson(jsonDecode(jsonString));
  }

  Budget copyWith({
    String? id,
    String? category,
    String? name,
    double? amount,
    String? period,
    String? currency,
    String? paymentMethod,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
