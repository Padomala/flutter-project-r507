class Room {
  final String id;
  final String hostId;
  final String status; // 'waiting', 'playing', 'finished'
  final String? code;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.hostId,
    required this.status,
    this.code,
    this.settings,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      hostId: json['host_id'],
      status: json['status'] ?? 'waiting',
      code: json['code'],
      settings: json['settings'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class RoomParticipant {
  final String id; // user_id
  final String roomId;
  final bool isHost;
  final DateTime joinedAt;
  final String? pseudo; // Joined from profiles potentially
  final String? avatarUrl;

  RoomParticipant({
    required this.id,
    required this.roomId,
    required this.isHost,
    required this.joinedAt,
    this.pseudo,
    this.avatarUrl,
  });

  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    // Safe parsing for profiles (can be Map or List depending on Supabase version/relation detection)
    final profileData = json['profiles'];
    String? pseudoVar = 'Unknown';
    String? avatarUrlVar;

    if (profileData is Map) {
      pseudoVar = profileData['username'];
      avatarUrlVar = profileData['avatar_url'];
    } else if (profileData is List && profileData.isNotEmpty) {
      pseudoVar = profileData[0]['username'];
      avatarUrlVar = profileData[0]['avatar_url'];
    }

    return RoomParticipant(
      id: json['user_id'],
      roomId: json['room_id'],
      isHost: json['is_host'] ?? false,
      joinedAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()), 
      pseudo: pseudoVar ?? 'Unknown', 
      avatarUrl: avatarUrlVar,
    );
  }
}
