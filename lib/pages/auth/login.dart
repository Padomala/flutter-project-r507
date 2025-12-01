import 'package:flutter/material.dart';
import 'package:game_v1/core/services/supabase_service.dart';
import 'package:game_v1/pages/auth/register.dart';
import 'package:game_v1/store/provider/userProvider.dart';
import 'package:provider/provider.dart';
import '../../widget/molecules/text_field.dart';
import '../../app_colors.dart';
import '../../widget/molcule_card.dart';
import '../../widget/atom_background_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPageState();
}


class _LoginPageState extends State<Login> {
  // get auth service
  final supabaseService = SupabaseService();

  // text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // login button pressed
  void onPressedLogin() async {
    try {
      await context.read<UserProvider>().login(
        email: _emailController.text, 
        password: _passwordController.text
      );
      Navigator.pop(context, "/profile");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Taille de l'écran pour le responsive design
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          BackgroundPage(
            pathBackground: '../../assets/images/voiture_rouge.png',
          ),

          // Filtre semi-transparent pour améliorer la lisibilité
          Container(color: Colors.black.withAlpha(3)),
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
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo ou titre
                    const Text(
                      'CONNEXION',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Champ Email
                    CustomTextField(
                      controller: _emailController,
                      label: "EMAIL",
                      hintText: "Entrez votre email",
                      icon: Icons.email,
                      fieldType: EnumFieldType.email,
                    ),
                    const SizedBox(height: 15),
                    // Champ mot de passe
                    CustomTextField(
                      controller: _passwordController,
                      label: "PASSWORD",
                      hintText: "Entrez votre mot de passe",
                      icon: Icons.password,
                      fieldType: EnumFieldType.password,
                    ),
                    const SizedBox(height: 20),
                    // Bouton de connexion
                    SizedBox(
                      child: MoleculeCard(
                        label: 'SE CONNECTER',
                        onPressed: onPressedLogin,
                        bgColor: AppColors.blue,
                        width: 320,
                        height: 100,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, "/register"),
                      child: const Center(child: Text("Vous n'avez pas de compte ? Inscrivez-vous"),),
                    )

                    // // Séparateur "Ou se connecter avec"
                    // const Row(
                    //   children: [
                    //     Expanded(child: Divider()),
                    //     Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 10),
                    //       child: Text(
                    //         'Ou se connecter avec',
                    //         style: TextStyle(
                    //           color: Colors.black54,
                    //           fontSize: 14,
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(child: Divider()),
                    //   ],
                    // ),

                    // // Bouton Google
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: OutlinedButton.icon(
                    //     onPressed: () {
                    //       // Logique de connexion avec Google
                    //     },
                    //     icon: const Icon(
                    //       Icons.g_mobiledata,
                    //       color: AppColors.red,
                    //     ),
                    //     label: const Text(
                    //       'Google',
                    //       style: TextStyle(fontSize: 16, color: AppColors.red),
                    //     ),
                    //     style: OutlinedButton.styleFrom(
                    //       padding: const EdgeInsets.symmetric(vertical: 12),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 15),
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
