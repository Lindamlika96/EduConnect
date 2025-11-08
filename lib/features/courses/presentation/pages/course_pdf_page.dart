import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:educonnect_mobile/features/quizzes/domain/entities/quiz.dart';
import 'package:educonnect_mobile/features/quizzes/domain/presentation/pages/welcome_page.dart';
import 'package:educonnect_mobile/features/quizzes/domain/presentation/pages/quiz_pratique_page.dart';
import 'package:educonnect_mobile/features/quizzes/data/pratique_quiz_seeds.dart';

class CoursePdfPage extends StatefulWidget {
  final String path;
  final int courseId;

  const CoursePdfPage({super.key, required this.path, required this.courseId});

  @override
  State<CoursePdfPage> createState() => _CoursePdfPageState();
}

class _CoursePdfPageState extends State<CoursePdfPage> {
  late final PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.path.startsWith('assets/')
        ? PdfControllerPinch(document: PdfDocument.openAsset(widget.path))
        : PdfControllerPinch(document: PdfDocument.openFile(widget.path));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToQuiz() {
    final quiz = Quiz(
      id: widget.courseId,
      title: "Quiz du cours ${widget.courseId}",
      courseId: widget.courseId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WelcomePage(quiz: quiz, questionCount: 10, duration: 5, userId: 1),
      ),
    );
  }

  void _goToQuizAutomatique() {
    final questions = pratiqueQuizSeeds[widget.courseId];
    if (questions != null && questions.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPratiquePage(question: questions.first),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune question pratique disponible')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF du cours')),
      body: PdfViewPinch(controller: _controller),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _goToQuiz,
                  child: const Text('Passer au quiz'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _goToQuizAutomatique,
                  child: const Text('Quiz automatique'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
