import 'package:flutter/material.dart';
import '../../widget/molecules/text_field.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    // Taille de l'écran pour le responsive design
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(''), // Remplacez par votre image
                fit: BoxFit.cover,
              ),
            ),
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
                  color: Colors.yellow[200],
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
                    // Logo ou titre
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 20),
                    // // Champ email
                    // TextFormField(
                    //   decoration: InputDecoration(
                    //     labelText: 'Email',
                    //     prefixIcon: const Icon(Icons.email),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //   ),
                    //   keyboardType: TextInputType.emailAddress,
                    // ),

                    // Champ Email
                    CustomTextField(
                      label: "Email",
                      hintText: "Entrez votre email",
                      icon: Icons.email,
                      fieldType: EnumFieldType.email,
                    ),
                    const SizedBox(height: 15),
                    // Champ mot de passe
                    CustomTextField(
                      label: "Password",
                      hintText: "Entrez votre mot de passe",
                      icon: Icons.password,
                      fieldType: EnumFieldType.password,
                    ),
                    const SizedBox(height: 20),
                    // Bouton de connexion
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logique de connexion ici
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Lien "Mot de passe oublié"
                    TextButton(
                      onPressed: () {
                        // Logique pour mot de passe oublié
                      },
                      child: const Text('Mot de passe oublié ?'),
                    ),
                    // Bouton Retour
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Retour'),
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
