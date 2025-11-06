import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class CoursePdfPage extends StatefulWidget {
  final String path; // ex: 'assets/pdfs/demo_course.pdf' OU chemin local
  const CoursePdfPage({super.key, required this.path});

  @override
  State<CoursePdfPage> createState() => _CoursePdfPageState();
}

class _CoursePdfPageState extends State<CoursePdfPage> {
  late final PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    // Si c'est un asset (commence par 'assets/'), on ouvre via openAsset, sinon openFile
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF du cours')),
      body: PdfViewPinch(controller: _controller),
    );
  }
}
