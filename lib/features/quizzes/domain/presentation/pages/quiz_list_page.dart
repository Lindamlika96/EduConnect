import 'package:educonnect_mobile/core/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:educonnect_mobile/features/quizzes/domain/entities/quiz.dart';
import 'package:educonnect_mobile/features/quizzes/domain/usecases/get_quiz_usecase.dart';
import 'package:educonnect_mobile/features/quizzes/data/dao/quiz_dao_impl.dart';
import 'package:educonnect_mobile/features/quizzes/data/repository/quiz_repository_impl.dart';

import 'ranking_page.dart';
import 'quiz_play_page.dart';

class QuizListPage extends StatefulWidget {
  final int? courseId;

  const QuizListPage({super.key, this.courseId});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  late final GetQuizUseCase _getQuizUseCase;
  List<Quiz> quizzes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final dao = QuizDaoImpl(AppDatabase.database);
    final repo = QuizRepositoryImpl(dao);
    _getQuizUseCase = GetQuizUseCase(repo);
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final data = await _getQuizUseCase(widget.courseId ?? 0);
    setState(() {
      quizzes = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseId == null
              ? "Tous les Quiz"
              : "Quiz du cours #${widget.courseId}",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RankingPage()),
            ),
          ),
          // ✅ Bouton DebugDatabase supprimé
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
          ? const Center(child: Text("Aucun quiz disponible"))
          : ListView.builder(
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return Card(
                  child: ListTile(
                    title: Text(quiz.title),
                    subtitle: Text("Quiz #${quiz.id}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPlayPage(quiz: quiz),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
