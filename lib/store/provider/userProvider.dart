import 'package:flutter/material.dart';
import 'package:game_v1/core/services/supabase_service.dart';

import '../model/user.dart';

class UserProvider with ChangeNotifier {
  UserProvider() : _currentUser = const UserModel.guest();  //we create a user 'guest'

  UserModel _currentUser;   //we set the current user at the previously made guest
  bool _isConnecting = false; //we set isConnecting at false

  UserModel get user => _currentUser; //if we ask user, we get the current user
  bool get isConnected => _currentUser.isConnected; //we set quick way to get info like isConnected or isConnecting
  bool get isConnecting => _isConnecting;

  /// Allows updating local profile fields while keeping the connection flag.
  void updateUser(UserModel user) {
    _currentUser = user.copyWith(isConnected: true);
    notifyListeners();
  }

  /// Marks the single user as disconnected but keeps the last known profile so
  /// widgets can continue to display information offline.
  void disconnect() {
    _currentUser = _currentUser.copyWith(isConnected: false);
    notifyListeners();
  }

  void _setConnecting(bool value) {
    _isConnecting = value;
    notifyListeners();
  }

  /// Immediately marks the in-memory user as connected so the UI always has a
  /// single source of truth without waiting for any backend.
  // Future<void> connect({
  //   required String email,
  //   required String mdp,
  // }) async {
  //   _setConnecting(true);
  //   try {
  //     // Attempt to log in with Supabase email & password
  //     final response = await SupabaseService.signIn(email,mdp);
  //     final session = response.session;
  //     final user = response.user;

  //     if (user != null && session != null) {
  //       _currentUser = UserModel(
  //         id: user.id,
  //         name: user.userMetadata?['name'] ?? user.email ?? '',
  //         email: user.email ?? '',
  //         avatarUrl: user.userMetadata?['avatar_url'],
  //         isConnected: true,
  //       );
  //     } else {
  //       // Reset to guest if login failed
  //       _currentUser = const UserModel.guest();
  //     }
  //   } catch (e) {
  //     // In case of error, rollback to guest and rethrow/error-handle as needed
  //     _currentUser = const UserModel.guest();
  //     // Optionally, you could log the error or show a message
  //     // print('Login failed: $e');
  //   }
  //   notifyListeners();
  //   _setConnecting(false);
  // }

  
}