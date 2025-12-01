import 'package:flutter/material.dart';
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
  // get auth service
  final supabaseService = SupabaseService();

  // text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();


  // login button pressed
  void register() async {
    // prepare data
    final email = _emailController.text;
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    // attempt login
    if (password == passwordConfirm) {
      try {
        await supabaseService.signIn(email, password);
      }
      catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    } else {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Les mot de passe doivent-être identique")));
    }
  }

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
                      color: Colors.black.withAlpha(2),
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
                      'Inscription',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Champ Username
                    CustomTextField(
                      label: "NOM D'UTILISATEUR",
                      hintText: "Entrez votre nom d'utilisateur",
                      icon: Icons.person,
                      fieldType: EnumFieldType.text,
                    ),

                    // Champ Email
                    CustomTextField(
                      label: "EMAIL",
                      hintText: "Entrez votre mail",
                      icon: Icons.mail,
                      fieldType: EnumFieldType.email,
                    ),

                    // Champ Mot de passe
                    CustomTextField(
                      controller: _passwordController,
                      label: "MOT DE PASSE",
                      hintText: "Entrez votre mot de passe",
                      icon: Icons.password,
                      fieldType: EnumFieldType.password,
                    ),

                    // Champ Confirmer Mot de Passe
                    CustomTextField(
                      controller: _passwordConfirmController,
                      label: "CONFIRMER MOT DE PASSE",
                      hintText: "Confirmez votre mot de passe",
                      icon: Icons.password,
                      fieldType: EnumFieldType.password,
                    ),
                    const SizedBox(height: 35),

                    // Bouton S'inscrire
                    SizedBox(
                      child: AtomButton(
                        label: 'S\'INSCRIRE',
                        onPressed: register,
                        bgColor: AppColors.blue,
                        width: 320,
                        height: 100,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Lien vers la page de connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ? ',
                          style: TextStyle(color: AppColors.textColor),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
