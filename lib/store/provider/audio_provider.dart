import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Gère la lecture de la musique de fond et des effets sonores (SFX).
class AudioProvider extends ChangeNotifier {
  bool _isMusicOn = false;

  /// Indique si la musique de fond est activée.
  bool get isMusicOn => _isMusicOn;

  // Player unique pour la musique de fond
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();

  // État actuel du player (stopped, playing, paused)
  PlayerState _musicState = PlayerState.stopped;
  bool _webMusicSourceSet = false; // Pour Web : source définie ou non

  // Effets sonores
  bool _isSfxOn = true;

  /// Indique si les effets sonores sont activés.
  bool get isSfxOn => _isSfxOn;

  /// Initialise le provider et configure le lecteur audio.
  AudioProvider() {
    _init();
  }

  /// Initialise le player de musique.
  ///
  /// Écoute les changements d'état et configure le mode de lecture en boucle.
  Future<void> _init() async {
    _backgroundMusicPlayer.onPlayerStateChanged.listen((state) {
      _musicState = state;
      notifyListeners();
    });

    await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Active ou désactive la musique de fond.
  ///
  /// [value] détermine l'état souhaité :
  /// * `true` : joue ou reprend la musique.
  /// * `false` : met la musique en pause.
  Future<void> toggleMusic(bool value) async {
    _isMusicOn = value;
    notifyListeners();

    if (_isMusicOn) {
      // Si Web, définir la source une seule fois
      if (kIsWeb && !_webMusicSourceSet) {
        await _backgroundMusicPlayer.setSource(
          AssetSource('audio/son-game.mp3'),
        );
        _webMusicSourceSet = true;
      }

      if (_musicState != PlayerState.playing) {
        if (kIsWeb) {
          await _backgroundMusicPlayer.resume();
        } else {
          await _backgroundMusicPlayer.play(AssetSource('audio/son-game.mp3'));
        }
      }
    } else {
      await _backgroundMusicPlayer.pause();
    }
  }

  /// Initialise la source audio pour le Web après une interaction utilisateur.
  ///
  /// Ceci est nécessaire car les navigateurs bloquent l'audio automatique
  /// avant la première interaction.
  Future<void> registerUserInteraction() async {
    if (kIsWeb && !_webMusicSourceSet) {
      await _backgroundMusicPlayer.setSource(AssetSource('audio/son-game.mp3'));
      _webMusicSourceSet = true;
    }
  }

  /// Joue un effet sonore spécifique.
  ///
  /// [assetPath] : le chemin du fichier audio dans les assets.
  /// Ne fait rien si les effets sonores sont désactivés.
  Future<void> playSfx(String assetPath) async {
    if (!_isSfxOn) return;

    final sfxPlayer = AudioPlayer();
    try {
      await sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Erreur SFX : $e');
    }
  }

  /// Active ou désactive les effets sonores.
  void toggleSfx(bool value) {
    _isSfxOn = value;
    notifyListeners();
  }

  /// Libère les ressources du lecteur audio lors de la destruction du provider.
  @override
  void dispose() {
    _backgroundMusicPlayer.dispose();
    super.dispose();
  }
}
