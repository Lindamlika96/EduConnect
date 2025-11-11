import 'dart:async';
import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/db/app_database.dart';
import 'package:educonnect_mobile/features/quizzes/data/dao/quiz_dao_impl.dart';
import 'package:educonnect_mobile/features/quizzes/data/repository/quiz_repository_impl.dart';
import 'package:educonnect_mobile/features/quizzes/domain/usecases/get_questions_usecase.dart';
import 'package:educonnect_mobile/features/quizzes/domain/entities/question.dart';
import 'package:educonnect_mobile/features/quizzes/domain/entities/quiz.dart';
import 'package:educonnect_mobile/features/quizzes/domain/presentation/pages/result_page.dart';
import 'package:educonnect_mobile/features/quizzes/domain/presentation/pages/level_up_page.dart';
import 'package:educonnect_mobile/features/quizzes/services/openai_service.dart';
import 'package:lottie/lottie.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:educonnect_mobile/core/widgets/ia_explanation_card.dart';

class AdaptiveController {
  String currentDifficulty = "facile";
  int consecutiveCorrect = 0;

  String? registerAnswer(bool isCorrect) {
    if (isCorrect) {
      consecutiveCorrect++;
      if (consecutiveCorrect >= 3) {
        return _levelUp();
      }
    } else {
      consecutiveCorrect = 0;
    }
    return null;
  }

  String? _levelUp() {
    if (currentDifficulty == "facile") {
      currentDifficulty = "moyen";
      consecutiveCorrect = 0;
      return "Bravo 🎉 tu passes au niveau MOYEN !";
    } else if (currentDifficulty == "moyen") {
      currentDifficulty = "difficile";
      consecutiveCorrect = 0;
      return "Excellent 🚀 tu passes au niveau DIFFICILE !";
    }
    return null;
  }
}

class QuizPlayPage extends StatefulWidget {
  final Quiz quiz;
  final String mode;
  final String? difficulty;
  final int userId;

  const QuizPlayPage({
    super.key,
    required this.quiz,
    this.mode = "classique",
    this.difficulty,
    required this.userId,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage>
    with WidgetsBindingObserver {
  late final GetQuestionsUseCase _getQuestionsUseCase;
  final AdaptiveController adaptiveController = AdaptiveController();
  final openAI = OpenAIService();

  List<Question> questions = [];
  List<int> userAnswers = [];
  int currentIndex = 0;
  int score = 0;
  int? selectedIndex;
  bool answered = false;
  bool loading = true;

  Timer? _timer;
  int remainingTime = 20;
  final int maxTime = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🚨 Active protection contre capture d’écran
    ScreenProtector.preventScreenshotOn();
    ScreenProtector.protectDataLeakageOn();

    final dao = QuizDaoImpl(AppDatabase.database);
    final repo = QuizRepositoryImpl(dao);
    _getQuestionsUseCase = GetQuestionsUseCase(repo);
    _loadQuestions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // 🔓 Désactive protection
    ScreenProtector.preventScreenshotOff();
    ScreenProtector.protectDataLeakageOff();

    _timer?.cancel();
    super.dispose();
  }

  // 🚨 Détection triche : quitter/minimiser l’app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _onCheatingDetected("Tu as quitté la fenêtre du quiz !");
    }
  }

  void _onCheatingDetected(String reason) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("⚠️ Suspicion de triche : $reason")));
    setState(() {
      score = (score > 0) ? score - 1 : 0; // pénalité
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => remainingTime = maxTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        timer.cancel();
        _answerQuestion(-1);
      }
    });
  }

  Future<void> _loadQuestions() async {
    List<Question> qs = [];
    if (widget.mode == "adaptatif") {
      qs = await _getQuestionsUseCase.getByDifficulty(
        widget.quiz.id,
        adaptiveController.currentDifficulty,
      );
    } else if (widget.mode == "mixte") {
      qs = await _getQuestionsUseCase.getMixed(widget.quiz.id);
    } else if (widget.difficulty != null) {
      qs = await _getQuestionsUseCase.getByDifficulty(
        widget.quiz.id,
        widget.difficulty!,
      );
    } else {
      qs = await _getQuestionsUseCase(widget.quiz.id);
    }

    qs.shuffle();
    setState(() {
      questions = qs;
      userAnswers = List.filled(qs.length, -1);
      loading = false;
      currentIndex = 0;
      answered = false;
      selectedIndex = null;
    });
    _startTimer();
  }

  void _answerQuestion(int index) async {
    if (answered) return;

    final question = questions[currentIndex];
    final isCorrect = index == question.correctIndex;

    setState(() {
      selectedIndex = index;
      answered = true;
      userAnswers[currentIndex] = index;
      if (isCorrect) score++;
    });

    // ✅ Explication IA si mauvaise réponse
    // ✅ Explication IA avec IAExplanationCard
    if (!isCorrect) {
      try {
        final userAnswerText = index == -1
            ? "Pas de réponse (temps écoulé)"
            : question.options[index];

        final explanation = await openAI.getExplanation(
          question.text,
          userAnswerText,
          question.options[question.correctIndex],
        );

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) =>
              IAExplanationCard(explanation: explanation, isCorrect: isCorrect),
        );
      } catch (_) {}
    }

    // ✅ LevelUp logique
    final levelUpMessage = adaptiveController.registerAnswer(isCorrect);

    if (widget.mode == "adaptatif" && levelUpMessage != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LevelUpPage(difficulty: adaptiveController.currentDifficulty),
        ),
      );
      await _loadQuestions();
      return;
    }

    // Sinon progression normale
    Future.delayed(const Duration(seconds: 1), () async {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          answered = false;
          selectedIndex = null;
        });
        _startTimer();
      } else {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              score: score,
              total: questions.length,
              quizId: widget.quiz.id,
              questions: questions,
              userAnswers: userAnswers,
              userId: widget.userId,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0066FF)),
        ),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0066FF), Color(0xFF5A00FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header avec timer et niveau
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Column(
                      children: [
                        Text(
                          widget.quiz.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "⏱ $remainingTime s | Niveau: ${adaptiveController.currentDifficulty.toUpperCase()} | Série: ${adaptiveController.consecutiveCorrect}/3",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 20),
                Lottie.asset(
                  'assets/animations/book.json', // adapte le nom
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                // Question Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Question ${currentIndex + 1}/${questions.length}",
                          style: const TextStyle(
                            color: Color(0xFF0066FF),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 🚫 Question non copiable
                        Text(
                          question.text,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Options
                        ...question.options.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final text = entry.value;

                          Color bgColor = Colors.grey.shade200;
                          Color textColor = Colors.black;

                          if (answered) {
                            if (idx == question.correctIndex) {
                              bgColor = Colors.green.shade400;
                              textColor = Colors.white;
                            } else if (selectedIndex == idx) {
                              bgColor = Colors.red.shade400;
                              textColor = Colors.white;
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Material(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => _answerQuestion(idx),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Text(
                                        String.fromCharCode(65 + idx) + ". ",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        const Spacer(),

                        // Next button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 60,
                              ),
                            ),
                            onPressed: answered
                                ? () {
                                    if (currentIndex < questions.length - 1) {
                                      setState(() {
                                        currentIndex++;
                                        answered = false;
                                        selectedIndex = null;
                                      });
                                      _startTimer();
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ResultPage(
                                            score: score,
                                            total: questions.length,
                                            quizId: widget.quiz.id,
                                            questions: questions,
                                            userAnswers: userAnswers,
                                            userId: widget.userId,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: const Text(
                              "Suivant",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
