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
    // Note: This assumes we might join with a profiles table or have data in metadata
    // Adjust based on actual data structure returned by Supabase
    return RoomParticipant(
      id: json['user_id'],
      roomId: json['room_id'],
      isHost: json['is_host'] ?? false,
      joinedAt: DateTime.parse(json['joined_at']),
      // If we join with profiles, we might have these fields. 
      // For now we might need to fetch them separately or they might be null
      pseudo: json['profiles']?['username'] ?? 'Unknown', 
      avatarUrl: json['profiles']?['avatar_url'],
    );
  }
}
