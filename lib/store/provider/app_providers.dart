import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './audio_provider.dart';
import './vibration_provider.dart';
import 'user_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => VibrationProvider()),
      ],
      child: child,
    );
  }
}
