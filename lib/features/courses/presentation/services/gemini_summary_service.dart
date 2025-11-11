// lib/features/courses/presentation/services/gemini_summary_service.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/course_summary.dart';

/// Service "fake Gemini" côté mobile (asset -> résumé).
/// Lis un PDF d'assets pour s'assurer que le chemin existe, puis renvoie un
/// résumé structuré. L’appel HTTP réel pourra remplacer cette implémentation.
class GeminiSummaryService {
  GeminiSummaryService._();

  static Future<GeminiSummaryService> defaultInstance() async {
    // On vérifie que l’API key est présente si tu branches un vrai appel plus tard.
    // Ici on ne s’en sert pas (mock), donc pas de crash si absente.
    dotenv.isEveryDefined(const ['GEMINI_API_KEY']);
    return GeminiSummaryService._();
  }

  /// Génère un résumé structuré (mock) à partir d’un PDF embarqué.
  /// - [courseId] et [language] sont propagés pour cohérence.
  /// - [assetPath] doit pointer vers un asset valide (ex: 'assets/pdfs/c1.pdf').
  Future<CourseSummary> summarizeAsset({
    required int courseId,
    required String language,
    required String assetPath,
  }) async {
    // On lit l’asset pour valider le chemin (pas d’utilisation des bytes ici).
    await rootBundle.load(assetPath);

    final now = DateTime.now().millisecondsSinceEpoch;

    // ✅ Résumé structuré (paragraphes séparés par \n\n)
    // ✅ Titre neutre (pas de #id)
    // ✅ Chemin d’apprentissage clair dans nextSteps
    // ✅ Aucun texte d’auto-référence (“généré automatiquement”, etc.)
    return CourseSummary(
      courseId: courseId,
      language: language,
      title: 'Résumé du cours',
      overview: [
        "Ce cours présente les objectifs et le contexte : comprendre les notions fondamentales, savoir quand et pourquoi les utiliser, et identifier les résultats attendus à la fin de la lecture.",
        "Les concepts clés sont introduits progressivement, avec une définition courte et un mini-exemple concret pour chacun. L’accent est mis sur l’intuition (ce que la notion change dans la pratique) et sur les liens entre les concepts.",
        "La démarche proposée suit un fil simple : observer un problème réel, sélectionner la bonne notion, l’appliquer étape par étape, puis vérifier le résultat. Un schéma mental (entrée → traitement → sortie) aide à ne rien oublier.",
        "Erreurs fréquentes à éviter : confondre des notions proches, ignorer les pré-requis, sauter la phase de vérification ou oublier de tester un contre-exemple. Un contrôle rapide (check-list) termine chaque exercice.",
        "À la fin du cours, tu es capable de reconnaître la situation, choisir la bonne approche, l’exécuter proprement et expliquer ton choix. Tu disposes d’exemples types pour t’entraîner et d’une carte mentale des liens entre chapitres."
      ].join('\n\n'),
      keyPoints: const [
        "Comprendre le but de chaque notion et son contexte d’usage",
        "Relier les concepts entre eux via un schéma simple",
        "Appliquer une démarche étape par étape et vérifier le résultat",
        "Identifier les pièges récurrents et les éviter",
        "Savoir expliquer la solution choisie",
      ],
      nextSteps: const [
        "Refaire un exemple guidé en détaillant chaque étape (observer → choisir → appliquer → vérifier).",
        "Appliquer la même notion sur un cas différent (changer les données, garder la méthode).",
        "Rédiger une mini-fiche mémo (définition, quand l’utiliser, pièges, exemple bref).",
        "Tester ses connaissances avec 3 questions ciblées (vrai/faux ou QCM court).",
      ],
      highlights: const [
        "Objectifs clairs",
        "Démarche pas-à-pas",
        "Pièges fréquents",
        "Exemples concrets",
      ],
      outline: const [
        "Introduction et objectifs",
        "Notions fondamentales",
        "Méthode d’application",
        "Pièges & bonnes pratiques",
        "Synthèse et usages",
      ],
      keyTerms: const ['notion', 'méthode', 'exemple', 'validation'],
      readingTimeMin: 2,
      cacheHit: false,
      generatedAt: now,
    );
  }
}
