import 'package:flutter/material.dart';
import 'package:game_v1/game/caesar/game/state/caesar_game_notifier.dart';
import 'package:game_v1/game/caesar/game/ui/caesar_game_main_screen.dart';
import 'package:game_v1/pages/shop/shop_page.dart';
import 'pages/home_page.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/services/supabase_gate.dart';
import 'pages/auth/login.dart';
import 'pages/auth/register.dart';
import 'pages/auth/profile.dart';
import 'pages/party/create_party.dart';
import 'pages/party/join_party.dart';
import 'store/provider/app_providers.dart';
import 'game/clues/game/ui/guessing_game_screen.dart';
import 'game/clues/game/ui/hot_cold_game_screen.dart';
import 'game/clues/game/state/guessing_game_notifier.dart';
import 'game/clues/game/state/hot_cold_game_notifier.dart';
import 'widget/organisms/settings_popup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await SupabaseService.initialize();

  runApp(const AppProviders(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPLIT',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Motley_Forces',
      ),
      initialRoute: null,
      home: const SupabaseGate(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) Positioned.fill(child: child),
            const SettingsPopup(),
          ],
        );
      },
      routes: {
        '/home': (context) => HomePage(),
        '/create_party': (context) => CreatePartyPage(),
        '/join_party': (context) => JoinPartyPage(),
        '/shop': (context) => ShopPage(),
        '/profile': (context) => Profile(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/game/caesar_game': (context) => ChangeNotifierProvider(
          create: (_) => CaesarGameNotifier(
            gameId: "a1b2c3d4-0000-0000-0000-000000000001",
          ),
          child: const CaesarGamePage(),
        ),
        '/guessing_game': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final gameId =
              args?['gameId'] ?? 'a1b2c3d4-0000-0000-0000-000000000000';
          return ChangeNotifierProvider(
            create: (context) => GuessingGameNotifier(gameId: gameId),
            child: GuessingGameScreen(gameId: gameId),
          );
        },
        '/hot_cold_game': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final gameId =
              args?['gameId'] ?? 'a1b2c3d5-0000-0000-0000-000000000000';
          return ChangeNotifierProvider(
            create: (context) => HotColdGameNotifier(gameId: gameId),
            child: HotColdGameScreen(gameId: gameId),
          );
        },
      },
    );
  }
}
