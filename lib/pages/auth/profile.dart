import 'package:flutter/material.dart';
import '../../widget/atoms/atom_text_field.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:game_v1/store/provider/user_provider.dart'; // Import your UserProvider
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
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Helper to handle Logout
  void _onLogout() async {
    try {
      await context.read<UserProvider>().logout();
      // No need to navigate manually; SupabaseGate will see the 
      // session change and redirect to Login automatically.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // 1. Listen to the UserProvider
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    // 2. Sync controllers with User Data (only if not currently editing)
    // This ensures that when the page loads, the fields are filled.
    if (!_isEditing) {
      _usernameController.text = user.name;
      _emailController.text = user.email;
    }

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
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      // Display user avatar if available, else Icon
                      backgroundImage: user.avatarUrl != null 
                          ? NetworkImage(user.avatarUrl!) 
                          : null,
                      child: user.avatarUrl == null 
                          ? const Icon(Icons.person, size: 50, color: Colors.blue) 
                          : null,
                    ),
                    const SizedBox(height: 10),
                    
                    // Display Name (Read-only view at top)
                    Text(
                      user.name.isEmpty ? 'Utilisateur' : user.name,
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
                    
                    // Email is usually read-only in Supabase unless you have a specific flow
                    // So we might want to keep enabled: false even in edit mode, 
                    // or handle email change separately. For now, I'll follow your edit logic.
                    CustomTextField(
                      label: "EMAIL",
                      hintText: "Entrez votre email",
                      icon: Icons.email,
                      fieldType: EnumFieldType.email,
                      controller: _emailController,
                      enabled: false, // Usually better to not allow email edit here directly
                    ),
                    const SizedBox(height: 15),

                    // Bouton Éditer / Enregistrer
                    SizedBox(
                      width: double.infinity,
                      child: AtomButton(
                        label: _isEditing ? 'ENREGISTRER' : 'ÉDITER',
                        onPressed: () {
                          if (_isEditing) {
                            // TODO: Add logic to save changes to Supabase here
                            setState(() {
                              _isEditing = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Modifications locales enregistrées !'),
                              ),
                            );
                          } else {
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
                    
                    const SizedBox(height: 15),

                    // --- NEW: LOGOUT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      child: AtomButton(
                        label: 'SE DÉCONNECTER',
                        onPressed: _onLogout,
                        // Assuming you have a red color, otherwise use Colors.red
                        bgColor: Colors.redAccent, 
                        width: double.infinity,
                        height: 60, // Slightly smaller than primary action
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Statistiques
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