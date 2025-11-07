import 'package:educonnect_mobile/features/quizzes/domain/entities/quiz.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'quiz_play_page.dart';

class WelcomePage extends StatelessWidget {
  final Quiz quiz;
  final int questionCount;
  final int duration;

  const WelcomePage({
    super.key,
    required this.quiz,
    required this.questionCount,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Text(
          "Bienvenue 👋",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation Lottie professionnelle
            Lottie.asset('assets/animations/learing.json', height: 220),

            const SizedBox(height: 30),

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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.help_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "$questionCount questions",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.timer, color: Colors.red),
                const SizedBox(width: 8),
                Text("$duration min", style: const TextStyle(fontSize: 16)),
              ],
            ),

            const SizedBox(height: 40),

            // Bouton animé
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizPlayPage(quiz: quiz)),
                );
              },
              child: const Text(
                "🚀 Commencer le quiz",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
