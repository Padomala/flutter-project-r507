import 'package:flutter/material.dart';
import '../../widget/molecules/text_field.dart';

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
  final TextEditingController _bioController = TextEditingController(
    text: "Passionné de jeux et de défis !",
  );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec le nom d'utilisateur
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blue[800],
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _usernameController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Bloc de statistiques
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Statistiques',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            // Champs modifiables avec CustomTextField
            Container(
              width: screenSize.width * 0.9,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Champ Username
                  CustomTextField(
                    label: "Nom d'utilisateur",
                    hintText: "Entrez votre nom d'utilisateur",
                    icon: Icons.person,
                    controller: _usernameController,
                    enabled: _isEditing,
                    onEditPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  // Champ Email
                  CustomTextField(
                    label: "Email",
                    hintText: "Entrez votre email",
                    icon: Icons.email,
                    fieldType: EnumFieldType.email,
                    controller: _emailController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  // Champ Bio
                  CustomTextField(
                    label: "Bio",
                    hintText: "Entrez votre bio",
                    icon: Icons.info,
                    controller: _bioController,
                    enabled: _isEditing,
                  ),
                ],
              ),
            ),

            // Bouton Enregistrer
            if (_isEditing)
              Container(
                margin: const EdgeInsets.all(20),
                width: screenSize.width * 0.7,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modifications enregistrées !'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
