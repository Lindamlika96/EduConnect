import 'package:educonnect_mobile/features/quizzes/services/certificate_service.dart'
    show CertificateService;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:educonnect_mobile/features/quizzes/domain/entities/question.dart';

import 'package:printing/printing.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final int quizId;
  final List<Question> questions;
  final List<int> userAnswers;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.quizId,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    if (widget.score / widget.total >= 0.8) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getTrophy() {
    final ratio = widget.score / widget.total;
    if (ratio == 1.0) return "🥇 Or";
    if (ratio >= 0.8) return "🥈 Argent";
    if (ratio >= 0.6) return "🥉 Bronze";
    return "🎯 Participation";
  }

  Color _getTrophyColor() {
    final ratio = widget.score / widget.total;
    if (ratio == 1.0) return Colors.amber;
    if (ratio >= 0.8) return Colors.grey;
    if (ratio >= 0.6) return Colors.brown;
    return Colors.blueGrey;
  }

  Map<String, Map<String, int>> _calculateStats() {
    final stats = {
      "facile": {"correct": 0, "total": 0},
      "moyen": {"correct": 0, "total": 0},
      "difficile": {"correct": 0, "total": 0},
    };
    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final diff = q.difficulty;
      stats[diff]!["total"] = stats[diff]!["total"]! + 1;
      if (widget.userAnswers[i] == q.correctIndex) {
        stats[diff]!["correct"] = stats[diff]!["correct"]! + 1;
      }
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.score / widget.total;
    final stats = _calculateStats();

    return Scaffold(
      appBar: AppBar(title: const Text("Résultats")),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Cercle de progression
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: ratio,
                            strokeWidth: 12,
                            color: _getTrophyColor(),
                            backgroundColor: Colors.grey[300],
                          ),
                          Center(
                            child: Text(
                              "${(ratio * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Score : ${widget.score} / ${widget.total}",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Trophée : ${_getTrophy()}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTrophyColor(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Résumé par difficulté
                    ...stats.entries.map((entry) {
                      final diff = entry.key;
                      final correct = entry.value["correct"]!;
                      final total = entry.value["total"]!;
                      return Card(
                        child: ListTile(
                          title: Text("$diff : $correct / $total"),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Retour"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Rejouer"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final certificateService = CertificateService();
                            final pdfData = await certificateService
                                .generateCertificate(
                                  userName: "Wissal",
                                  quizTitle: "Quiz #${widget.quizId}",
                                  score: widget.score,
                                  total: widget.total,
                                );
                            await Printing.layoutPdf(
                              onLayout: (format) async => pdfData,
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Certificat"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
