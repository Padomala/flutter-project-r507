import 'package:flutter/material.dart';
import 'package:game_v1/pages/party/room_hub.dart';
import 'package:game_v1/widget/atoms/atom_title_page.dart';
import 'package:game_v1/widget/atoms/atom_background_page.dart';
import 'package:game_v1/widget/atoms/atom_button.dart';
import 'package:game_v1/widget/atoms/atom_number_picker.dart';

class CreatePartyPage extends StatefulWidget {
  const CreatePartyPage({super.key});

  @override
  State<CreatePartyPage> createState() => _CreatePartyPageState();
}

class _CreatePartyPageState extends State<CreatePartyPage> {
  int _nbGames = 5;

  // Préparation pour ta logique future (API / SQL)
  Future<void> _createParty() async {
    // 1. Feedback visuel immédiat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Création de la partie avec $_nbGames mini-jeux...")),
    );

    // TODO: Ici, insère ton appel à la base de données
    // String roomCode = await api.generateRoomCode();
    // await api.insertRoom(roomCode, _nbGames);

    // Simulation d'un délai réseau (à retirer plus tard)
    await Future.delayed(const Duration(milliseconds: 500)); 

    if (!mounted) return; // Sécurité : on vérifie si la page est toujours là

    // 2. Navigation vers la RoomHub
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomHub(
          nb: _nbGames,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Assure-toi que le chemin est correct et accessible
          const BackgroundPage(pathBackground: "assets/images/carrefour.png"),
          Column(
            children: [
              const AtomTitle(
                title: "Créer une Partie",
                color: Color.fromARGB(255, 255, 70, 101),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ---- LABEL ----
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(100, 0, 0, 0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Nombre de mini-jeux",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // ---- ATOM NUMBER PICKER ----
                          AtomNumberPicker(
                            min: 1,
                            max: 20,
                            initial: _nbGames,
                            width: 290,
                            onChanged: (value) {
                              setState(() {
                                _nbGames = value;
                              });
                            },
                          ),

                          const SizedBox(height: 32),

                          // ---- BUTTON ----
                          AtomButton(
                            label: "Créer la partie",
                            bgColor: const Color.fromARGB(255, 18, 184, 10),
                            onPressed: _createParty, // Appel direct de la fonction
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}