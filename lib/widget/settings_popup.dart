import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widget/atom_toggle_button.dart';

class SettingsPopup extends StatefulWidget {
  const SettingsPopup({super.key});

  @override
  State<SettingsPopup> createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  bool _isVibrationOn = true;
  bool _isMusicOn = true;

  // Player pour la musique de fond
  final AudioPlayer _musicPlayer = AudioPlayer();

  @override
  void dispose() {
    _musicPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleMusic(bool value) async {
    setState(() => _isMusicOn = value);

    if (_isMusicOn) {
      // Jouer la musique en boucle
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('audio/son-game.mp3'));
    } else {
      await _musicPlayer.stop();
    }
  }

  Future<void> _playClickSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('audio/son-game.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.white, size: 32),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setStateDialog) => AlertDialog(
                backgroundColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.white, width: 8),
                ),
                title: const Text("Paramètres globaux"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ToggleButton(
                        icon: Icons.vibration,
                        labelOn: "Activer les vibrations",
                        labelOff: "Désactiver les vibrations",
                        value: _isVibrationOn,
                        onPressed: () async {
                          setStateDialog(
                            () => _isVibrationOn = !_isVibrationOn,
                          );
                          if (!kIsWeb && _isVibrationOn) {
                            Vibration.vibrate(duration: 100);
                          }
                          await _playClickSound();
                        },
                      ),
                      const SizedBox(height: 12),
                      ToggleButton(
                        icon: Icons.music_note,
                        labelOn: "Activer la musique",
                        labelOff: "Désactiver la musique",
                        value: _isMusicOn,
                        onPressed: () async {
                          setStateDialog(() => _isMusicOn = !_isMusicOn);
                          await _toggleMusic(_isMusicOn);
                          await _playClickSound();
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Fermer"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
