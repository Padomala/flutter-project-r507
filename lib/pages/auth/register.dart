import 'package:flutter/material.dart';
import 'package:game_v1/store/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../../widget/atoms/atom_background_page.dart';
import '../../widget/atoms/atom_text_field.dart';
import 'package:game_v1/core/services/supabase_service.dart';
import '../../app_colors.dart';
import '../../widget/atoms/atom_button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<Register> {
  // text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  
  // Pour gérer l'état de chargement
  bool _isLoading = false;
  
  // Supprimer la variable inutilisée : final supabaseService = SupabaseService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }


  // Fonction d'inscription
  void register() async {
    if (_isLoading) return;
    
    // 1. Validation du mot de passe
    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe doivent être identiques")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    try {
      // 2. Appel de la logique d'inscription dans le Provider
      await context.read<UserProvider>().register(
        email: _emailController.text, 
        password: _passwordController.text
      );
      
      // *** POINT CLÉ CORRIGÉ : AUCUNE NAVIGATION MANUELLE ICI ***
      // L'inscription réussit, la SupabaseGate navigue vers Profile.
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'inscription : ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // La fonction onPressedLogin dans le composant Register n'a pas de sens
  // si elle est vide. J'ai gardé la fonction register comme l'action principale.

  @override
  Widget build(BuildContext context) {
    //responsive
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          BackgroundPage(
            pathBackground: '../../assets/images/voiture_rouge.png',
          ),
          
          // Bouton de retour (si vous voulez permettre le retour à Login sans inscription)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Contenu principal
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenSize.width * 0.9,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre
                    const Text(
                      'INSCRIPTION',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Champ Email (J'ai conservé l'ordre de votre composant original,
                    // mais l'email et le mot de passe sont les champs obligatoires pour Supabase)
                    CustomTextField(
                      controller: _emailController, // Utilisation du controller
                      label: "EMAIL",
                      hintText: "Entrez votre mail",
                      icon: Icons.mail,
                      // fieldType: EnumFieldType.email,
                    ),

                    // Champ Mot de passe
                    CustomTextField(
                      controller: _passwordController,
                      label: "MOT DE PASSE",
                      hintText: "Entrez votre mot de passe",
                      icon: Icons.lock,
                      // fieldType: EnumFieldType.password,
                      // isObscure: true,
                    ),

                    // Champ Confirmer Mot de Passe
                    CustomTextField(
                      controller: _passwordConfirmController,
                      label: "CONFIRMER MOT DE PASSE",
                      hintText: "Confirmez votre mot de passe",
                      icon: Icons.lock,
                      // fieldType: EnumFieldType.password,
                      // isObscure: true,
                    ),
                    
                    // Remarque : Le champ "NOM D'UTILISATEUR" doit être géré dans la base de données après l'inscription
                    // (souvent avec une insertion dans une table 'profiles' ou 'users' distincte).
                    // Je l'ai retiré pour simplifier le flux d'authentification de base.
                    
                    const SizedBox(height: 35),

                    // Bouton S'inscrire
                    SizedBox(
                      child: AtomButton(
                        label: _isLoading ? 'INSCRIPTION EN COURS...' : 'S\'INSCRIRE',
                        onPressed: register,
                        bgColor: AppColors.blue,
                        width: double.infinity,
                        height: 60,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Lien vers la page de connexion
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Retourne à Login
                      child: const Text(
                        'Déjà un compte ? Se connecter',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}