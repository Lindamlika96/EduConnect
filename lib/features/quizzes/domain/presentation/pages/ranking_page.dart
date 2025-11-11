import 'package:educonnect_mobile/core/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:educonnect_mobile/features/quizzes/data/dao/quiz_dao_impl.dart';

class ResultEntry {
  final int quizId;
  final int score;
  final int total;
  final DateTime date;

  ResultEntry({
    required this.quizId,
    required this.score,
    required this.total,
    required this.date,
  });

  factory ResultEntry.fromMap(Map<String, Object?> m) => ResultEntry(
    quizId: m['quiz_id'] as int,
    score: m['score'] as int,
    total: m['total'] as int,
    date: DateTime.parse(m['date'] as String),
  );
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late final QuizDaoImpl _dao;
  bool _loading = true;
  List<ResultEntry> _top = [];

  @override
  void initState() {
    super.initState();
    _dao = QuizDaoImpl(AppDatabase.database);
    _load();
  }

  Future<void> _load() async {
    final rows = await _dao.topScores(limit: 10);
    final sorted = rows.map((m) => ResultEntry.fromMap(m)).toList();
    sorted.sort((a, b) {
      final percentA = a.total == 0 ? 0.0 : a.score / a.total;
      final percentB = b.total == 0 ? 0.0 : b.score / b.total;
      return percentB.compareTo(percentA);
    });
    setState(() {
      _top = sorted;
      _loading = false;
    });
  }

  String _trophy(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '🏅';
    }
  }

  Color _barColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPodium(List<ResultEntry> top3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPodiumUser(top3[1], 2, Colors.grey),
        _buildPodiumUser(top3[0], 1, Colors.amber),
        _buildPodiumUser(top3[2], 3, Colors.brown),
      ],
    );
  }

  Widget _buildPodiumUser(ResultEntry r, int rank, Color color) {
    final percent = r.total == 0
        ? 0.0
        : (r.score / r.total * 100).toStringAsFixed(1);
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: rank == 1 ? 36 : 30,
            backgroundColor: color,
            child: Text('$rank', style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 6),
          Text(
            'Quiz ${r.quizId}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('$percent%', style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Classement global'),
        backgroundColor: Colors.indigo,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _top.isEmpty
          ? const Center(child: Text('Aucun score enregistré'))
          : Column(
              children: [
                if (_top.length >= 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _buildPodium(_top.take(3).toList()),
                  ),

                // 📊 Graphique global
                SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              _top.length,
                              (i) => FlSpot(
                                (i + 1).toDouble(),
                                (_top[i].score / _top[i].total) * 100,
                              ),
                            ),
                            isCurved: true,
                            color: Colors.indigo,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🏅 Liste des scores
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _top.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = _top[i];
                      final percent = r.total == 0
                          ? 0.0
                          : (r.score / r.total * 100);
                      final percentText = percent.toStringAsFixed(1);

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Text(
                            _trophy(i),
                            style: const TextStyle(fontSize: 26),
                          ),
                          title: Text(
                            'Quiz ${r.quizId} — $percentText%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Score: ${r.score} / ${r.total}'),
                              Text(
                                'Date: ${r.date.toLocal().toString().split(".").first}',
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: percent / 100,
                                color: _barColor(percent),
                                backgroundColor: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
