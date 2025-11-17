import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() => jsonEncode(toJson());

  @override
  int get hashCode => id.hashCode;
}






/// -------------------------
/// Test data inside this file
/// -------------------------




// A sample “backend-like” object
const Map<String, dynamic> testUserJson = {
  'id': '001',
  'name': 'John Doe',
  'email': 'john@test.com',
  'avatarUrl': 'https://example.com/avatar.jpg',
};

// Convert test JSON into a UserModel instance
final UserModel testUser = UserModel.fromJson(testUserJson);


