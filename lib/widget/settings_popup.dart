import 'package:flutter/material.dart';
import 'package:game_v1/app_colors.dart';
import 'package:provider/provider.dart';
import '../widget/atom_toggle_button.dart';
import '../store/provider/audio_provider.dart';
import '../store/provider/vibration_provider.dart';

class SettingsPopup extends StatelessWidget {
  const SettingsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                builder: (context, setStateDialog) => AlertDialog(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.white, width: 8),
                  ),
                  title: const Text(
                    "PARAMÈTRES GLOBAUX",
                    style: TextStyle(fontSize: 35),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle vibration
                        Consumer<VibrationProvider>(
                          builder: (context, vibration, child) {
                            return ToggleButton(
                              icon: Icons.vibration,
                              labelOn: "Désactiver les vibrations",
                              labelOff: "Activer les vibrations",
                              value: vibration.isVibrationOn,
                              onPressed: () async {
                                vibration.toggleVibration(
                                  !vibration.isVibrationOn,
                                );
                                await vibration.vibrate();
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Toggle music
                        Consumer<AudioProvider>(
                          builder: (context, audio, child) {
                            return ToggleButton(
                              icon: Icons.music_note,
                              labelOn: "Désactiver la musique",
                              labelOff: "Activer la musique",
                              value: audio.isMusicOn,
                              onPressed: () async {
                                await audio.registerUserInteraction();
                                await audio.toggleMusic(!audio.isMusicOn);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Fermer les paramètres",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.settings, color: Colors.black, size: 28),
          ),
        ),
      ),
    );
  }
}
