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
      password: password
      );
  }


  // SIGN UP
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password
      );
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
}

