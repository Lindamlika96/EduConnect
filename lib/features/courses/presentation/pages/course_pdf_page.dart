import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class CoursePdfPage extends StatefulWidget {
  final String path;        // ex: 'assets/pdfs/algo.pdf'
  final int courseId;       // pour le bouton "Passer au quiz"
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
      _controller = PdfControllerPinch(document: PdfDocument.openAsset(widget.path));
    } else {
      _controller = PdfControllerPinch(document: PdfDocument.openFile(widget.path));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToQuiz() {
    // TODO: remplacer par ta vraie navigation quiz
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: Naviguer vers le quiz')),
    );
  }

  void _showSummary() {
    // TODO: brancher Gemini plus tard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Résumé IA (à venir)')),
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
                child: OutlinedButton(
                  onPressed: _showSummary,
                  child: const Text('Voir le résumé'),
                ),
              ),
              const SizedBox(width: 12),
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
