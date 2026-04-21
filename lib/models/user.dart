import 'dart:convert';

class User {
  final String uid;
  final String email;
  final DateTime createdAt;
  final String? displayName;
  final String? photoUrl;
  final String? country;
  final String? currency;
  final String? fullName;
  final String? phoneNumber;

  User({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.displayName,
    this.photoUrl,
    this.country,
    this.currency,
    this.fullName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'displayName': displayName,
      'photoUrl': photoUrl,
      'country': country,
      'currency': currency,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      country: json['country'],
      currency: json['currency'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
    );
  }

  User copyWith({
    String? uid,
    String? email,
    DateTime? createdAt,
    String? displayName,
    String? photoUrl,
    String? country,
    String? currency,
    String? fullName,
    String? phoneNumber,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
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
