// lib/features/courses/presentation/services/gemini_summary_service.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/course_summary.dart';

/// Service "fake Gemini" côté mobile (asset -> résumé).
/// Tu as déjà la clé .env, ici on lit l'asset et on renvoie un mock structuré.
/// (Tu pourras remplacer l'implémentation par l'appel HTTP réel plus tard.)
class GeminiSummaryService {
  GeminiSummaryService._();

  static Future<GeminiSummaryService> defaultInstance() async {
    // Assure que dotenv est prêt si appelé tôt.
    if (dotenv.isEveryDefined(const ['GEMINI_API_KEY']) == false) {
      // ok, mais on ne crash pas — on peut bosser en mock.
    }
    return GeminiSummaryService._();
  }

  Future<CourseSummary> summarizeAsset({
    required int courseId,
    required String language,
    required String assetPath,
  }) async {
    // Lis le PDF (bytes non utilisés ici, mais on pourrait).
    await rootBundle.load(assetPath);

    final now = DateTime.now().millisecondsSinceEpoch;

    // ⬇️ Résultat simulé/structuré
    return CourseSummary(
      courseId: courseId,
      language: language,
      title: 'Résumé du cours #$courseId',
      overview:
      "Ce cours couvre les bases essentielles. Ce résumé est généré automatiquement.",
      keyPoints: const [
        'Concepts clés expliqués simplement',
        'Exemples pratiques',
        'Bonnes pratiques à retenir',
      ],
      nextSteps: const [
        'Revoir les sections difficiles',
        'Faire le quiz pour valider',
        'Lire la documentation complémentaire',
      ],
      highlights: const [
        'Intro claire',
        'Schémas utiles',
      ],
      outline: const [
        'Chapitre 1: Notions',
        'Chapitre 2: Approfondissement',
        'Chapitre 3: Exemples',
      ],
      keyTerms: const ['Flutter', 'SQLite', 'PDF', 'Gemini'],
      readingTimeMin: 2,
      cacheHit: false,
      generatedAt: now,
    );
  }
}
