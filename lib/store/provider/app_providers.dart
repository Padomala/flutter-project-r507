import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './audio_provider.dart';
import './vibration_provider.dart';
import 'user_provider.dart';
import 'room_provider.dart';
import '../../core/game_orchestrator/providers/game_session_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => VibrationProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => GameSessionProvider()),
      ],
      child: child,
    );
  }
}
