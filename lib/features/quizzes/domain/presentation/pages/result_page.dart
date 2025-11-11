import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'package:printing/printing.dart';
import 'package:educonnect_mobile/features/quizzes/domain/entities/question.dart';
import 'package:educonnect_mobile/features/quizzes/services/certificate_service.dart';
import 'podium_page.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final int quizId;
  final List<Question> questions;
  final List<int> userAnswers;
  final int userId;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.quizId,
    required this.questions,
    required this.userAnswers,
    required this.userId,
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

  List<Map<String, dynamic>> getSortedScores() {
    final scores = [
      {"username": "Wissal", "userId": widget.userId, "score": widget.score},
      {"username": "Yasmine", "userId": 102, "score": 26},
      {"username": "Omar", "userId": 103, "score": 22},
      {"username": "Sami", "userId": 104, "score": 18},
    ];
    scores.sort((a, b) {
      final scoreA = a['score'] as int? ?? 0;
      final scoreB = b['score'] as int? ?? 0;
      return scoreB.compareTo(scoreA);
    });
    return scores;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.score / widget.total;
    final stats = _calculateStats();
    final sorted = getSortedScores();

    return Scaffold(
      appBar: AppBar(title: const Text("🎓 Fin du Quiz")),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (ratio >= 0.2)
                      Lottie.asset(
                        'assets/animations/celebrate.json',
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    const SizedBox(height: 20),
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
                    ...stats.entries.map((entry) {
                      final diff = entry.key;
                      final correct = entry.value["correct"]!;
                      final total = entry.value["total"]!;
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.bar_chart),
                          title: Text("Difficulté : $diff"),
                          subtitle: Text(
                            "Réponses correctes : $correct / $total",
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Text(
                      "🎉 Félicitations ! Tu as terminé le cours avec succès.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "📋 Classement complet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...sorted.map((entry) {
                      final isMe = entry['userId'] == widget.userId;
                      return Card(
                        color: isMe ? Colors.deepPurple[50] : null,
                        elevation: isMe ? 4 : 2,
                        child: ListTile(
                          leading: Icon(
                            Icons.emoji_events,
                            color: isMe ? Colors.amber : Colors.grey,
                          ),
                          title: Text(
                            entry['username'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMe ? Colors.deepPurple : Colors.black,
                            ),
                          ),
                          subtitle: Text("ID utilisateur : ${entry['userId']}"),
                          trailing: Text(
                            "${entry['score']} pts",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Retour"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Rejouer"),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final certificateService = CertificateService();
                            final pdfData = await certificateService
                                .generateCertificate(
                                  userId: widget.userId.toString(),
                                  userName: "Wissal",
                                  quizTitle: "Certificat de fin de cours",
                                  score: widget.score,
                                  total: widget.total,
                                );
                            await Printing.layoutPdf(
                              onLayout: (format) async => pdfData,
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Télécharger le certificat"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final scores = getSortedScores();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PodiumPage(topScores: scores),
                              ),
                            );
                          },
                          icon: const Icon(Icons.emoji_events),
                          label: const Text("Voir le podium animé"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
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
