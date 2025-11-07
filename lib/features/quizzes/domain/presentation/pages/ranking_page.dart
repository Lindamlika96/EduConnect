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
        return '${index + 1}';
    }
  }

  Color? _highlightColor(int index) {
    if (index == 0) return Colors.amber[100];
    if (index == 1) return Colors.grey[200];
    if (index == 2) return Colors.brown[100];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classement global')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _top.isEmpty
          ? const Center(child: Text('Aucun score enregistré'))
          : Column(
              children: [
                // 📊 Graphique global
                if (_top.isNotEmpty)
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
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 🏆 Liste des scores
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _top.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = _top[i];
                      final percent = (r.score / r.total * 100).toStringAsFixed(
                        1,
                      );
                      return Card(
                        color: _highlightColor(i),
                        child: ListTile(
                          leading: Text(
                            _trophy(i),
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(
                            'Score: ${r.score} / ${r.total}  ($percent %)',
                          ),
                          subtitle: Text(
                            'Quiz ${r.quizId} — ${r.date.toLocal().toString().split(".").first}',
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
