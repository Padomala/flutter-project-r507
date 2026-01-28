import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../model/room_model.dart';

class RoomProvider with ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  Room? _currentRoom;
  List<RoomParticipant> _participants = [];
  bool _isLoading = false;
  RealtimeChannel? _roomChannel;

  Room? get currentRoom => _currentRoom;
  List<RoomParticipant> get participants => _participants;
  bool get isLoading => _isLoading;

  // Helper to know if I am host
  bool get amIHost {
    final myId = _service.getCurrentUserId();
    if (myId == null || _currentRoom == null) return false;
    return _currentRoom!.hostId == myId;
  }

  // Helper to check if room is full (assuming 2 players max for now based on UI)
  bool get isRoomFull => _participants.length >= 2;

  /// Create a room
  Future<void> createRoom({Map<String, dynamic>? settings}) async {
    _setLoading(true);
    try {
      final userId = _service.getCurrentUserId();
      if (userId == null) throw Exception("User not logged in");

      final roomData = await _service.createRoom(userId, settings: settings);
      _currentRoom = Room.fromJson(roomData);

      await _refreshParticipants();
      _subscribeToRoom();
    } catch (e) {
      debugPrint("Error creating room: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Join a room
  Future<void> joinRoom(String code) async {
    _setLoading(true);
    try {
      final userId = _service.getCurrentUserId();
      if (userId == null) throw Exception("User not logged in");

      final roomData = await _service.joinRoom(code, userId);
      _currentRoom = Room.fromJson(roomData);

      await _refreshParticipants();
      _subscribeToRoom();
    } catch (e) {
      debugPrint("Error joining room: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Start the game
  Future<void> startGame() async {
    if (_currentRoom == null) return;
    try {
      await _service.startGame(_currentRoom!.id);
      // Local update optimization
      // _currentRoom = Room(id: _currentRoom!.id, hostId: _currentRoom!.hostId, status: 'playing', code: _currentRoom!.code, settings: _currentRoom!.settings, createdAt: _currentRoom!.createdAt);
      // notifyListeners();
    } catch (e) {
      debugPrint("Error starting game: $e");
      rethrow;
    }
  }

  /// Leave current room
  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;
    final userId = _service.getCurrentUserId();
    if (userId != null) {
      try {
        await _service.leaveRoom(_currentRoom!.id, userId);
      } catch (e) {
        debugPrint("Check leave room error: $e");
        // We continue to unsubscribe even if backend fails
      }
    }
    leaveLocalInfo();
  }

  /// Clears local room state (e.g., when kicked or room deleted)
  void leaveLocalInfo() {
    _unsubscribeFromRoom();
    _currentRoom = null;
    _participants = [];
    notifyListeners();
  }

  /// Refresh participants list
  Future<void> _refreshParticipants() async {
    if (_currentRoom == null) return;
    try {
      print("Refreshing participants for room: ${_currentRoom!.id}");
      final data = await _service.getRoomParticipants(_currentRoom!.id);
      print("Raw participants data: $data"); // DEBUG LOG
      _participants = data.map((e) => RoomParticipant.fromJson(e)).toList();
      print(
        "Participants refreshed: ${_participants.length} (Host found: ${_participants.any((p) => p.isHost)})",
      ); // DEBUG
      notifyListeners();
    } catch (e, stack) {
      print("Error refreshing participants: $e");
      print(stack);
    }
  }

  /// Subscribe to realtime changes
  void _subscribeToRoom() {
    if (_currentRoom == null) return;
    _unsubscribeFromRoom(); // Ensure no double sub

    _roomChannel = _service.subscribeToRoom(_currentRoom!.id, (payload) {
      if (payload.table == 'room_participants') {
        // Someone joined or left
        _refreshParticipants();
      } else if (payload.table == 'rooms') {
        // Room status changed or Room Deleted
        if (payload.eventType == PostgresChangeEvent.update) {
          _refreshRoom();
        } else if (payload.eventType == PostgresChangeEvent.delete) {
          // Room was deleted (Host left)
          print("Room deleted event received. Clearing local info.");
          leaveLocalInfo();
        }
      }
    });
  }

  Future<void> _refreshRoom() async {
    if (_currentRoom == null) return;
    try {
      final data = await _service.getRoomById(_currentRoom!.id);
      _currentRoom = Room.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing room: $e");
    }
  }

  void _unsubscribeFromRoom() {
    if (_roomChannel != null) {
      _service.unsubscribeRoom(_roomChannel!);
      _roomChannel = null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
