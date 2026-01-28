import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_result_model.dart';
import '../providers/game_session_provider.dart';
import '../../../store/provider/room_provider.dart';

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
    final results = await provider.getResults();

    if (!mounted) return; // Protection

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
    final participant = roomProvider.participants.firstWhere(
      (p) => p.id == winnerId,
      orElse: () => roomProvider.participants.first,
    );

    return participant.pseudo ?? 'Joueur';
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<GameSessionProvider>();
    final session = sessionProvider.currentSession;

    if (_isLoading || session == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sortedEntries = session.playerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final winnerId = sortedEntries.isNotEmpty ? sortedEntries.first.key : null;
    final winnerName = _getWinnerName(winnerId);
    final winnerScore = sortedEntries.isNotEmpty
        ? sortedEntries.first.value
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.shade900.withOpacity(0.3),
                  const Color(0xFF1A1A1A),
                  Colors.blue.shade900.withOpacity(0.3),
                ],
              ),
            ),
          ),

          // Confettis
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
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
              ],
            ),
          ),

          // UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '🎉 Partie Terminée ! 🎉',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Winner Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade700, Colors.amber.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          winnerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$winnerScore points',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Scores List
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scores Finaux',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              itemCount: sortedEntries.length,
                              itemBuilder: (context, index) {
                                final entry = sortedEntries[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${index + 1}.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _getWinnerName(entry.key),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${entry.value} pts',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final sessionProvider = context
                                .read<GameSessionProvider>();
                            sessionProvider.clearSession(); // Clean
                            if (mounted)
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Quitter',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
