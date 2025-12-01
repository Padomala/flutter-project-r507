import 'package:flutter/material.dart';
import '../../widget/atoms/atom_text_field.dart';
import '../../app_colors.dart';
import '../../widget/atoms/atom_button.dart';
import '../../widget/atoms/atom_background_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  bool _isEditing = false;
  final TextEditingController _usernameController = TextEditingController(
    text: "Utilisateur123",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "utilisateur@example.com",
  );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan
          const BackgroundPage(
            pathBackground: '../../assets/images/voiture_rouge.png',
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenSize.width * 0.9,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
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
                    // En-tête profil
                    const Text(
                      'MON PROFIL',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Avatar
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _usernameController.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Champs modifiables
                    CustomTextField(
                      label: "NOM D'UTILISATEUR",
                      hintText: "Entrez votre nom d'utilisateur",
                      icon: Icons.person,
                      controller: _usernameController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      label: "EMAIL",
                      hintText: "Entrez votre email",
                      icon: Icons.email,
                      fieldType: EnumFieldType.email,
                      controller: _emailController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 15),

                    // Bouton Éditer / Enregistrer
                    SizedBox(
                      width: double.infinity,
                      child: AtomButton(
                        label: _isEditing ? 'ENREGISTRER' : 'ÉDITER',
                        onPressed: () {
                          if (_isEditing) {
                            // Sauvegarder
                            setState(() {
                              _isEditing = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Modifications enregistrées !'),
                              ),
                            );
                          } else {
                            // Passer en mode édition
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        },
                        bgColor: AppColors.blue,
                        width: double.infinity,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Statistiques (optionnel, gardé pour cohérence)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Statistiques',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '12',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Parties jouées'),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '8',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Victoires'),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '4',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Défaites'),
                                ],
                              ),
                            ],
                          ),
                        ],
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
