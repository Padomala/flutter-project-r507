class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isConnected;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isConnected = false,
  });

  const UserModel.guest()
    : id = 'guest',
      name = 'Guest',
      email = 'not connected',
      avatarUrl = null,
      isConnected = false;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isConnected,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
