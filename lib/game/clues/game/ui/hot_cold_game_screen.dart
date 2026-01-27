import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/game_enums.dart';
import '../../../../app_colors.dart';
import '../state/hot_cold_game_notifier.dart';

class HotColdGameScreen extends StatefulWidget {
  final String gameId;
  const HotColdGameScreen({super.key, required this.gameId});

  @override
  State<HotColdGameScreen> createState() => _HotColdGameScreenState();
}

class _HotColdGameScreenState extends State<HotColdGameScreen> {
  final TextEditingController _guessController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _guessController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final notifier = context.read<HotColdGameNotifier>();
    final state = context.watch<HotColdGameNotifier>().state;
    final isLoading = notifier.isLoading;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/voiture_rouge.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withAlpha(70)),

          // 2. BOUTON RETOUR
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(100),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. INDICATEUR DE MANCHE
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Manche ${state.currentRound} / 2",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // 4. CONTENU PRINCIPAL
          Center(
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.height * 0.75,
              margin: const EdgeInsets.only(top: 80),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(70),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildGameContent(state, notifier, isLoading),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(
    dynamic state,
    HotColdGameNotifier notifier,
    bool isLoading,
  ) {
    if (state.currentState == GameStateEnum.waiting) {
      return _buildWaitingScreen();
    }

    if (state.currentState == GameStateEnum.results ||
        state.gameData.isCorrect == true) {
      return _buildResultsScreen(state, notifier, isLoading);
    }

    return Column(
      children: [
        _buildThemeHeader(state.gameData.theme),
        const SizedBox(height: 20),

        Expanded(
          child: state.amIDescriber
              ? _buildDescriberView(state, notifier)
              : _buildGuesserView(state, notifier, isLoading),
        ),
      ],
    );
  }

  // --- 1. VUE DU MAÎTRE (CELUI QUI SAIT) ---
  Widget _buildDescriberView(dynamic state, HotColdGameNotifier notifier) {
    final history = state.gameData.history;
    final lastAttempt = history.isNotEmpty ? history.last : null;
    final String lastWord = lastAttempt != null ? lastAttempt['word'] : "...";
    final String lastTemp = lastAttempt != null
        ? lastAttempt['temperature']
        : "waiting";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("FAITES DEVINER :", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 10),

        // LE MOT CIBLE
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            state.gameData.targetWord.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),

        const Spacer(),

        // LA PROPOSITION DU JOUEUR B
        const Text(
          "Dernière proposition :",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 5),
        Text(
          lastWord,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const Spacer(),

        if (history.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildTempButton(
                  "FROID ❄️",
                  Colors.lightBlueAccent,
                  () => notifier.rateLastAttempt('cold'),
                  isSelected: lastTemp == 'cold',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTempButton(
                  "CHAUD 🔥",
                  Colors.orangeAccent,
                  () => notifier.rateLastAttempt('hot'),
                  isSelected: lastTemp == 'hot',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: _buildTempButton(
              "C'EST GAGNÉ ! 🏆",
              Colors.green,
              () => notifier.rateLastAttempt('found'),
              isSelected: false,
            ),
          ),
        ] else ...[
          const Text(
            "En attente que l'autre joueur écrive...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  // --- 2. VUE DU CHERCHEUR (CELUI QUI DEVINE) ---
  Widget _buildGuesserView(
    dynamic state,
    HotColdGameNotifier notifier,
    bool isLoading,
  ) {
    final history = state.gameData.history;

    return Column(
      children: [
        Expanded(
          child: history.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _buildHistoryItem(item);
                  },
                ),
        ),

        const SizedBox(height: 15),
        const Divider(),

        _buildStyledTextField(
          _guessController,
          "Votre proposition...",
          Icons.search,
        ),
        const SizedBox(height: 15),

        _buildStyledButton("ENVOYER", isLoading, () {
          notifier.submitAttempt(_guessController.text);
          _guessController.clear();
        }, color: AppColors.blue),
      ],
    );
  }

  // --- WIDGETS UI ---

  Widget _buildThemeHeader(String theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.category, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            "THÈME : ${theme.toUpperCase()}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, String> item) {
    final temp = item['temperature'];
    Color bgColor;
    Color textColor = Colors.white;
    String statusIcon;

    switch (temp) {
      case 'hot':
        bgColor = Colors.redAccent;
        statusIcon = "🔥";
        break;
      case 'cold':
        bgColor = Colors.lightBlueAccent;
        statusIcon = "❄️";
        break;
      case 'waiting':
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.black87;
        statusIcon = "⏳";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item['word']!.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          Text(statusIcon, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildTempButton(
    String label,
    Color color,
    VoidCallback onTap, {
    required bool isSelected,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: isSelected ? 10 : 2,
        side: isSelected
            ? const BorderSide(color: Colors.black, width: 3)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hearing, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            "Aucune proposition pour le moment.\nLancez-vous !",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: AppColors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton(
    String label,
    bool isLoading,
    VoidCallback onPressed, {
    Color color = AppColors.blue,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.blue),
    );
  }

  Widget _buildResultsScreen(
    dynamic state,
    HotColdGameNotifier notifier,
    bool isLoading,
  ) {
    final bool isLastRound = state.currentRound == 2;
    final bool isCorrect = state.gameData.isCorrect == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
        const SizedBox(height: 20),
        const Text(
          "TROUVÉ !",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          "Le mot était : ${state.gameData.targetWord}",
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 40),
        _buildStyledButton(
          isLastRound ? 'JEU SUIVANT' : 'MANCHE SUIVANTE',
          isLoading,
          () {
            if (isLastRound) {
              final totalScore = state.gameData.score;

              final gameResult = {'finished': true, 'score': totalScore};

              Navigator.pop(context, gameResult);
            } else {
              notifier.proceedToNextStep();
            }
          },
          color: isCorrect ? Colors.green : AppColors.blue,
        ),
      ],
    );
  }
}
