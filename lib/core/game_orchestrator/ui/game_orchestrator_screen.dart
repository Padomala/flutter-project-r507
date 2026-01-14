import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_result_model.dart';
import '../providers/game_session_provider.dart';
import 'transition_screen.dart';
import 'final_results_screen.dart';
import '../../../game/clues/game/state/guessing_game_notifier.dart';
import '../../../game/clues/game/ui/guessing_game_screen.dart';
// Caesar game imports - update when Caesar is properly structured
// import '../../../game/caesar/game/ui/caesar_game_main_screen.dart';

class GameOrchestratorScreen extends StatefulWidget {
  final String sessionId;

  const GameOrchestratorScreen({
    required this.sessionId,
    super.key,
  });

  @override
  State<GameOrchestratorScreen> createState() => _GameOrchestratorScreenState();
}

class _GameOrchestratorScreenState extends State<GameOrchestratorScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = context.read<GameSessionProvider>();
    
    // Charger la session
    await provider.loadSession(widget.sessionId);
    
    setState(() {
      _isInitialized = true;
    });
    
    // Lancer le premier jeu
    _launchNextGame();
  }

  Future<void> _launchNextGame() async {
    final provider = context.read<GameSessionProvider>();
    
    // Vérifier s'il reste des jeux
    if (!provider.hasMoreGames || provider.isCompleted) {
      _showFinalResults();
      return;
    }
    
    // Attendre un peu pour que l'UI se stabilise
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    // Afficher l'écran de transition
    await _showTransition();
    
    if (!mounted) return;
    
    // Lancer le jeu
    final currentGame = provider.currentSession!.currentGame;
    final result = await _navigateToGame(currentGame.gameType);
    
    if (!mounted) return;
    
    // Si on a un résultat, le sauvegarder
    if (result != null) {
      await provider.saveGameResult(result);
      await provider.moveToNextGame();
      
      // Passer au jeu suivant
      _launchNextGame();
    } else {
      // L'utilisateur a quitté le jeu, retour au hub
      _exitOrchestrator();
    }
  }

  Future<void> _showTransition() async {
    final provider = context.read<GameSessionProvider>();
    final session = provider.currentSession!;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransitionScreen(
          gameNumber: session.currentGameIndex + 1,
          totalGames: session.totalGames,
          gameType: session.currentGame.gameType,
        ),
      ),
    );
  }

  Future<GameResult?> _navigateToGame(String gameType) async {
    final provider = context.read<GameSessionProvider>();
    final sessionId = provider.currentSession!.id;
    
    debugPrint('🎮 Lancement du jeu: $gameType');
    
    // Router vers le bon jeu selon le type
    switch (gameType) {
      case 'clues':
        return await _launchCluesGame(sessionId);
      
      case 'caesar':
        return await _launchCaesarGame();
      
      case 'labyrinthe':
        return await _launchLabyrintheGame();
      
      default:
        debugPrint('⚠️ Type de jeu inconnu: $gameType');
        // Résultat par défaut pour jeu non implémenté
        return GameResult.draw(
          gameType: gameType,
          playerIds: provider.currentSession!.playerScores.keys.toList(),
        );
    }
  }

  Future<GameResult?> _launchCluesGame(String sessionId) async {
    // Créer un game_data spécifique pour ce jeu dans la session
    final gameId = '${sessionId}_clues';
    
    final provider = context.read<GameSessionProvider>();
    final playerIds = provider.currentSession!.playerScores.keys.toList();
    
    // Vérifier qu'on a bien 2 joueurs
    if (playerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Il faut 2 joueurs pour ce jeu')),
      );
      return GameResult.draw(gameType: 'clues', playerIds: playerIds);
    }
    
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GuessingGameNotifier(gameId: gameId),
          child: GuessingGameScreen(gameId: gameId),
        ),
      ),
    );
    
    // Si l'utilisateur quitte sans finir le jeu
    if (result == null) return null;
    
    final playerA = playerIds[0];
    final playerB = playerIds[1];
    
    // Extraire les scores du résultat
    final playerAScore = result['playerA_score'] as int? ?? 1;
    final playerBScore = result['playerB_score'] as int? ?? 1;
    
    // Déterminer le gagnant
    String? winnerId;
    if (playerAScore > playerBScore) {
      winnerId = playerA;
    } else if (playerBScore > playerAScore) {
      winnerId = playerB;
    }
    // Sinon winnerId reste null (égalité)
    
    return GameResult(
      gameType: 'clues',
      winnerId: winnerId,
      scores: {
        playerA: playerAScore,
        playerB: playerBScore,
      },
      completedAt: DateTime.now(),
      additionalData: {
        'rounds_played': 2,
        'game_finished': result['finished'] ?? true,
      },
    );
  }

  Future<GameResult?> _launchCaesarGame() async {
    // TODO: Mettre à jour quand la structure de Caesar sera clarifiée
    // Le jeu Caesar est dans game/caesar/game/ui/ mais il faut voir quelle page utiliser
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le jeu Caesar n\'est pas encore intégré à l\'orchestrateur'),
        duration: Duration(seconds: 2),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    // Résultat temporaire : égalité
    final provider = context.read<GameSessionProvider>();
    final playerIds = provider.currentSession!.playerScores.keys.toList();
    
    return GameResult.draw(
      gameType: 'caesar',
      playerIds: playerIds,
      pointsEach: 0,
    );
  }

  Future<GameResult?> _launchLabyrintheGame() async {
    // TODO: Implémenter le jeu Labyrinthe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le jeu Labyrinthe n\'est pas encore implémenté'),
        duration: Duration(seconds: 2),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    // Résultat temporaire : égalité
    final provider = context.read<GameSessionProvider>();
    final playerIds = provider.currentSession!.playerScores.keys.toList();
    
    return GameResult.draw(
      gameType: 'labyrinthe',
      playerIds: playerIds,
      pointsEach: 0,
    );
  }

  void _showFinalResults() {
    // Marquer la session comme terminée
    final provider = context.read<GameSessionProvider>();
    provider.completeSession();
    
    // Naviguer vers l'écran de résultats
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FinalResultsScreen(
          sessionId: widget.sessionId,
        ),
      ),
    );
  }

  void _exitOrchestrator() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(height: 20),
              Text(
                'Préparation des jeux...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final provider = context.watch<GameSessionProvider>();
    
    // Afficher les erreurs si nécessaire
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 20),
              Text(
                'Erreur',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  provider.error!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _exitOrchestrator,
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    // Écran d'attente entre les jeux
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.lightBlueAccent,
            ),
            const SizedBox(height: 20),
            Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
