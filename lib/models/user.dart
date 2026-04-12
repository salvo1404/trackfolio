import 'dart:convert';

class User {
  final String username;
  final String email;
  final String password;
  final DateTime createdAt;
  final String? photoUrl;
  final String? country;
  final String? currency;
  final String? fullName;
  final String? phoneNumber;

  User({
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
    this.photoUrl,
    this.country,
    this.currency,
    this.fullName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
      'country': country,
      'currency': currency,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
      photoUrl: json['photoUrl'],
      country: json['country'],
      currency: json['currency'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
    );
  }

  User copyWith({
    String? username,
    String? email,
    String? password,
    DateTime? createdAt,
    String? photoUrl,
    String? country,
    String? currency,
    String? fullName,
    String? phoneNumber,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }
}
