import 'package:flutter/material.dart';

class JoinPartyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rejoindre une Partie')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Retour'),
        ),
      ),
    );
  }
}
