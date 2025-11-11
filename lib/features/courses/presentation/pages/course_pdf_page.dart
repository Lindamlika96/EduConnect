// lib/features/courses/presentation/pages/course_pdf_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../controllers/courses_controller.dart';
import 'course_summary_sheet.dart';

// Téléchargement
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';

// ⬇️ Import vers la page Welcome du quiz (ajuste le chemin si besoin)
import 'package:educonnect_mobile/features/quizzes/domain/presentation/pages/welcome_page.dart';
import 'package:educonnect_mobile/features/quizzes/domain/entities/quiz.dart';


class CoursePdfPage extends StatefulWidget {
  final int courseId;
  final String path; // asset ('assets/...') ou file path
  final int userId;

  const CoursePdfPage({
    super.key,
    required this.courseId,
    required this.path,
    required this.userId,
  });

  @override
  State<CoursePdfPage> createState() => _CoursePdfPageState();
}

class _CoursePdfPageState extends State<CoursePdfPage>
    with SingleTickerProviderStateMixin {
  late CoursesController _ctrl;

  PdfControllerPinch? _pdf;
  int _totalPages = 1;
  int _currentPage = 1;

  double _lastPercent = 0.0;
  double _initialPercent = 0.0;
  int _maxPageSeen = 1;

  bool _ready = false;
  bool _completionDialogShownNow = false;
  bool _openingSummary = false;

  bool get _canStartQuiz => _lastPercent >= 100.0;

  late AnimationController _popupCtrl;
  late CurvedAnimation _popupAnim;

  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _popupCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _popupAnim = CurvedAnimation(parent: _popupCtrl, curve: Curves.easeOutBack);
    _boot();
  }

  Future<void> _boot() async {
    _ctrl = await CoursesController.init();
    await _ctrl.startCourseIfNeeded(widget.userId, widget.courseId);

    _lastPercent = await _ctrl.getUserProgress(widget.userId, widget.courseId);
    _initialPercent = _lastPercent;

    final isAsset = widget.path.startsWith('assets/');
    _pdf = PdfControllerPinch(
      document: isAsset
          ? PdfDocument.openAsset(widget.path)
          : PdfDocument.openFile(widget.path),
      initialPage: 1,
    );

    setState(() => _ready = true);
  }

  int _pageFromPercent() {
    if (_totalPages <= 0) return 1;
    if (_lastPercent <= 0) return 1;
    if (_lastPercent >= 100.0) return _totalPages;
    final raw = (_lastPercent / 100.0) * _totalPages;
    return max(1, min(_totalPages, raw.ceil()));
  }

  void _updateFromPage(int currentPage1) {
    _currentPage = currentPage1;
    _maxPageSeen = max(_maxPageSeen, currentPage1);

    var percent = (_maxPageSeen / (_totalPages > 0 ? _totalPages : 1)) * 100.0;
    if (_maxPageSeen >= _totalPages || percent >= 99.5) {
      percent = 100.0;
    }

    if (percent > _lastPercent + 0.2) {
      _lastPercent = percent;
      _ctrl.updateProgressMax(widget.userId, widget.courseId, _lastPercent);
      setState(() {});
      if (_initialPercent < 100.0 && _lastPercent >= 100.0) {
        _showCompletionOnce();
      }
    } else {
      setState(() {});
    }
  }

  void _showCompletionOnce() {
    if (_completionDialogShownNow) return;
    _completionDialogShownNow = true;

    _popupCtrl.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ScaleTransition(
        scale: _popupAnim,
        child: _CompletionDialogFr(
          onRatedOnly: (stars) async => _ctrl.addQuickRating(
            userId: widget.userId,
            courseId: widget.courseId,
            rating: stars,
          ),
          onRatedWithComment: (stars, comment) async => _ctrl.addQuickRating(
            userId: widget.userId,
            courseId: widget.courseId,
            rating: stars,
            comment: comment,
          ),
        ),
      ),
    ).then((_) {
      if (mounted) _popupCtrl.reverse();
    });
  }

  @override
  void dispose() {
    _popupCtrl.dispose();
    _pdf?.dispose();
    super.dispose();
  }

  // Téléchargement
  String _basename(String path) {
    final i = path.lastIndexOf('/');
    return i >= 0 ? path.substring(i + 1) : path;
  }

  String _ensurePdfExtension(String name) {
    return name.toLowerCase().endsWith('.pdf') ? name : '$name.pdf';
  }

  Future<void> _handleDownloadToPublicDownloads() async {
    if (_downloading) return;
    setState(() => _downloading = true);

    try {
      final bytes = await rootBundle.load(widget.path);
      final data = bytes.buffer.asUint8List();

      final rawName = _basename(widget.path);
      final fileName = _ensurePdfExtension(rawName);

      final String? savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: data,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF enregistré dans Téléchargements : $fileName'),
          action: SnackBarAction(
            label: 'Ouvrir',
            onPressed: () {
              if (savedPath != null && savedPath.isNotEmpty) {
                OpenFilex.open(savedPath);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fichier non disponible à l'ouverture."),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Échec du téléchargement : $e')));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _openSummarySheet() async {
    if (_openingSummary) return;
    setState(() => _openingSummary = true);

    try {
      final isAsset = widget.path.startsWith('assets/');
      if (!isAsset) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Résumé disponible pour les assets.')),
        );
        return;
      }

      final summary = await _ctrl.summarizeCourse(
        courseId: widget.courseId,
        language: 'fr',
        assetPdfPath: widget.path, // requis (non-null)
        forceRefresh: false,
      );

      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => CourseSummarySheet(summary: summary),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Impossible de générer le résumé: $e')));
    } finally {
      if (mounted) setState(() => _openingSummary = false);
    }
  }

  // ⬇️ Navigation vers la page du quiz
  void _goToQuiz() {
    final quiz = Quiz(
      id: widget.courseId,
      courseId: widget.courseId,
      title: 'Quiz du cours #${widget.courseId}',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WelcomePage(
          duration: 10,              // ⏱ durée (minutes)
          questionCount: 10,         // 📋 nombre de questions
          quiz: quiz,                // 🧠 objet Quiz
          userId: widget.userId,     // 👤 identifiant utilisateur
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (!_ready || _pdf == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final alreadyCompletedAtOpen = _initialPercent >= 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF du cours'),
        actions: [
          IconButton(
            tooltip: 'Télécharger',
            onPressed: _downloading ? null : _handleDownloadToPublicDownloads,
            icon: _downloading
                ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 18),
            child: Text(
              '${_lastPercent.toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: ((_lastPercent / 100).clamp(0.0, 1.0)).toDouble(),
          ),
        ),
      ),
      body: PdfViewPinch(
        controller: _pdf!,
        onDocumentLoaded: (doc) {
          _totalPages = doc.pagesCount;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final start = _pageFromPercent();
            _maxPageSeen = start;
            _currentPage = start;
            _pdf!.jumpToPage(start);
            setState(() {});
          });
        },
        onPageChanged: (page) => _updateFromPage(page),
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) => Center(child: Text('Erreur PDF : $error')),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _openSummarySheet,
                child: const Text('Voir résumé'),
              ),
            ),
            const SizedBox(width: 12),
            if (!alreadyCompletedAtOpen)
              Expanded(
                child: ElevatedButton(
                  onPressed: _canStartQuiz ? _goToQuiz : null,
                  child: const Text('Passer au quiz'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------- Dialog FR “Cours terminé” --------------------------- */
class _CompletionDialogFr extends StatefulWidget {
  final Future<void> Function(int stars) onRatedOnly;
  final Future<void> Function(int stars, String comment) onRatedWithComment;

  const _CompletionDialogFr({
    required this.onRatedOnly,
    required this.onRatedWithComment,
  });

  @override
  State<_CompletionDialogFr> createState() => _CompletionDialogFrState();
}

class _CompletionDialogFrState extends State<_CompletionDialogFr> {
  int _stars = 0;

  Future<void> _openCommentSheet() async {
    final ctrl = TextEditingController();
    final comment = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final inset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, inset + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 36,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text('Rédiger un avis', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Votre commentaire (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
                child: const Text('Publier'),
              ),
            ],
          ),
        );
      },
    );
    if (comment != null) {
      await widget.onRatedWithComment(_stars, comment);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Spacer(),
                if (_stars > 0)
                  IconButton(
                    tooltip: 'Fermer',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
              ]),
              Container(
                width: 96,
                height: 96,
                decoration:
                BoxDecoration(color: primary.withOpacity(.12), shape: BoxShape.circle),
                child: Icon(Icons.school, size: 56, color: primary),
              ),
              const SizedBox(height: 12),
              Text('Cours terminé',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  )),
              const SizedBox(height: 6),
              Text('Bravo ! Donnez une note à ce cours.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final idx = i + 1;
                  final filled = idx <= _stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () async {
                        setState(() => _stars = idx);
                        await widget.onRatedOnly(_stars);
                      },
                      child: AnimatedScale(
                        scale: filled ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          size: 36,
                          color: filled ? secondary : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _stars > 0 ? _openCommentSheet : null,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Écrire un avis'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez d’abord une note.\nLe commentaire est optionnel.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
