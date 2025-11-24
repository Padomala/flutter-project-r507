import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:provider/provider.dart';
import '../store/provider/userProvider.dart';
import '../store/provider/audio_provider.dart';
import '../store/provider/vibration_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AudioProvider()),
        ChangeNotifierProvider(create: (context) => VibrationProvider()),
      ],
      child: const MyApp(),
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
        // final user = context.watch<UserProvider>().user;
        // if (user?.isConnected == true) {
        //   return Profile();
        // } else {
        //   SystemNavigator.routeInformationUpdated(uri: Uri(path: "#/login"));
        //   return Login();
        // }
        // },
        '/login': (context) => Login(),
        // final user = context.watch<UserProvider>().user;
        // if (user?.isConnected == true) {
        //   SystemNavigator.routeInformationUpdated(
        //     uri: Uri(path: "#/profile"),
        //   );
        //   return Profile();
        // } else {
        //   return Login();
        // }
        // },
        '/register': (context) => Register(),
      },
    );
  }
}
