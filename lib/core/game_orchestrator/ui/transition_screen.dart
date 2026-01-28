import 'package:flutter/material.dart';
import 'dart:async';

class TransitionScreen extends StatefulWidget {
  final int gameNumber;
  final int totalGames;
  final String gameType;

  const TransitionScreen({
    required this.gameNumber,
    required this.totalGames,
    required this.gameType,
    super.key,
  });

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen>
    with SingleTickerProviderStateMixin {
  int _countdown = 3;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation pour le compte à rebours
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        timer.cancel();
        // Capture navigator before async gap
        final navigator = Navigator.of(context);

        // Attendre un peu avant de fermer l'écran
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            navigator.pop();
          }
        });
      }
    });
  }

  String _getGameName(String gameType) {
    switch (gameType) {
      case 'clues':
        return 'Devine le Mot';
      case 'caesar':
        return 'Code César';
      case 'labyrinthe':
        return 'Labyrinthe';
      default:
        return gameType.toUpperCase();
    }
  }

  IconData _getGameIcon(String gameType) {
    switch (gameType) {
      case 'clues':
        return Icons.lightbulb_outline;
      case 'caesar':
        return Icons.lock_outline;
      case 'labyrinthe':
        return Icons.grid_on;
      default:
        return Icons.videogame_asset;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A),
              Colors.purple.shade900.withOpacity(0.3),
              const Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicateur de progression
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Jeu ${widget.gameNumber} / ${widget.totalGames}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Icône du jeu
                Icon(
                  _getGameIcon(widget.gameType),
                  size: 80,
                  color: Colors.lightBlueAccent,
                ),

                const SizedBox(height: 20),

                // Nom du jeu
                Text(
                  _getGameName(widget.gameType),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 80),

                // Compte à rebours animé
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.lightBlueAccent, Colors.blue.shade700],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.lightBlueAccent.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_countdown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Message
                Text(
                  'Préparez-vous !',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
