import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Fournit la gestion de l'état et de l'exécution des vibrations.
class VibrationProvider extends ChangeNotifier {
  bool _isVibrationOn = true;

  /// Indique si les vibrations sont activées.
  bool get isVibrationOn => _isVibrationOn;

  /// Active ou désactive les vibrations.
  ///
  /// Met à jour l'état avec [value] et notifie les écouteurs.
  void toggleVibration(bool value) {
    _isVibrationOn = value;
    notifyListeners();
  }

  /// Fait vibrer l'appareil si la vibration est activée.
  ///
  /// [duration] : durée de la vibration en millisecondes (par défaut 100).
  Future<void> vibrate({int duration = 100}) async {
    // Ne rien faire si les vibrations sont désactivées
    if (!_isVibrationOn || kIsWeb) return;

    // Vérifie si le device supporte la vibration
    final canVibrate = await Vibration.hasVibrator();
    if (canVibrate != true) return;

    // Lance la vibration
    try {
      await Vibration.vibrate(duration: duration);
    } catch (e) {
      debugPrint('Erreur lors de la vibration : $e');
    }
  }
}
