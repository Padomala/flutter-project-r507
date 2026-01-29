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
  int _lastLaunchedIndex = -1;
  bool _isGameRunning = false;

  // KILL SWITCH : Empêche toute action une fois qu'on quitte
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  Future<void> _initSession() async {
    if (_isExiting) return;

    final provider = context.read<GameSessionProvider>();
    await provider.loadSession(widget.sessionId);

    if (!mounted || _isExiting) return;

    // Abonnement manuel
    provider.addListener(_onSessionUpdated);

    setState(() {
      _isInitialized = true;
    });

    // Premier check
    _checkAndLaunchGame();
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  void _removeListener() {
    try {
      context.read<GameSessionProvider>().removeListener(_onSessionUpdated);
    } catch (_) {}
  }

  void _onSessionUpdated() {
    // Si on est en train de quitter ou démonté, on ignore tout update
    if (!mounted || _isExiting) return;
    _checkAndLaunchGame();
  }

  void _checkAndLaunchGame() async {
    // Double sécurité
    if (_isExiting) return;

    final provider = context.read<GameSessionProvider>();
    final session = provider.currentSession;

    // 1. Pas de session chargée
    if (session == null || provider.isLoading) return;

    // 2. Vérification de fin de partie
    // On vérifie aussi l'index manuellement pour éviter le RangeError plus tard
    bool isSessionFinished =
        provider.isCompleted ||
        !provider.hasMoreGames ||
        session.currentGameIndex >= session.gamesQueue.length;

    if (isSessionFinished) {
      _goToFinalResults();
      return;
    }

    // 3. Logique de lancement de jeu
    final serverIndex = session.currentGameIndex;

    if (serverIndex > _lastLaunchedIndex && !_isGameRunning) {
      debugPrint('DÉTECTION NOUVEAU JEU: Index $serverIndex');

      _lastLaunchedIndex = serverIndex;
      _isGameRunning = true;

      await _runGameSequence(provider);

      if (mounted && !_isExiting) {
        setState(() {
          _isGameRunning = false;
        });
      }
    }
  }

  Future<void> _runGameSequence(GameSessionProvider provider) async {
    if (_isExiting) return;

    // Safety checks avant de lancer
    if (provider.currentSession == null) return;
    final idx = provider.currentSession!.currentGameIndex;
    if (idx >= provider.currentSession!.gamesQueue.length) return;

    // 1. Transition
    await _showTransition();

    // --- CORRECTION ICI ---
    if (!mounted || _isExiting) return;

    // IMPORTANT : On doit revérifier si la session est null après le await
    // car elle a pu être supprimée pendant l'animation de transition.
    final sessionAfterTransition = provider.currentSession;
    if (sessionAfterTransition == null) {
      debugPrint('Session perdue pendant la transition, arrêt séquence.');
      return;
    }

    // 2. Lancement du jeu (On utilise la variable locale sécurisée)
    final currentGame = sessionAfterTransition.currentGame;
    debugPrint('Lancement UI Jeu: ${currentGame.gameType}');

    try {
      final result = await _navigateToGame(currentGame.gameType);

      if (!mounted || _isExiting) return;

      if (result != null) {
        debugPrint('Sauvegarde résultat local...');
        await provider.saveGameResult(result);
        debugPrint('Résultat sauvegardé. Attente synchro...');
      } else {
        debugPrint('Jeu annulé par utilisateur');
        _exitOrchestrator();
      }
    } catch (e) {
      debugPrint('Erreur séquence jeu: $e');
    }
  }

  Future<GameResult?> _navigateToGame(String gameType) async {
    final provider = context.read<GameSessionProvider>();
    final sessionId = provider.currentSession!.id;

    switch (gameType) {
      case 'clues':
        return await _launchCluesGame(sessionId);
      case 'hot_cold':
        return await _launchHotColdGame(sessionId);
      case 'caesar':
        return await _launchCaesarGame(sessionId);

      default:
        return GameResult.draw(
          gameType: gameType,
          playerIds: provider.currentSession!.playerScores.keys.toList(),
        );
    }
  }

  Future<GameResult?> _launchCaesarGame(String sessionId) async {
    // On génère un ID unique pour cette instance de jeu
    final gameId = '${sessionId}_caesar';
    final provider = context.read<GameSessionProvider>();
    final playerIds = provider.currentSession!.playerScores.keys.toList();

    // On utilise la route nommée définie dans main.dart
    final result =
        await Navigator.pushNamed(
              context,
              '/caesar_game',
              arguments: {'gameId': gameId},
            )
            as Map<String, dynamic>?;

    if (result == null) return null;

    final score = result['score'] as int? ?? 0;

    // On construit le GameResult pour mettre à jour la session globale
    return GameResult(
      gameType: 'caesar',
      winnerId:
          null, // Pas de winner unique en coop, ou à définir selon ta logique
      scores: {
        for (var pid in playerIds) pid: score,
      }, // Tout le monde a le même score en coop ?
      completedAt: DateTime.now(),
      additionalData: {'game_finished': true},
    );
  }

  Future<GameResult?> _launchCluesGame(String sessionId) async {
    final gameId = '${sessionId}_clues';
    final provider = context.read<GameSessionProvider>();
    final playerIds = provider.currentSession!.playerScores.keys.toList();

    if (playerIds.length < 2) return null;

    return await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GuessingGameNotifier(
            gameId: gameId,
            playerAId: playerIds[0],
            playerBId: playerIds[1],
          ),
          child: GuessingGameScreen(gameId: gameId),
        ),
      ),
    ).then((result) {
      if (result == null) return null;
      final playerAScore = result['playerA_score'] as int? ?? 1;
      final playerBScore = result['playerB_score'] as int? ?? 1;

      String? winnerId;
      if (playerAScore > playerBScore)
        winnerId = playerIds[0];
      else if (playerBScore > playerAScore)
        winnerId = playerIds[1];

      return GameResult(
        gameType: 'clues',
        winnerId: winnerId,
        scores: {playerIds[0]: playerAScore, playerIds[1]: playerBScore},
        completedAt: DateTime.now(),
        additionalData: {'game_finished': true},
      );
    });
  }

  Future<GameResult?> _launchHotColdGame(String sessionId) async {
    final gameId = '${sessionId}_hot_cold';
    final provider = context.read<GameSessionProvider>();
    final playerIds = provider.currentSession!.playerScores.keys.toList();

    return await Navigator.push<Map<String, dynamic>?>(
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
    ).then((result) {
      if (result == null) return null;
      final score = result['score'] as int? ?? 10;
      return GameResult(
        gameType: 'hot_cold',
        winnerId: null,
        scores: {for (var pid in playerIds) pid: score},
        completedAt: DateTime.now(),
        additionalData: {'game_finished': true},
      );
    });
  }

  Future<void> _showTransition() async {
    if (!mounted || _isExiting) return;
    final provider = context.read<GameSessionProvider>();
    final session = provider.currentSession;

    if (session == null ||
        session.currentGameIndex >= session.gamesQueue.length)
      return;

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

  // --- Gestion de Fin de Session (Le coeur du fix) ---

  Future<void> _goToFinalResults() async {
    // 1. Si on est déjà en train de sortir, on ne fait rien (Stop Loop)
    if (_isExiting) return;

    // 2. On active le Kill Switch
    _isExiting = true;
    debugPrint('Navigation vers résultats finaux)');

    // 3. On se désabonne IMMÉDIATEMENT
    _removeListener();

    if (!mounted) return;

    // 4. On utilise pushReplacement pour tuer l'Orchestrator
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FinalResultsScreen(sessionId: widget.sessionId),
      ),
    );
  }

  void _exitOrchestrator() {
    _isExiting = true;
    _removeListener();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Si on sort, on affiche un écran vide pour éviter tout crash
    if (_isExiting) {
      return const Scaffold(backgroundColor: Color(0xFF1A1A1A));
    }

    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final provider = context.watch<GameSessionProvider>();
    final session = provider.currentSession;

    if (provider.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: Text(
            'Erreur: ${provider.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // Protection Index Overflow
    if (session == null ||
        session.currentGameIndex >= session.gamesQueue.length) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    // Affichage "En attente" si on ne joue pas et qu'on n'est pas encore redirigé
    bool isWaiting =
        !_isGameRunning && (session.currentGameIndex == _lastLaunchedIndex);

    if (isWaiting) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'En attente des autres joueurs...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return const Scaffold(backgroundColor: Color(0xFF1A1A1A));
  }
}
