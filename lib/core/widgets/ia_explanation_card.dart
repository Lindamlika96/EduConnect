import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IAExplanationCard extends StatelessWidget {
  final String explanation;
  final bool isCorrect;

  const IAExplanationCard({
    super.key,
    required this.explanation,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isCorrect
        ? Colors.greenAccent
        : Colors.blueAccent;
    final String animationPath = isCorrect
        ? 'assets/animations/success.json'
        : 'assets/animations/ai_bot.json';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎬 Animation Lottie
              SizedBox(
                height: 120,
                child: Lottie.asset(animationPath, fit: BoxFit.contain),
              ),

              const SizedBox(height: 12),

              Text(
                isCorrect ? "Bonne réponse ✅" : "Explication IA 🤖",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  explanation,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text("Continuer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
