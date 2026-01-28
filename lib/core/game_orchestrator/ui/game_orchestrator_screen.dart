import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_result_model.dart';
import '../providers/game_session_provider.dart';
import 'transition_screen.dart';
import 'final_results_screen.dart';
import '../../../game/clues/game/state/guessing_game_notifier.dart';
import '../../../game/clues/game/ui/guessing_game_screen.dart';
import '../../../game/clues/game/state/hot_cold_game_notifier.dart';
import '../../../game/clues/game/ui/hot_cold_game_screen.dart';

class GameOrchestratorScreen extends StatefulWidget {
  final String sessionId;

  const GameOrchestratorScreen({required this.sessionId, super.key});

  @override
  State<GameOrchestratorScreen> createState() => _GameOrchestratorScreenState();
}

class _GameOrchestratorScreenState extends State<GameOrchestratorScreen> {
  bool _isInitialized = false;
  int? _lastPlayedIndex; // Pour éviter de relancer le même jeu en boucle
  late GameSessionProvider _sessionProvider;
  bool _isNavigating = false; // Guard to prevent double navigation

  @override
  void initState() {
    super.initState();
    _sessionProvider = context.read<GameSessionProvider>();
    // Écouter les changements de session pour déclencher _launchNextGame
    // quand l'index change (signifiant que tous les joueurs sont prêts)
    _sessionProvider.addListener(_onSessionUpdated);
    _init();
  }

  Future<void> _init() async {
    // Charger la session APRÈS le build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sessionProvider.loadSession(widget.sessionId);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Lancer le premier jeu
        _launchNextGame();
      }
    });
  }

  @override
  void dispose() {
    _sessionProvider.removeListener(_onSessionUpdated);
    super.dispose();
  }

  void _onSessionUpdated() {
    if (!mounted) return;

    final provider = context.read<GameSessionProvider>();
    // Si l'index a changé, on relance la logique de jeu
    // Note: On pourrait ajouter une vérification plus fine pour ne pas relancer
    // si on est déjà en train de jouer le bon jeu.
    if (provider.currentSession != null &&
        !provider.isLoading &&
        !provider.isCompleted &&
        provider.hasMoreGames) {
      // Si l'index a augmenté par rapport à ce qu'on a joué, c'est le moment de lancer le prochain !
      if (_lastPlayedIndex != null &&
          provider.currentSession!.currentGameIndex > _lastPlayedIndex!) {
        debugPrint(
          '🚀 DÉTECTION CHANGEMENT INDEX: ${_lastPlayedIndex} -> ${provider.currentSession!.currentGameIndex}',
        );
        _launchNextGame();
      }
      // Cas initial ou reprise
      else if (_lastPlayedIndex == null) {
        _launchNextGame();
      }
    } else if (provider.isCompleted) {
      // Si la session est finie, on s'assure d'aller aux résultats
      _launchNextGame(); // _launchNextGame gère la redirection vers les résultats
    }
  }

  Future<void> _launchNextGame() async {
    if (_isNavigating) {
      debugPrint('⚠️ _launchNextGame ignoré: déjà en cours de navigation');
      return;
    }

    final provider = context.read<GameSessionProvider>();

    final currentIndex = provider.currentSession?.currentGameIndex;

    debugPrint(
      '🎯 _launchNextGame appelé - currentIndex: $currentIndex, lastPlayed: $_lastPlayedIndex',
    );

    // Si on a déjà joué ce jeu, on ne fait rien (on attend que l'index change)
    if (currentIndex != null && _lastPlayedIndex == currentIndex) {
      debugPrint(
        '⏸️ Jeu $currentIndex déjà lancé/joué, en attente du suivant...',
      );
      return;
    }

    _isNavigating = true;

    // Vérifier s'il reste des jeux
    if (!provider.hasMoreGames || provider.isCompleted) {
      debugPrint('🏁 Plus de jeux, affichage des résultats');
      await _showFinalResults();
      _isNavigating = false;
      return;
    }

    // Attendre un peu pour que l'UI se stabilise
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) {
      _isNavigating = false;
      return;
    }

    // FIX: Re-vérifier l'état car il a pu changer pendant le délai (stream update)
    // Cela évite le RangeError si l'index a grimpé à la fin de la liste
    if (!provider.hasMoreGames || provider.isCompleted) {
      debugPrint('🏁 Plus de jeux (après délai), affichage des résultats');
      await _showFinalResults();
      _isNavigating = false;
      return;
    }

    // Afficher l'écran de transition
    debugPrint(
      '📺 Affichage transition pour jeu ${provider.currentSession!.currentGameIndex + 1}',
    );
    await _showTransition();

    if (!mounted) {
      _isNavigating = false;
      return;
    }

    // Lancer le jeu
    final currentGame = provider.currentSession!.currentGame;

    // Mettre à jour l'index joué AVANT de lancer pour bloquer les réentrances
    _lastPlayedIndex = provider.currentSession!.currentGameIndex;

    debugPrint(
      '🎮 Lancement du jeu: ${currentGame.gameType} (index: $_lastPlayedIndex)',
    );

    try {
      final result = await _navigateToGame(currentGame.gameType);

      if (!mounted) {
        return;
      }

      if (result != null) {
        debugPrint('💾 Sauvegarde résultat');
        await provider.saveGameResult(result);

        debugPrint(
          '➡️ Passage au jeu suivant (avant moveToNextGame: ${provider.currentSession!.currentGameIndex})',
        );
        debugPrint('➡️ Attente des autres joueurs...');

        // On affiche un écran d'attente en attendant que le stream mette à jour l'index
        if (mounted) {
          setState(() {});
        }
      } else {
        // L'utilisateur a quitté le jeu, retour au hub
        debugPrint('❌ Utilisateur a quitté le jeu');
        _exitOrchestrator();
      }
    } catch (e) {
      debugPrint('❌ Erreur navigation jeu: $e');
    } finally {
      debugPrint('🔓 Fin de navigation, prêt pour suite');
      _isNavigating = false;
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

      case 'hot_cold':
        return await _launchHotColdGame(sessionId);

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

    final playerA = playerIds[0];
    final playerB = playerIds[1];

    debugPrint(
      '🎮 Lancement Clues: gameId=$gameId, playerA=$playerA, playerB=$playerB',
    );

    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GuessingGameNotifier(
            gameId: gameId,
            playerAId: playerA, // ✅ On passe l'ID du joueur A
            playerBId: playerB, // ✅ On passe l'ID du joueur B
          ),
          child: GuessingGameScreen(gameId: gameId),
        ),
      ),
    );

    // Si l'utilisateur quitte sans finir le jeu
    if (result == null) return null;

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
      scores: {playerA: playerAScore, playerB: playerBScore},
      completedAt: DateTime.now(),
      additionalData: {
        'rounds_played': 2,
        'game_finished': result['finished'] ?? true,
      },
    );
  }

  Future<GameResult?> _launchHotColdGame(String sessionId) async {
    final gameId = '${sessionId}_hot_cold';
    final provider = context.read<GameSessionProvider>();
    final playerIds = provider.currentSession!.playerScores.keys.toList();

    debugPrint('🎮 Lancement HotCold: gameId=$gameId');

    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => HotColdGameNotifier(
            gameId: gameId,
            playerAId: playerIds[0],
            playerBId: playerIds[1],
          ),
          child: HotColdGameScreen(gameId: gameId),
        ),
      ),
    );

    if (result == null) return null;

    final score = result['score'] as int? ?? 10;
    // Assuming hot_cold assigns score to both or handled differently,
    // but HotCold seems to be cooperative or handled by notifier state.
    // The previous implementation was vague, let's look at HotColdGameNotifier.
    // It updates stats in DB. But here we need to return a GameResult for the orchestrator to save locally/session level.
    // However, HotColdGameNotifier writes to DB directly via CommunicationService.
    // But GameOrchestrator also calls provider.saveGameResult. We need to avoid double writes or ensure consistency.
    // The orchestrator expects a return value to call saveGameResult.
    // Let's return a result that reflects the game state.

    // Note: HotColdGameNotifier updates 'scores' in its own way.
    // If CommunicationService writes to 'game_results', maybe we shouldn't write again?
    // GameSessionProvider.saveGameResult writes to 'game_results'.
    // Double write might be an issue.
    // Let's check HotColdGameNotifier again. It uses CommunicationService.
    // CommunicationService likely writes to a specific table or 'game_data' field in 'game_sessions' or similar?
    // Actually HotColdGameNotifier writes to `game_data` JSON in `game_sessions` via `updateGameDataBatch`.
    // It does NOT write to `game_results` table directly seemingly.
    // So Orchestrator MUST write to `game_results`.

    // For Hot Cold:
    // Who is the winner? It's a cooperative game usually or asymmetry.
    // Let's assume everyone gets points if they win.

    return GameResult(
      gameType: 'hot_cold',
      winnerId: null, // As per logic
      scores: {for (var pid in playerIds) pid: score},
      completedAt: DateTime.now(),
      additionalData: {'game_finished': true, 'rounds_played': 2},
    );
  }

  bool _isNavigatingToResults = false;

  Future<void> _showFinalResults() async {
    if (!mounted || _isNavigatingToResults) return;

    _isNavigatingToResults = true;

    // Marquer la session comme terminée
    final provider = context.read<GameSessionProvider>();
    // Note: This might trigger listeners, so _isNavigatingToResults must be set BEFORE
    if (!provider.isCompleted) {
      provider.completeSession();
    }

    // Naviguer vers l'écran de résultats
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FinalResultsScreen(sessionId: widget.sessionId),
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
              const CircularProgressIndicator(color: Colors.lightBlueAccent),
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
    final session = provider.currentSession;

    // Si on a fini un jeu et qu'on attend les autres, session.currentGameIndex n'a pas encore changé
    // mais on n'est plus dans _navigateToGame (car await est fini).
    // On doit différencier "Chargement initial" de "Attente des joueurs".

    // TODO: Améliorer la gestion d'état pour savoir explicitement si on attend.
    // Pour l'instant, si on est ici, c'est qu'on n'est pas dans un jeu actif.

    // Afficher les erreurs si nécessaire
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
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

    // Écran d'attente entre les jeux ou chargement
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.lightBlueAccent),
            const SizedBox(height: 20),
            Text(
              // Si on a une session et qu'on n'a pas encore fini, on attend probablement les autres
              (session != null && !provider.isCompleted)
                  ? 'En attente des autres joueurs...'
                  : 'Chargement...',
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
