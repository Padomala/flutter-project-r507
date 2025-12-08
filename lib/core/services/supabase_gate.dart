import 'package:flutter/material.dart';
import 'package:game_v1/pages/auth/login.dart';
import 'package:game_v1/pages/auth/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseGate extends StatelessWidget {
  const SupabaseGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Le stream de Supabase émet un objet AuthState à chaque changement.
      stream: Supabase.instance.client.auth.onAuthStateChange,

      builder: (context, snapshot) {
        // 1. État de chargement initial (le SDK vérifie l'existence d'une session)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Récupère l'événement d'état d'authentification
        final AuthState? authState = snapshot.data;
        
        // 2. Vérifie la présence d'une session valide
        // Si authState est non nul ET la session à l'intérieur est non nulle
        if (authState != null && authState.session != null) {
          return const Profile(); // Utilisateur connecté
        } else {
          return const Login(); // Utilisateur déconnecté ou session expirée
        }
      },
    );
  }
}