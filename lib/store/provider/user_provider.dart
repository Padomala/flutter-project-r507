import 'package:flutter/material.dart';
import 'package:game_v1/core/services/supabase_service.dart';
import '../model/user.dart';

class UserProvider with ChangeNotifier {
  // Instance of our service to handle backend calls
  final SupabaseService _authService = SupabaseService();

  UserProvider()
    : _currentUser = const UserModel(
        id: '',
        name: '',
        email: '',
        isConnected: false,
      );

  UserModel _currentUser;
  bool _isConnecting = false;

  UserModel get user => _currentUser;
  bool get isConnected => _currentUser.isConnected;
  bool get isConnecting => _isConnecting;

  /// --- LOCAL STATE HELPERS ---

  void _setConnecting(bool value) {
    _isConnecting = value;
    notifyListeners();
  }

  /// --- AUTHENTICATION ACTIONS ---

  /// Logs in the user using Email and Password via Supabase
  Future<void> login({required String email, required String password}) async {
    _setConnecting(true);

    try {
      // 1. Call the service to sign in
      final response = await _authService.signIn(email, password);

      final session = response.session;
      final authUser = response.user;

      // 2. Check if we got a valid user back
      if (authUser != null && session != null) {
        // 3. Map Supabase User to your local UserModel
        _currentUser = UserModel(
          id: authUser.id,
          // Fallback to email if 'name' metadata is missing
          name: authUser.userMetadata?['name'] ?? authUser.email ?? 'Unknown',
          email: authUser.email ?? '',
          avatarUrl: authUser.userMetadata?['avatar_url'],
          isConnected: true,
        );
      } else {
        // Log explicitly if auth failed
        debugPrint("Auth failed: No user returned");
        _currentUser = const UserModel(
          id: '',
          name: '',
          email: '',
          isConnected: false,
        );
      }
    } catch (e) {
      // 4. On error, ensure we are reset to disconnected
      _currentUser = const UserModel(
        id: '',
        name: '',
        email: '',
        isConnected: false,
      );
      rethrow;
    } finally {
      // 5. Always stop loading and notify UI
      _setConnecting(false);
      notifyListeners();
    }
  }

  /// Registers a new user
  Future<void> register({
    required String email,
    required String password,
    String? username,
  }) async {
    _setConnecting(true);
    try {
      final response = await _authService.signUp(
        email,
        password,
        username: username,
      );

      final authUser = response.user;

      if (authUser != null) {
        // Depending on your app flow, you might want to log them in directly
        // or ask them to verify email. For now, let's log them in locally.
        _currentUser = UserModel(
          id: authUser.id,
          name: username ?? authUser.email ?? 'New User',
          email: authUser.email ?? '',
          isConnected: true,
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _setConnecting(false);
      notifyListeners();
    }
  }

  /// Updates user profile
  Future<void> updateProfile({String? username, String? avatarUrl}) async {
    final userId = _currentUser.id;
    if (userId.isEmpty || userId == 'guest') return;

    _setConnecting(true);
    try {
      await _authService.updateProfile(
        userId,
        username: username,
        avatarUrl: avatarUrl,
      );

      // Update local state
      var updatedUser = _currentUser;
      if (username != null) {
        updatedUser = updatedUser.copyWith(name: username);
      }
      if (avatarUrl != null) {
        updatedUser = updatedUser.copyWith(avatarUrl: avatarUrl);
      }
      _currentUser = updatedUser;
    } catch (e) {
      rethrow;
    } finally {
      _setConnecting(false);
      notifyListeners();
    }
  }

  /// Logs out from Supabase and resets local state
  Future<void> logout() async {
    _setConnecting(true);
    try {
      await _authService.signOut();
    } catch (e) {
      // Even if Supabase errors out, we want to clear local state
      debugPrint("Error signing out: $e");
    } finally {
      _currentUser = const UserModel(
        id: '',
        name: '',
        email: '',
        isConnected: false,
      );
      _setConnecting(false);
      notifyListeners();
    }
  }
}
