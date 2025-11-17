import 'package:flutter/material.dart';
import '../widget/atom_title_page.dart';
import 'package:flutter/services.dart';

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
      body: Column(
        children: [
          AtomTitle(title: "Rejoindre une Prtie", color: Color.fromARGB(255, 255, 70, 101)),
          Form(
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

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Entrez le code à 6 chiffres',
                      counterText: '',
                    ),
                    validator: _validator,
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _onValidate,
                    child: const Text('Rejoindre'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
