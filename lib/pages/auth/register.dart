import 'package:flutter/material.dart';
import '../../widget/atom_background_page.dart';
import '../../widget/molecules/text_field.dart';
import '../../app_colors.dart';
import '../../widget/molcule_card.dart';

class Register extends StatelessWidget {
  const Register({super.key});

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
                      label: "MOT DE PASSE",
                      hintText: "Entrez votre mot de passe",
                      icon: Icons.password,
                      fieldType: EnumFieldType.password,
                    ),
                    const SizedBox(height: 35),

                    // Bouton S'inscrire
                    SizedBox(
                      child: MoleculeCard(
                        label: 'S\'INSCRIRE',
                        onPressed: () {
                          Navigator.pushNamed(context, '/home_page');
                        },
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
