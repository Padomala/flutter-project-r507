import 'package:flutter/material.dart';
import 'package:game_v1/game/microphone/game/ui/audio_game_main_screen.dart';
import 'package:game_v1/pages/shop/shop_page.dart';
import 'package:permission_handler/permission_handler.dart';
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
// import 'game/caesar/game/ui/caesar_game_main_screen.dart';
import 'widget/organisms/settings_popup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //we just wait for initialization
  await SupabaseService.initialize(); //we wait to get the url and mdp to connect
  await _ensureMicrophonePermission();

  runApp(const AppProviders(child: MyApp()));
}

/// Ask for microphone permission up front so the microphone games can work.
Future<void> _ensureMicrophonePermission() async {
  // If already granted, nothing to do.
  final status = await Permission.microphone.status;
  if (status.isGranted) return;

  final result = await Permission.microphone.request();
  if (result.isPermanentlyDenied) {
    // Best-effort: prompt user to open app settings to enable microphone.
    await openAppSettings();
  }
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
        // '/game/caesar_game': (context) => CaesarGamePage(),
        '/game/microphone_game': (context) => MicrophoneGamePage(),
        // '/guessing_game': (context) => ChangeNotifierProvider(
        //   create: (context) => GuessingGameNotifier(
        //     gameId: 'a1b2c3d4-0000-0000-0000-000000000000',
        //   ),
        //   child: const GuessingGameScreen(
        //     gameId: 'a1b2c3d4-0000-0000-0000-000000000000',
        //   ),
        // ),
        // '/game/caesar_game': (context) => CaesarGamePage(),
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
