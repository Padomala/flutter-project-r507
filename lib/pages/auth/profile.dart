import 'package:flutter/material.dart';
import '../../widget/atoms/atom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:game_v1/store/provider/user_provider.dart';
import '../../app_colors.dart';
import '../../widget/atoms/atom_button.dart';
import '../../widget/atoms/atom_background_page.dart';
import '../../core/utils/avatar_helper.dart';
import '../../core/utils/avatar_assets.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  bool _isEditing = false;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  String? _selectedAvatarUrl;

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
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (!_isEditing) {
      _usernameController.text = user.name;
      _emailController.text = user.email;
    }

    final displayAvatarUrl = (_isEditing && _selectedAvatarUrl != null)
        ? _selectedAvatarUrl
        : user.avatarUrl;

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundPage(
            pathBackground: 'assets/images/voiture_rouge.png',
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
                    const Text(
                      'MON PROFIL',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: AvatarHelper.getAvatarImageOrNull(
                        displayAvatarUrl,
                      ),
                      child: displayAvatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue,
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),

                    Text(
                      user.name.isEmpty ? 'Utilisateur' : user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_isEditing) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Choisir un avatar :",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: AvatarAssets.all.length,
                          itemBuilder: (context, index) {
                            final path = AvatarAssets.all[index];

                            final isSelected =
                                (_selectedAvatarUrl == path) ||
                                (_selectedAvatarUrl == null &&
                                    user.avatarUrl == path);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAvatarUrl = path;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(color: Colors.blue, width: 3)
                                      : null,
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AvatarHelper.getAvatarImage(
                                    path,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // champs modifiables
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
                      enabled: false,
                    ),
                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: AtomButton(
                        label: _isEditing ? 'ENREGISTRER' : 'ÉDITER',
                        onPressed: () async {
                          if (_isEditing) {
                            try {
                              await context.read<UserProvider>().updateProfile(
                                username: _usernameController.text.trim(),
                                avatarUrl: _selectedAvatarUrl,
                              );

                              if (context.mounted) {
                                setState(() {
                                  _isEditing = false;
                                  _selectedAvatarUrl = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Modifications enregistrées !',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur : $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
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

                    SizedBox(
                      width: double.infinity,
                      child: AtomButton(
                        label: 'SE DÉCONNECTER',
                        onPressed: _onLogout,
                        bgColor: Colors.redAccent,
                        width: double.infinity,
                        height: 60,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 60,
            left: 40,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              style: IconButton.styleFrom(backgroundColor: Colors.black26),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
          ),
        ],
      ),
    );
  }
}
