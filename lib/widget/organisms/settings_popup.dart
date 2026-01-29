import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../atoms/atom_toggle_button.dart';
import '../../store/provider/audio_provider.dart';
import '../../store/provider/vibration_provider.dart';
import '../../main.dart';

class SettingsPopup extends StatefulWidget {
  const SettingsPopup({super.key});

  @override
  State<SettingsPopup> createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  // verrouille le bouton si la popup est déjà ouverte
  bool _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            // si la dialog est déjà ouverte, on ne fait rien
            if (_isDialogOpen) return;

            final navContext = navigatorKey.currentContext;
            if (navContext == null) return;

            // on verrouille : la dialog va s'ouvrir
            setState(() {
              _isDialogOpen = true;
            });

            // on attend que la dialog se ferme
            await showDialog(
              context: navContext,
              barrierDismissible: true,
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
                        // Vibration
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
                        // Musique
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

            //si dialog fermée on déverrouille le bouton
            if (mounted) {
              setState(() {
                _isDialogOpen = false;
              });
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isDialogOpen ? Colors.grey : Colors.yellow,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.settings, color: Colors.black, size: 28),
          ),
        ),
      ),
    );
  }
}
