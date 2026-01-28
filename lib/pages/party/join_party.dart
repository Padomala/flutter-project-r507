import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:game_v1/pages/party/room_hub.dart';
import 'package:game_v1/widget/atoms/atom_button.dart';
import '../../widget/atoms/atom_title_page.dart';
import '../../widget/atoms/atom_background_page.dart';
import '../../store/provider/room_provider.dart';

class JoinPartyPage extends StatefulWidget {
  const JoinPartyPage({super.key});

  @override
  State<JoinPartyPage> createState() => _JoinGameBodyMinimalState();
}

class _JoinGameBodyMinimalState extends State<JoinPartyPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _joinParty() async {
    if (_formKey.currentState?.validate() ?? false) {
      final code = _controller.text;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tentative de connexion à la room $code...')),
      );

      try {
        await context.read<RoomProvider>().joinRoom(code);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RoomHub()),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Impossible de rejoindre la room. $e'),
          ),
        );
      }
    }
  }

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundPage(pathBackground: "assets/images/carrefour.png"),
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
                title: "Rejoindre une Partie",
                color: Colors.blueAccent,
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(100, 0, 0, 0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Code de la partie',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                            ),

                            TextFormField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: InputDecoration(
                                hintText: '______',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 6,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 25,
                              ),
                              validator: _validator,
                            ),

                            const SizedBox(height: 16),

                            AtomButton(
                              label: "Rejoindre la partie",
                              onPressed: _joinParty,
                              bgColor: const Color.fromARGB(255, 18, 184, 10),
                            ),
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
