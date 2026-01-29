import 'package:flutter/material.dart';
import 'package:game_v1/pages/party/room_hub.dart';
import 'package:game_v1/widget/atoms/atom_title_page.dart';
import 'package:game_v1/widget/atoms/atom_background_page.dart';
import 'package:game_v1/widget/atoms/atom_button.dart';
import 'package:game_v1/widget/atoms/atom_number_picker.dart';
import 'package:provider/provider.dart';
import '../../store/provider/room_provider.dart';

class CreatePartyPage extends StatefulWidget {
  const CreatePartyPage({super.key});

  @override
  State<CreatePartyPage> createState() => _CreatePartyPageState();
}

class _CreatePartyPageState extends State<CreatePartyPage> {
  int _nbGames = 3;

  Future<void> _createParty() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text("Création de la partie avec $_nbGames mini-jeux..."),
      ),
    );

    try {
      await context.read<RoomProvider>().createRoom(
        settings: {'nb_games': _nbGames},
      );

      if (!mounted) return;

      // navigation vers la RoomHub
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoomHub()),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Erreur lors de la création de la room: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundPage(pathBackground: "assets/images/carrefour.png"),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
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
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          AtomNumberPicker(
                            min: 1,
                            max: 3,
                            initial: _nbGames,
                            width: 290,
                            onChanged: (value) {
                              setState(() {
                                _nbGames = value;
                              });
                            },
                          ),

                          const SizedBox(height: 32),

                          AtomButton(
                            label: "Créer la partie",
                            bgColor: const Color.fromARGB(255, 18, 184, 10),
                            onPressed: _createParty,
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
