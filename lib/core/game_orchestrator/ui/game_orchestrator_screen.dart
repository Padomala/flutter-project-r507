import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_result_model.dart';
import '../providers/game_session_provider.dart';
import 'transition_screen.dart';
import 'final_results_screen.dart';
import '../../../game/clues/game/state/guessing_game_notifier.dart';
import '../../../game/clues/game/ui/guessing_game_screen.dart';
import '../../../game/caesar/ui/caesar_game_screen.dart';

class GameOrchestratorScreen extends StatefulWidget {
  final String sessionId;

  const GameOrchestratorScreen({required this.sessionId, super.key});

  @override
  State<GameOrchestratorScreen> createState() => _GameOrchestratorScreenState();
}

class _GameOrchestratorScreenState extends State<GameOrchestratorScreen> {
  bool _isInitialized = false;
  int? _lastPlayedIndex; // Pour éviter de relancer le même jeu en boucle

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = context.read<GameSessionProvider>();

    // Charger la session APRÈS le build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await provider.loadSession(widget.sessionId);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Lancer le premier jeu
        _launchNextGame();
      }
    });

    // Écouter les changements de session pour déclencher _launchNextGame
    // quand l'index change (signifiant que tous les joueurs sont prêts)
    provider.addListener(_onSessionUpdated);
  }

  @override
  void dispose() {
    final provider = context.read<GameSessionProvider>();
    provider.removeListener(_onSessionUpdated);
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

    // Vérifier s'il reste des jeux
    if (!provider.hasMoreGames || provider.isCompleted) {
      debugPrint('🏁 Plus de jeux, affichage des résultats');
      _showFinalResults();
      return;
    }

    // Attendre un peu pour que l'UI se stabilise
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // FIX: Re-vérifier l'état car il a pu changer pendant le délai (stream update)
    // Cela évite le RangeError si l'index a grimpé à la fin de la liste
    if (!provider.hasMoreGames || provider.isCompleted) {
      debugPrint('🏁 Plus de jeux (après délai), affichage des résultats');
      _showFinalResults();
      return;
    }

    // Afficher l'écran de transition
    debugPrint(
      '📺 Affichage transition pour jeu ${provider.currentSession!.currentGameIndex + 1}',
    );
    await _showTransition();

    if (!mounted) return;

    // Lancer le jeu
    final currentGame = provider.currentSession!.currentGame;

    // Mettre à jour l'index joué AVANT de lancer pour bloquer les réentrances
    _lastPlayedIndex = provider.currentSession!.currentGameIndex;

    debugPrint(
      '🎮 Lancement du jeu: ${currentGame.gameType} (index: $_lastPlayedIndex)',
    );
    final result = await _navigateToGame(currentGame.gameType);

    if (!mounted) return;

    // Si on a un résultat, le sauvegarder
    if (result != null) {
      debugPrint('💾 Sauvegarde résultat');
      await provider.saveGameResult(result);

      debugPrint(
        '➡️ Passage au jeu suivant (avant moveToNextGame: ${provider.currentSession!.currentGameIndex})',
      );
      debugPrint('➡️ Attente des autres joueurs...');

      // On ne force plus le passage au jeu suivant ici.
      // C'est le service qui le fera quand tous les résultats seront là.
      // provider.moveToNextGame();

      // On affiche un écran d'attente en attendant que le stream mette à jour l'index
      if (mounted) {
        setState(
          () {},
        ); // Force rebuild to show waiting screen if logic falls through
      }

      // _launchNextGame() sera rappelé automatiquement via le listener/stream
      // quand l'index changera dans la DB.
    } else {
      // L'utilisateur a quitté le jeu, retour au hub
      debugPrint('❌ Utilisateur a quitté le jeu');
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

  Future<GameResult?> _launchCaesarGame() async {
    final provider = context.read<GameSessionProvider>();
    final playerIds = provider.currentSession!.playerScores.keys.toList();
    final gameId = '${widget.sessionId}_caesar';

    debugPrint('🎮 Lancement Caesar: gameId=$gameId');

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => CaesarGameScreen(gameId: gameId, onGameFinished: () {}),
      ),
    );

    if (result == null) return null;

    // Résultat factice pour le moment (victoire partagée ou score fixe)
    return GameResult(
      gameType: 'caesar',
      winnerId: null, // Égalité par défaut
      scores: {
        for (var pid in playerIds) pid: result['score'] as int? ?? 10,
      }, // Score par défaut
      completedAt: DateTime.now(),
      additionalData: {'game_finished': true},
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

  bool _isNavigatingToResults = false;

  void _showFinalResults() {
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
