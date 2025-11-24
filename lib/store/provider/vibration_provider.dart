import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class VibrationProvider extends ChangeNotifier {
  // Indique si les vibrations sont activées
  bool _isVibrationOn = true;
  bool get isVibrationOn => _isVibrationOn;

  // Active ou désactive les vibrations
  void toggleVibration(bool value) {
    _isVibrationOn = value;
    notifyListeners();
  }

  /*
   * Fait vibrer le device si vibration activé
   * [duration] : durée de la vibration en millisecondes
   */
  Future<void> vibrate({int duration = 100}) async {
    // Ne rien faire si les vibrations sont désactivées
    if (!_isVibrationOn || kIsWeb) return;

    // Vérifie si le device supporte la vibration
    final canVibrate = await Vibration.hasVibrator();
    if (!canVibrate) return;

    // Lance la vibration
    try {
      await Vibration.vibrate(duration: duration);
    } catch (e) {
      debugPrint('Erreur lors de la vibration : $e');
    }
  }
}


