import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:educonnect_mobile/features/quizzes/domain/entities/quiz.dart';
import 'quiz_play_page.dart';

class WelcomePage extends StatelessWidget {
  final Quiz quiz;
  final int questionCount;
  final int duration;
  final int userId;

  const WelcomePage({
    super.key,
    required this.quiz,
    required this.questionCount,
    required this.duration,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Text(
          "Bienvenue 👋",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🎬 Animation Lottie
            Lottie.asset('assets/animations/learing.json', height: 200),

            const SizedBox(height: 30),

            // 🧠 Titre du quiz
            Text(
              quiz.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // 📊 Résumé du quiz
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_outline, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        "$questionCount questions",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        "$duration min",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🚀 Bouton stylisé
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                "Commencer le quiz",
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPlayPage(quiz: quiz, userId: userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
