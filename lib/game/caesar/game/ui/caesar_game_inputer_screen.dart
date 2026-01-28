import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_v1/game/caesar/game/state/caesar_game_notifier.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';

class CaesarGamePageInputer extends StatefulWidget {
  const CaesarGamePageInputer({super.key});

  @override
  State<CaesarGamePageInputer> createState() => _CaesarGamePageInputerState();
}

class _CaesarGamePageInputerState extends State<CaesarGamePageInputer> {
  final _controller = TextEditingController();
  final _txtController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // we choose the question randomly here
  late final int _questionIndex;
  late final Map<String, String> _question;

  @override
  void initState() {
    super.initState();

    if (kCaesarQuestions.isNotEmpty) {
      // Pick a truly random question index each time
      final random = Random();
      _questionIndex = (kCaesarQuestions.length == 1)
          ? 0
          : random.nextInt(kCaesarQuestions.length);
      _question = kCaesarQuestions[_questionIndex];
    } else {
      _questionIndex = 0;
      _question = {};
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _txtController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    var text = enleverAccents(_txtController.text.trim().toLowerCase());

    //HERE we verify if the answer is correctly formated to continue (not multiple word)
    if (text.isEmpty || text.split(RegExp(r'\s+')).length > 1) {
      showNotification('Veuillez entrer un seul mot non vide.');
      return;
    }
    //HERE we verify if we have a correct answer
    bool correctResponse = await context.read<CaesarGameNotifier>().submitAttempt(text, _question['answerWord'] ?? '');
    if (correctResponse) {
      //CORRECT
      showNotification('Bonne réponse !', color: Colors.greenAccent);

    } else {
      //INCORRECT
      showNotification('Mauvaise réponse !');
    }
    // Attend 2 secondes, puis passe à l'écran de résultats
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.read<CaesarGameNotifier>().goToResult();
  }


  /// Show a notification
  void showNotification(String message, {Color? color}) {
    // Remove current SnackBar to avoid stacking on multiple clicks
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: color ?? Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }


  // Function to choose a question by a specified index from kCaesarQuestions
  Map<String, String> getQuestionByIndex(int index) {
    final questions = kCaesarQuestions;
    if (questions.isEmpty || index < 0 || index >= questions.length) return {};
    return questions[index];
  }

  @override
  Widget build(BuildContext context) {
    final questionText = _question['question'] ?? '';
    final questionMotA = _question['questionWord'] ?? '';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Form(
          key: _formKey,
          child: Column(
            // Forces the column to use all available height 
            // so spacers can actually expand.
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 245, 245),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                        spreadRadius: 3,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Text(
                      'Trouvez la réponse à la question !',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              // FLEX SPACE 1: Pushes the header and the question box apart
              const Spacer(flex: 1),

              // Question Card Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 19,
                        spreadRadius: 5,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Question :', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 12),
                        Text(
                          questionText,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          questionMotA,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 64,
                            fontFamily: 'AstroDotBasic',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // FLEX SPACE 2: This is the "Main" gap that pushes the input to the bottom.
              // Increasing the flex value makes this gap larger relative to others.
              const Spacer(flex: 2),

              // Input Footer Section
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(100, 0, 0, 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Entrez votre réponse',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _txtController,
                decoration: InputDecoration(
                  hintText: 'Votre réponse texte…',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 6),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),

              const SizedBox(height: 16), // Small fixed gap between input and button

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color.fromARGB(255, 18, 184, 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Valider",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              
              // Small padding at the very bottom to prevent the button from touching the edge
              const SizedBox(height: 16), 
            ],
          ),
        ),
      ),
    );
  }
}
