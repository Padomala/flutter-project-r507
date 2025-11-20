import 'package:flutter/material.dart';
import 'package:game_v1/pages/shop_page.dart';
import 'pages/home_page.dart';
// import 'pages/party_page.dart';
import 'pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'store/provider/userProvider.dart';
import 'pages/auth/login.dart';
import 'pages/auth/register.dart';
import 'pages/auth/profile.dart';
import 'pages/create_party.dart';
import 'pages/join_party.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print(context.watch<UserProvider>().user?.name);
    return MaterialApp(
      title: 'SPLIT',
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
        '/shop': (context) => ShopPage(),
        '/settings': (context) => SettingsPage(),
        '/profile': (context) => Profile(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
      },
    );
  }
}
