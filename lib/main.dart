import 'package:flutter/material.dart';
import 'pages/home_page.dart';
// import 'pages/party_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Project',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        // '/create_party': (context) => CreatePartyPage(),
        // '/join_party': (context) => JoinPartyPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
