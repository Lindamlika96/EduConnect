// lib/features/courses/presentation/course_pdf_page.dart
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:educonnect_mobile/features/quizzes/domain/entities/quiz.dart';
import 'package:educonnect_mobile/features/quizzes/domain/presentation/pages/welcome_page.dart';

class CoursePdfPage extends StatefulWidget {
  final String path; // ex: 'assets/pdfs/algo.pdf'
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
    if (widget.path.startsWith('assets/')) {
      _controller = PdfControllerPinch(
        document: PdfDocument.openAsset(widget.path),
      );
    } else {
      _controller = PdfControllerPinch(
        document: PdfDocument.openFile(widget.path),
      );
    }
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
        builder: (_) => WelcomePage(quiz: quiz, questionCount: 10, duration: 5),
      ),
    );
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
            ],
          ),
        ),
      ),
    );
  }
}
