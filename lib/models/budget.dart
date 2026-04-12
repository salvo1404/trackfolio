import 'dart:convert';

class Budget {
  final String id;
  final String category;
  final double amount;
  final String period; // monthly, quarterly, yearly
  final double spent;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.period,
    required this.spent,
    required this.createdAt,
  });

  double get remaining => amount - spent;
  double get percentUsed => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period,
      'spent': spent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      period: json['period'],
      spent: (json['spent'] as num).toDouble(),
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
    double? amount,
    String? period,
    double? spent,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      spent: spent ?? this.spent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
