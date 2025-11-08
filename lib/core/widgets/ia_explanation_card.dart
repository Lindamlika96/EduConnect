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
    final Color accentColor = isCorrect
        ? Colors.greenAccent
        : Colors.blueAccent;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Icône dans un cercle coloré
          CircleAvatar(
            radius: 36,
            backgroundColor: accentColor.withOpacity(0.15),
            child: Icon(
              isCorrect ? Icons.check_circle : Icons.psychology_alt,
              size: 48,
              color: accentColor,
            ),
          ),

          const SizedBox(height: 16),

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

          Text(
            explanation,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 1.4,
              color: Colors.white70,
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
    );
  }
}
