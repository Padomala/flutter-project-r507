import 'package:flutter/material.dart';
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
      // appBar: AppBar(title: Text("Rejoindre une partie")), // optionnel
      body: Stack(
        children: [
          BackgroundPage(pathBackground: "../../assets/images/quai_gare.png"),

          Column(
            children: [
              AtomTitle(
                title: "Rejoindre une Partie",
                color: Color.fromARGB(255, 255, 70, 101),
              ),

              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400, minHeight: 200),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Code de la partie',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Entrez le code à 6 chiffres',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),

                              counterText: '',
                            ),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: _validator,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _onValidate,
                            child: Text(
                              'Rejoindre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
