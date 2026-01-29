import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_result_model.dart';
import '../providers/game_session_provider.dart';
import '../../../store/provider/room_provider.dart';
import '../../../app_colors.dart';
import '../../../widget/atoms/atom_background_page.dart';

class FinalResultsScreen extends StatefulWidget {
  final String sessionId;

  const FinalResultsScreen({required this.sessionId, super.key});

  @override
  State<FinalResultsScreen> createState() => _FinalResultsScreenState();
}

class _FinalResultsScreenState extends State<FinalResultsScreen> {
  late ConfettiController _confettiController;
  List<GameResult> _results = [];
  bool _isLoading = true;
  bool _isReplaying = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadResults();
  }

  Future<void> _loadResults() async {
    if (!mounted) return;
    final provider = context.read<GameSessionProvider>();
    // On charge les résultats une fois
    final results = await provider.getResults();

    if (!mounted) return;

    setState(() {
      _results = results;
      _isLoading = false;
    });

    // Lancer les confettis
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  String _getWinnerName(String? winnerId) {
    if (winnerId == null) return 'Égalité';

    final roomProvider = context.read<RoomProvider>();
    if (roomProvider.participants.isEmpty) return 'Joueur';

    final participant = roomProvider.participants.firstWhere(
      (p) => p.id == winnerId,
      orElse: () => roomProvider.participants.first,
    );

    return participant.pseudo ?? 'Joueur';
  }

  Future<void> _handleReplay() async {
    if (_isReplaying) return;
    setState(() => _isReplaying = true);

    final roomProvider = context.read<RoomProvider>();
    final sessionProvider = context.read<GameSessionProvider>();
    final amIHost = roomProvider.amIHost;
    final currentRoom = roomProvider.currentRoom;

    try {
      if (amIHost && currentRoom != null) {
        await Supabase.instance.client
            .from('rooms')
            .update({'status': 'waiting'})
            .eq('id', currentRoom.id);

        final playerIds = roomProvider.participants.map((p) => p.id).toList();
        final int rawNbGames = currentRoom.settings?['nb_games'] ?? 3;
        final int nbGames = rawNbGames > 3 ? 3 : rawNbGames;

        await sessionProvider.createSession(
          roomId: currentRoom.id,
          nbGames: nbGames,
          playerIds: playerIds,
        );

        await Supabase.instance.client
            .from('rooms')
            .update({'status': 'playing'})
            .eq('id', currentRoom.id);
      }

      sessionProvider.clearSession();

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du redémarrage: $e')),
        );
        setState(() => _isReplaying = false);
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<GameSessionProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final session = sessionProvider.currentSession;
    final amIHost = roomProvider.amIHost;
    final screenSize = MediaQuery.of(context).size;

    // --- CORRECTION DU BUG ICI ---
    // Si on a fini de charger localement (_isLoading == false)
    // MAIS que la session est null (l'hôte a quitté/supprimé la session),
    // alors on doit sortir de l'écran.
    if (!_isLoading && session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // On retourne à l'accueil
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });
      // On affiche un loader temporaire le temps de la redirection
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.red)),
      );
    }

    // Affichage pendant le chargement initial des données
    if (_isLoading) {
      return const Scaffold(
        body: Stack(
          children: [
            BackgroundPage(pathBackground: 'assets/images/voiture_rouge.png'),
            Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      );
    }
    // --- FIN DE LA CORRECTION ---

    // Note: Si session est null ici, le bloc ci-dessus l'aura attrapé.
    // On utilise une valeur par défaut vide pour éviter le crash si jamais ça passe.
    final safePlayerScores = session?.playerScores ?? {};

    final sortedEntries = safePlayerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final winnerId = sortedEntries.isNotEmpty ? sortedEntries.first.key : null;
    final winnerName = _getWinnerName(winnerId);
    final winnerScore = sortedEntries.isNotEmpty
        ? sortedEntries.first.value
        : 0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. FOND (Style Login/Profile)
          const BackgroundPage(
            pathBackground: 'assets/images/voiture_rouge.png',
          ),

          // 2. Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppColors.green,
                AppColors.blue,
                AppColors.yellow,
                AppColors.red,
              ],
            ),
          ),

          // 3. CONTENU
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenSize.width * 0.9,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.yellow, // Style Profile/Login
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- TITRE ---
                    const Text(
                      'RÉSULTATS',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- CARTE GAGNANT ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 60,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "VAINQUEUR",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            winnerName.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '$winnerScore POINTS',
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- LISTE DES SCORES ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "CLASSEMENT",
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedEntries.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Colors.black12),
                        itemBuilder: (context, index) {
                          final entry = sortedEntries[index];
                          final isWinner = index == 0;
                          return ListTile(
                            leading: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isWinner
                                    ? Colors.amber
                                    : Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              _getWinnerName(entry.key),
                              style: TextStyle(
                                fontWeight: isWinner
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: AppColors.textColor,
                              ),
                            ),
                            trailing: Text(
                              '${entry.value} pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.blue,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- BOUTONS ---
                    Row(
                      children: [
                        // BOUTON QUITTER
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () async {
                                final roomProvider = context
                                    .read<RoomProvider>();
                                final sessionProvider = context
                                    .read<GameSessionProvider>();

                                // Host release room logic
                                if (roomProvider.amIHost &&
                                    roomProvider.currentRoom != null) {
                                  try {
                                    await Supabase.instance.client
                                        .from('rooms')
                                        .update({'status': 'waiting'})
                                        .eq('id', roomProvider.currentRoom!.id);
                                  } catch (_) {}
                                }

                                sessionProvider.clearSession();
                                if (mounted) {
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'QUITTER',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // BOUTON REJOUER
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isReplaying ? null : _handleReplay,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: amIHost
                                    ? AppColors.green
                                    : AppColors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: _isReplaying
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      amIHost ? 'REJOUER' : 'REJOINDRE',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                        ),
                      ],
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
