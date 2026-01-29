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
  bool _isProcessingGameSequence = false;
  bool _isExiting = false; // Empêche toute action une fois qu'on quitte

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
    provider.addListener(_onSessionUpdated);
    setState(() => _isInitialized = true);
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
    if (!mounted || _isExiting) return;
    _checkAndLaunchGame();
  }

  void _checkAndLaunchGame() async {
    if (_isExiting) return;

    // Si on est déjà en train de gérer un lancement de jeu, on ignore les updates intermédiaires
    // (Ex: Update de score d'un joueur pendant la transition)
    if (_isProcessingGameSequence) return;

    final provider = context.read<GameSessionProvider>();
    final session = provider.currentSession;

    if (session == null || provider.isLoading) return;

    // --- FIN DE SESSION ---
    // Vérification stricte
    bool isSessionFinished =
        session.status == 'completed' ||
        session.currentGameIndex >= session.gamesQueue.length;

    if (isSessionFinished) {
      _goToFinalResults();
      return;
    }

    // --- LANCEMENT D'UN JEU ---
    final serverIndex = session.currentGameIndex;

    // On ne lance que si c'est un NOUVEAU jeu par rapport à ce qu'on a déjà lancé
    if (serverIndex > _lastLaunchedIndex) {
      debugPrint('🚀 DÉMARRAGE SÉQUENCE JEU : Index $serverIndex');

      setState(() {
        _isProcessingGameSequence = true; // VERROUILLAGE
        _lastLaunchedIndex =
            serverIndex; // On marque comme traité immédiatement
      });

      await _runGameSequence(provider);

      if (mounted && !_isExiting) {
        setState(() {
          _isProcessingGameSequence = false; // DÉVERROUILLAGE
        });

        // Petit check de sécurité : si l'index a bougé PENDANT qu'on jouait
        // (cas rare mais possible), on rappelle la fonction.
        if (provider.currentSession != null &&
            provider.currentSession!.currentGameIndex > _lastLaunchedIndex) {
          _checkAndLaunchGame();
        }
      }
    }
  }

  Future<void> _runGameSequence(GameSessionProvider provider) async {
    if (_isExiting) return;

    // 1. Transition
    await _showTransition();

    if (!mounted || _isExiting) return;

    // Re-vérification de la session après transition
    final session = provider.currentSession;
    if (session == null) return;

    // 2. Lancement du jeu
    final currentGame = session.currentGame;
    debugPrint('🎮 UI Jeu lancée : ${currentGame.gameType}');

    try {
      final result = await _navigateToGame(currentGame.gameType);

      if (!mounted || _isExiting) return;

      if (result != null) {
        debugPrint('💾 Sauvegarde résultat local...');
        // On sauvegarde le résultat.
        // NOTE: Le service gère le passage au jeu suivant (moveToNextGame)
        // si nous sommes le dernier joueur.
        await provider.saveGameResult(result);
      } else {
        // Si result est null, c'est que l'utilisateur a fait "Retour" système
        // ou qu'il y a eu une erreur. On quitte proprement.
        debugPrint('⚠️ Jeu annulé ou retour utilisateur');
        _exitOrchestrator();
      }
    } catch (e) {
      debugPrint('❌ Erreur critique séquence jeu: $e');
      // En cas d'erreur, on débloque pour permettre un retry ou une sortie
    }
  }

  Future<GameResult?> _navigateToGame(String gameType) async {
    final provider = context.read<GameSessionProvider>();
    final sessionId = provider.currentSession!.id;

    // Important : Si le widget est démonté pendant l'appel, Navigator throw une erreur.
    // Les blocs try/catch autour de _runGameSequence gèrent ça.

    switch (gameType) {
      case 'clues':
        return await _launchCluesGame(sessionId);
      case 'hot_cold':
        return await _launchHotColdGame(sessionId);
      case 'caesar':
        return await _launchCaesarGame(sessionId);
      default:
        // Fallback pour éviter de bloquer
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

    if (session == null) return;

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

  Future<void> _goToFinalResults() async {
    if (_isExiting) return;
    _isExiting = true;
    _removeListener();

    if (!mounted) return;

    // Utilisation de pushReplacement pour nettoyer l'Orchestrator de la pile
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FinalResultsScreen(sessionId: widget.sessionId),
      ),
    );
  }

  void _exitOrchestrator() {
    if (_isExiting) return;
    _isExiting = true;
    _removeListener();
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (_isExiting) return const Scaffold(backgroundColor: Color(0xFF1A1A1A));

    final provider = context.watch<GameSessionProvider>();
    final session = provider.currentSession;
    final hasError = provider.error != null;

    if (!_isInitialized || (session == null && !hasError)) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (hasError) {
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

    // Protection Index
    if (session!.currentGameIndex >= session.gamesQueue.length) {
      return const Scaffold(backgroundColor: Color(0xFF1A1A1A));
    }

    // Affichage "En attente"
    // On affiche cet écran si on a fini notre jeu, qu'on a sauvegardé,
    // mais que Supabase n'a pas encore envoyé le signal du jeu suivant (index n'a pas bougé).
    bool isWaitingForOthers =
        !_isProcessingGameSequence &&
        (session.currentGameIndex == _lastLaunchedIndex);

    if (isWaitingForOthers) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 30),
              const Text(
                'En attente des autres joueurs...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Jeu ${session.currentGameIndex + 1} terminé',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Écran noir par défaut pendant les transitions techniques
    return const Scaffold(backgroundColor: Color(0xFF1A1A1A));
  }
}
