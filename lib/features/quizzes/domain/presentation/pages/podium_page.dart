import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PodiumPage extends StatelessWidget {
  final List<Map<String, dynamic>> topScores;

  const PodiumPage({super.key, required this.topScores});

  @override
  Widget build(BuildContext context) {
    final top3 = topScores.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text("🏆 Podium", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Lottie.asset('assets/animations/podium.json', height: 140),
              const SizedBox(height: 12),
              Text(
                "Les meilleurs joueurs",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 24),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (top3.length > 1)
                      podiumColumn(
                        username: top3[1]['username'] ?? '',
                        score: top3[1]['score'] ?? 0,
                        color: Colors.blueGrey,
                        platformHeight: 100,
                        avatarSize: 40,
                        rank: "2",
                      ),
                    podiumColumn(
                      username: top3[0]['username'] ?? '',
                      score: top3[0]['score'] ?? 0,
                      color: Colors.blue,
                      platformHeight: 140,
                      avatarSize: 48,
                      rank: "1",
                    ),
                    if (top3.length > 2)
                      podiumColumn(
                        username: top3[2]['username'] ?? '',
                        score: top3[2]['score'] ?? 0,
                        color: Colors.indigo,
                        platformHeight: 80,
                        avatarSize: 36,
                        rank: "3",
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Retour"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget podiumColumn({
    required String username,
    required int score,
    required Color color,
    required double platformHeight,
    required double avatarSize,
    required String rank,
  }) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: avatarSize,
            backgroundColor: color,
            child: Text(
              username.isNotEmpty ? username[0] : '?',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(height: 6),
          Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("$score pts", style: TextStyle(color: Colors.green[700])),
          const SizedBox(height: 8),
          Container(
            height: platformHeight,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              rank,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
