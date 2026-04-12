import 'dart:convert';

class Transaction {
  final String id;
  final DateTime date;
  final String type; // income, expense
  final String category;
  final double amount;
  final String description;

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Transaction.fromJsonString(String jsonString) {
    return Transaction.fromJson(jsonDecode(jsonString));
  }
}
