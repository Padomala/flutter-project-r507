import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing Supabase credentials. '
        'Pass SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define or '
        'update lib/core/services/supabase_config.dart.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _initialized = true;
  }

  // static SupabaseClient get client {
  //   if (!_initialized) {
  //     throw StateError(
  //       'SupabaseService.initialize must be called before accessing the client.',
  //     );
  //   }

  //   return Supabase.instance.client;
  // }


  // SIGN IN
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
      );
  }


  // SIGN UP
  Future<AuthResponse> signUp(String email, String password, {String? username}) async {
    print("DEBUG SIGNUP - Email: '$email' (len: ${email.length}), Password: '$password', Username: '$username'");
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: username != null ? {'name': username} : null, // Sending metadata
      );
  }


  // UPDATE PROFILE
  Future<void> updateProfile(String userId, {String? username, String? avatarUrl}) async {
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl; // Save path or URL

    if (updates.isNotEmpty) {
      // Update public profile
      await _supabase.from('profiles').update(updates).eq('id', userId);

      // Optionally update auth metadata if name or avatar changed
      final metadataUpdates = <String, dynamic>{};
      if (username != null) metadataUpdates['name'] = username;
      if (avatarUrl != null) metadataUpdates['avatar_url'] = avatarUrl;
      
      if (metadataUpdates.isNotEmpty) {
        await _supabase.auth.updateUser(
          UserAttributes(data: metadataUpdates),
        );
      }
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  
  // GET USER MAIL
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  String? getCurrentUserId() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }

  // --- ROOMS ---

  /// Creates a new room. Returns the created room data.
  Future<Map<String, dynamic>> createRoom(String userId, {Map<String, dynamic>? settings}) async {
    // Generate a simple random room code (e.g., 6 chars)
    final code = DateTime.now().millisecondsSinceEpoch.toString().substring(7); // Simple unique-ish code

    final response = await _supabase.from('rooms').insert({
      'host_id': userId,
      'status': 'waiting',
      'code': code,
      'settings': settings,
    }).select().single();

    // Automatically add host as participant
    await _supabase.from('room_participants').insert({
      'room_id': response['id'],
      'user_id': userId,
      'is_host': true,
    });

    return response;
  }

  /// Joins a room by code. Returns the room data.
  Future<Map<String, dynamic>> joinRoom(String roomCode, String userId) async {
    // 1. Find the room
    final roomData = await _supabase
        .from('rooms')
        .select()
        .eq('code', roomCode)
        .single();
    
    final roomId = roomData['id'];

    // 2. Check if already joined (optional, but good practice)
    final existingParams = await _supabase
        .from('room_participants')
        .select()
        .eq('room_id', roomId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingParams == null) {
      // 3. Check if room is full (max 2 players)
      final currentParticipants = await _supabase
          .from('room_participants')
          .select()
          .eq('room_id', roomId);
      
      if (currentParticipants.length >= 2) {
        throw Exception('La room est pleine (maximum 2 joueurs)');
      }

      // 4. Add to participants
      await _supabase.from('room_participants').insert({
        'room_id': roomId,
        'user_id': userId,
        'is_host': false,
      });
    }

    return roomData;
  }

  /// Get room by ID
  Future<Map<String, dynamic>> getRoomById(String roomId) async {
    return await _supabase
        .from('rooms')
        .select()
        .eq('id', roomId)
        .single();
  }

  /// Leaves a room
  Future<void> leaveRoom(String roomId, String userId) async {
    // Check if I am host before deleting my row
    final participant = await _supabase
        .from('room_participants')
        .select()
        .eq('room_id', roomId)
        .eq('user_id', userId)
        .maybeSingle();

    if (participant != null) {
      final bool isHost = participant['is_host'] ?? false;
      
      await _supabase
          .from('room_participants')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', userId);

      // If host left, delete the room entirely
      if (isHost) {
        await _supabase.from('rooms').delete().eq('id', roomId);
      }
    }
  }
  
  /// Start the game (Host only)
  Future<void> startGame(String roomId) async {
    await _supabase.from('rooms').update({'status': 'playing'}).eq('id', roomId);
  }

  /// Get participants for a room
  Future<List<Map<String, dynamic>>> getRoomParticipants(String roomId) async {
    // We assume there's a profiles table linked? The user prompt implied standard setup.
    // If not, we might fail fetching pseudo/avatar.
    // Let's try to fetch user metadata if possible, but standard 'auth.users' is not directly queryable via join easily unless views strictly set up.
    // We will fetch participants and then maybe we rely on their user_id to display something or fetch profile separately if a table exists.
    // For this step, I'll fetch room_participants.
    final response = await _supabase
        .from('room_participants')
        .select('*, profiles(*)') 
        .eq('room_id', roomId);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Subscribe to room changes (participants joining/leaving, status changes)
  RealtimeChannel subscribeToRoom(String roomId, void Function(PostgresChangePayload) callback) {
    return _supabase.channel('public:rooms:$roomId')
      // Listen to ALL changes on room_participants (INSERT, UPDATE, DELETE)
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'room_participants',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq, 
          column: 'room_id', 
          value: roomId
        ),
        callback: callback,
      )
      // Listen to UPDATE and DELETE on rooms table
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'rooms',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq, 
          column: 'id', 
          value: roomId
        ),
        callback: callback,
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'rooms',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq, 
          column: 'id', 
          value: roomId
        ),
        callback: callback,
      )
      .subscribe();
  }

  void unsubscribeRoom(RealtimeChannel channel) {
    _supabase.removeChannel(channel);
  }
}

