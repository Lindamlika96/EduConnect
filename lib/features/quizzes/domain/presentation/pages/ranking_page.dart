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
    setState(() {
      _top = rows.map((m) => ResultEntry.fromMap(m)).toList();
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
                      final percent = (r.score / r.total * 100);
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
