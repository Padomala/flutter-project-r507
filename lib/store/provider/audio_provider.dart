import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioProvider extends ChangeNotifier {
  //[info] : commentaires enrichies par une IA générative

  bool _isMusicOn = false;
  bool get isMusicOn => _isMusicOn;

  // Player unique pour la musique de fond
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();

  // État actuel du player (stopped, playing, paused)
  PlayerState _musicState = PlayerState.stopped;
  bool _webMusicSourceSet = false; // Pour Web : source définie ou non

  //effets sonores
  bool _isSfxOn = true;
  bool get isSfxOn => _isSfxOn;

  /*
  * Initialise le player et configure le mode de lecture en boucle 
  */
  AudioProvider() {
    _init();
  }

  /*
   * Initialise le player de musique
   * - Écoute les changements d'état
   * - Configure boucle
   */
  Future<void> _init() async {
    _backgroundMusicPlayer.onPlayerStateChanged.listen((state) {
      _musicState = state;
      notifyListeners();
    });

    await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /* 
  * Active ou désactive la musique de fond 
  * - Si activé, joue ou reprend la musique 
  * - Si désactivé, met la musique en pause 
  */
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

  // Appeler une seule fois après le premier clic utilisateur pour le web
  Future<void> registerUserInteraction() async {
    if (kIsWeb && !_webMusicSourceSet) {
      await _backgroundMusicPlayer.setSource(AssetSource('audio/son-game.mp3'));
      _webMusicSourceSet = true;
    }
  }

  /*
   * Gestion des effets sonores
   */
  Future<void> playSfx(String assetPath) async {
    if (!_isSfxOn) return;

    final sfxPlayer = AudioPlayer();
    try {
      await sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Erreur SFX : $e');
    }
  }

  void toggleSfx(bool value) {
    _isSfxOn = value;
    notifyListeners();
  }

  /* 
  * Nettoyage du player lorsqu'on détruit le provider 
  */
  @override
  void dispose() {
    _backgroundMusicPlayer.dispose();
    super.dispose();
  }
}
