import 'package:flutter/material.dart';
import '../../widget/atoms/atom_text_field.dart';
import 'package:game_v1/core/services/supabase_service.dart';
import 'package:game_v1/store/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../widget/atoms/atom_button.dart';
import '../../widget/atoms/atom_background_page.dart';
import 'package:game_v1/core/utils/supabase_error_helper.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  // get auth service
  final supabaseService = SupabaseService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 1. Déclarer une variable pour stocker la référence au Messenger
  late ScaffoldMessengerState _scaffoldMessenger;

  // 2. Capturer la référence quand le contexte est prêt et encore lié à l'arbre
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // 3. Utiliser la référence capturée plutôt que ScaffoldMessenger.of(context)
    _scaffoldMessenger.clearSnackBars();

    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void onPressedLogin() async {
    FocusScope.of(context).unfocus();

    try {
      await context.read<UserProvider>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } catch (e) {
      if (mounted) SupabaseErrorHandler.show(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          BackgroundPage(pathBackground: 'assets/images/voiture_rouge.png'),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
          ),

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
                    const Text(
                      'CONNEXION',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),

                    const SizedBox(height: 20),
                    //email
                    CustomTextField(
                      controller: _emailController,
                      label: "EMAIL",
                      hintText: "Entrez votre email",
                      icon: Icons.email,
                      fieldType: EnumFieldType.email,
                    ),
                    const SizedBox(height: 15),
                    //mot de passe
                    CustomTextField(
                      controller: _passwordController,
                      label: "PASSWORD",
                      hintText: "Entrez votre mot de passe",
                      icon: Icons.password,
                      fieldType: EnumFieldType.password,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      child: AtomButton(
                        label: 'SE CONNECTER',
                        onPressed: onPressedLogin,
                        bgColor: AppColors.blue,
                        width: 320,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Vous n\'avez pas de compte ? Inscrivez-vous',
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
