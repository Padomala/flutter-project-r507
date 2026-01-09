import 'package:flutter/material.dart';
import 'package:game_v1/pages/game/caesar_game_page.dart';
import 'package:game_v1/pages/shop/shop_page.dart';
import 'pages/home_page.dart';

import 'core/services/supabase_service.dart';
import 'pages/auth/login.dart';
import 'pages/auth/register.dart';
import 'pages/auth/profile.dart';
import 'pages/party/create_party.dart';
import 'pages/party/join_party.dart';
import 'store/provider/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  //we just wait for initialization
  await SupabaseService.initialize();         //we wait to get the url and mdp to connect

  runApp(
    const AppProviders(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        '/game/caesar_game': (context) => CaesarGamePage(),
      },
    );
  }
}
