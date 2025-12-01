import 'package:flutter/material.dart';
import 'package:game_v1/widget/atom_button.dart';
import 'package:game_v1/widget/molcule_card.dart';
import '../widget/atom_title_page.dart';
import 'package:flutter/services.dart';
import '../widget/atom_background_page.dart';

class JoinPartyPage extends StatefulWidget {
  const JoinPartyPage({Key? key}) : super(key: key);

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

  void _onValidate() {
    if (_formKey.currentState?.validate() ?? false) {
      final code = _controller.text;
      // Ici : appelle ton backend ou fais la navigation
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Code soumis : $code')));
    }
  }

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    if (value.length != 6) return 'Le code doit comporter 6 chiffres';
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
                title: "Rejoindre une Partie",
                color: Colors.blueAccent,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 320),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      // FORMULAIARE START
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Container(
                                  padding: EdgeInsets.all(8), // padding interne
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(100, 0, 0, 0),
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // radius
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
                            // SizedBox(height: 8),

                            // Ton TextFormField
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
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 6,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 25,
                              ),
                              validator: _validator,
                            ),

                            SizedBox(height: 16),

                            AtomButton(
                              label: "Rejoindre la partie",
                              color: Color.fromARGB(255, 18, 184, 10),
                              onPressed: () => {
                                if (_formKey.currentState!.validate())
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Processing Data'),
                                      ),
                                    ),
                                  },
                              },
                            ),

                            // MoleculeCard(
                            //   label: "Rejoindre la partie",
                            //   onPressed: () {
                            //     Navigator.pushNamed(context, '');
                            //   },
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
