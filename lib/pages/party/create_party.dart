import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_v1/widget/atoms/atom_button.dart';
import '../../widget/atoms/atom_title_page.dart';
import '../../widget/atoms/atom_background_page.dart';
import '../../widget/atoms/atom_button.dart';
import '../../widget/atoms/atom_number_picker.dart';

class CreatePartyPage extends StatefulWidget {
  const CreatePartyPage({super.key});

  @override
  State<CreatePartyPage> createState() => _CreatePartyPageState();
}

class _CreatePartyPageState extends State<CreatePartyPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  int _nbGames = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onValidate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nombre de mini-jeux choisi : $_nbGames")),
    );
  }

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) return "Champ requis";
    final nb = int.tryParse(value);
    if (nb == null) return "Doit être un nombre";
    if (nb <= 0) return "Minimum : 1 mini-jeu";
    if (nb > 20) return "Maximum : 20 mini-jeux";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundPage(pathBackground: "../../assets/images/carrefour.png"),
          Column(
            children: [
              AtomTitle(
                title: "Créer une Partie",
                color: Color.fromARGB(255, 255, 70, 101),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
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
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ),

                            // const SizedBox(height: 8),

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

                            const SizedBox(height: 16),

                            AtomButton(
                              label: "Créer la partie",
                              color: Color.fromARGB(255, 18, 184, 10),
                              onPressed: () => {
                                if (_formKey.currentState!.validate())
                                  {
                                    // Générer un code de room soit en flutter soit en SLQ puis le récupérer et rédiriger ensuite vers la page suivante.
                                    // Je génère le code
                                    // Je l'insert en base
                                    // J'effectue la navigation vers la page roomHub
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Processing Data'),
                                      ),
                                    ),
                                  },
                              },
                              bgColor: Color.fromARGB(255, 18, 184, 10),
                            ),

                            // ---- VALIDATION BUTTON ----
                            // MoleculeCard(
                            //   label: "Créer la partie",
                            //   onPressed: _onValidate,
                            //   bgColor: Color.fromARGB(255, 18, 184, 10),
                            //   width: 320,
                            //   height: 120,
                            // ),
                          ],
                        ),
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
