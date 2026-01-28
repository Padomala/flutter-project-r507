import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  static void show(BuildContext context, Object error) {
    final message = _getErrorMessage(error);
    _showSnackBar(context, message);
  }

  /// traduit l'erreur en un message français
  static String _getErrorMessage(Object error) {
    if (error is String) return error;

    if (error is AuthException) {
      final msg = error.message;

      /// erreurs de Connexion
      if (msg.contains('Invalid login credentials')) {
        return 'Email ou mot de passe incorrect.';
      }
      if (msg.contains('Email not confirmed')) {
        return 'Veuillez confirmer votre email avant de vous connecter.';
      }
      if (msg.contains('invalid_grant')) {
        return 'Identifiants invalides.';
      }

      /// erreurs d'Inscription
      if (msg.contains('User already registered')) {
        return 'Cette adresse email est déjà utilisée.';
      }
      if (msg.contains('Password should be at least')) {
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      }
      if (msg.contains('Unable to validate email')) {
        return 'Format d\'email invalide.';
      }

      if (msg.contains('rate limit')) {
        return 'Trop de tentatives. Veuillez patienter un moment.';
      }

      return 'Erreur d\'authentification : $msg';
    }

    return 'Une erreur inattendue est survenue. Vérifiez votre connexion.';
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
