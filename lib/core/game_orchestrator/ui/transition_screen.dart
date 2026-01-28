import 'package:flutter/material.dart';
import 'dart:async';
import '../../../app_colors.dart';
import '../../../widget/atoms/atom_background_page.dart';

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
    // Utilisation de la même structure visuelle que FinalResultsScreen
    return Scaffold(
      body: Stack(
        children: [
          // 1. Image de fond (Style Atom)
          const BackgroundPage(pathBackground: "assets/images/carrefour.png"),
          Container(
            color: Colors.black.withOpacity(0.3), // Overlay sombre
          ),

          // 2. Contenu principal (Carte Blanche Centrée)
          SafeArea(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicateur de progression (Style Pill)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Jeu ${widget.gameNumber} / ${widget.totalGames}',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Icône du jeu
                    Icon(
                      _getGameIcon(widget.gameType),
                      size: 80,
                      color: AppColors.yellow,
                    ),

                    const SizedBox(height: 20),

                    // Nom du jeu
                    Text(
                      _getGameName(widget.gameType),
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 50),

                    // Compte à rebours animé
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$_countdown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Message
                    Text(
                      'Préparez-vous !',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
