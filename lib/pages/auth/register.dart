import 'package:flutter/material.dart';
import 'package:game_v1/store/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../../widget/atoms/atom_background_page.dart';
import '../../widget/atoms/atom_text_field.dart';
import '../../app_colors.dart';
import '../../widget/atoms/atom_button.dart';
import 'package:game_v1/core/utils/supabase_error_helper.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {
  final _emailController = TextEditingController();
  final _pseudoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;

  // on déclare une variable pour stocker le Messenger
  late ScaffoldMessengerState _scaffoldMessenger;

  // on capture le Messenger tant que le context est valide
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // on utilise la référence stockée
    _scaffoldMessenger.clearSnackBars();

    _emailController.dispose();
    _pseudoController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void register() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;

    final email = _emailController.text.trim();
    final pseudo = _pseudoController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _passwordConfirmController.text;

    if (pseudo.isEmpty || email.isEmpty || password.isEmpty) {
      SupabaseErrorHandler.show(context, "Veuillez remplir tous les champs.");
      return;
    }

    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      SupabaseErrorHandler.show(context, "Format d'email invalide.");
      return;
    }

    if (password != confirmPassword) {
      SupabaseErrorHandler.show(
        context,
        "Les mots de passe ne correspondent pas.",
      );
      return;
    }

    if (password.length < 6) {
      SupabaseErrorHandler.show(
        context,
        "Le mot de passe doit contenir au moins 6 caractères.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<UserProvider>().register(
        email: email,
        password: password,
        username: pseudo,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Inscription réussie"),
            content: const Text(
              "Votre compte a été créé avec succès !\n\nUn email de confirmation vous a été envoyé. Veuillez cliquer sur le lien reçu pour activer votre compte.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text("J'ai compris"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) SupabaseErrorHandler.show(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          BackgroundPage(pathBackground: 'assets/images/voiture_rouge.png'),
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
                      color: Colors.black.withAlpha(50),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'INSCRIPTION',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _pseudoController,
                      label: "PSEUDO",
                      hintText: "Choisissez un pseudo",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _emailController,
                      label: "EMAIL",
                      hintText: "Entrez votre mail",
                      icon: Icons.mail,
                      fieldType: EnumFieldType.email,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _passwordController,
                      label: "MOT DE PASSE",
                      hintText: "Min. 6 caractères",
                      icon: Icons.lock,
                      fieldType: EnumFieldType.password,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _passwordConfirmController,
                      label: "CONFIRMATION",
                      hintText: "Répétez le mot de passe",
                      icon: Icons.lock_outline,
                      fieldType: EnumFieldType.password,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: AtomButton(
                        label: _isLoading
                            ? 'CREATION EN COURS...'
                            : 'S\'INSCRIRE',
                        onPressed: register,
                        bgColor: AppColors.blue,
                        width: double.infinity,
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        'Déjà un compte ? Se connecter',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
