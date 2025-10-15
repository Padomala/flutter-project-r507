import 'dart:convert';

class UserModel {
  // we create the variable
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  // we create the model UserModel (constructor)
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  // we create the data from the JSON (replace with fetch the data from the database)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  // we have a toJson method to send the object list into a string form (useful to send data to a database)
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
  String toString() {
    return jsonEncode(toJson());
  }


  @override
  int get hashCode => id.hashCode;
}