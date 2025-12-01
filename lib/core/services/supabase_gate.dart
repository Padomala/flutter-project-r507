import 'package:flutter/material.dart';
import 'package:game_v1/pages/auth/login.dart';
import 'package:game_v1/pages/auth/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseGate extends StatelessWidget {
  const SupabaseGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // listen to the auth states changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      // build the appropriate
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator())
          );
        }
        
        // check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return Profile();
        } else {
          return Login();
        }
      },
    );
  }
}
