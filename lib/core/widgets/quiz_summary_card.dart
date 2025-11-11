import 'package:flutter/material.dart';

class QuizSummaryCard extends StatelessWidget {
  final String title;
  final int questionCount;
  final int duration;

  const QuizSummaryCard({
    super.key,
    required this.title,
    required this.questionCount,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blue, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text("$questionCount questions"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.red),
                  const SizedBox(width: 6),
                  Text("$duration min"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
