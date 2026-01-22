import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants.dart';

class MicrophoneGamePageMicroter extends StatefulWidget {
  const MicrophoneGamePageMicroter({super.key});

  @override
  State<MicrophoneGamePageMicroter> createState() => _MicrophoneGamePageMicroterState();
}

class _MicrophoneGamePageMicroterState extends State<MicrophoneGamePageMicroter> {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  double _currentDecibel = 0;
  String? _micError;
  final int _currentDecibelList = 0;
  final List<double> _decibelList = [];

  @override
  void initState() {
    super.initState();
    
    // Generate random decibel targets for each round.
    final Random random = Random();
    for (int i = 0; i < numberRound; i++) {
      _decibelList.add(
        kMinDecibel +
            (kMaxDecibel - kMinDecibel) * random.nextDouble(),
      );
    }

    // Start microphone listening as soon as the screen opens.
    _startListening();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
    super.dispose();
  }

  Future<void> _startListening() async {
    // Demande de permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() => _micError = 'Autorisez le micro pour lire les décibels.');
      return;
    }

    _micError = null;
    // Annuler l'ancienne souscription si elle existe
    await _noiseSubscription?.cancel();
    
    try {
      _noiseMeter = NoiseMeter();
      // On écoute le flux de données
      _noiseSubscription = _noiseMeter!.noise.listen(
        (reading) {
          if (mounted) {
            setState(() {
              // Utilisation de maxDecibel pour une détection plus réactive que meanDecibel
              _currentDecibel = reading.maxDecibel;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() => _micError = 'Erreur micro : $e');
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _micError = 'Erreur lors du démarrage : $e');
      }
    }
  }

  void showNotification(String message, {Color? color}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: color ?? Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_decibelList);

    final decibelText = '${_currentDecibel.toStringAsFixed(1)} dB';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 245, 245),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                        spreadRadius: 3,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Text(
                      'Trouvez la réponse à la question !',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Question Card Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 19,
                        spreadRadius: 5,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Question :', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mic, color: Colors.redAccent, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              decibelText,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (_micError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _micError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _startListening,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Relancer le micro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            minimumSize: const Size(0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}