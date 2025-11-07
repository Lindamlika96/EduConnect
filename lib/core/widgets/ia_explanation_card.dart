import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ En-tête sans animation
          Icon(
            isCorrect ? Icons.check_circle : Icons.psychology_alt,
            size: 60,
            color: isCorrect ? Colors.green : const Color(0xFF0066FF),
          ),

          const SizedBox(height: 12),

          Text(
            isCorrect ? "Bonne réponse ✅" : "Explication IA 🤖",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : const Color(0xFF0066FF),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            explanation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFF1E1E1E),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text("Continuer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
