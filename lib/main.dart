import 'package:flutter/material.dart';
import 'pages/home_page.dart';
// import 'pages/party_page.dart';
import 'pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'provider/appProvider.dart';
import './provider/provider/userProvider.dart';
import 'pages/auth/login.dart';
import 'pages/auth/register.dart';
import 'pages/auth/profile.dart';
import 'pages/create_party.dart';
import 'pages/join_party.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, AppProvider>(
          create: (_) => AppProvider(userProvider: null),
          update: (_, userProvider, previous) =>
              AppProvider(userProvider: userProvider),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Project',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Motley_Forces',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/create_party': (context) => CreatePartyPage(),
        '/join_party': (context) => JoinPartyPage(),

        '/settings': (context) => SettingsPage(),
        '/profile': (context) => Profile(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
      },
    );
  }
}
