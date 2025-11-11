import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// =============================================================
///  EventSuccessController — Évaluation locale du succès d’un événement
/// =============================================================
/// ⚙️ Ne dépend d’aucune API : tout est calculé directement dans l’app mobile.
/// Les poids proviennent de metrics_best_model.json (si dispo).
class EventSuccessController extends ChangeNotifier {
  bool loading = false;
  String? error;
  double? lastScore;   // entre 0 et 1
  String? lastAdvice;  // "Succès faible/moyen/élevé"
  Map<String, dynamic>? _metrics; // pour future extension (JSON)

  /// Charge le fichier JSON une seule fois (optionnel)
  Future<void> ensureLoaded() async {
    if (_metrics != null) return;
    try {
      final raw = await rootBundle.loadString('assets/ml/metrics_best_model.json');
      _metrics = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      _metrics = null; // non bloquant
    }
  }

  /// Calcule la probabilité de succès localement (sans API)
  Future<void> evaluate({
    required String localisation,
    required int dureeJours,
    required int nombrePlaces,
    required String niveauImportance,
    required String niveauExigeance,
    required String formateur,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await ensureLoaded();

      // calcul local
      final prob = _localHeuristicPredict(
        localisation: localisation,
        dureeJours: dureeJours,
        nombrePlaces: nombrePlaces,
        niveauImportance: niveauImportance,
        niveauExigeance: niveauExigeance,
        formateur: formateur,
      );

      lastScore = prob;
      lastAdvice = _labelFor(prob);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Renvoie une étiquette texte selon la probabilité
  String _labelFor(double p) {
    if (p >= 0.75) return 'Succès élevé';
    if (p >= 0.50) return 'Succès moyen';
    return 'Succès faible';
  }

  /// Calcul heuristique (dérivé du modèle ML mais local)
  double _localHeuristicPredict({
    required String localisation,
    required int dureeJours,
    required int nombrePlaces,
    required String niveauImportance,
    required String niveauExigeance,
    required String formateur,
  }) {
    double score = 0.0;

    const impMap = {
      'Très peu': 0.0,
      'Peu': 0.1,
      'Moyen': 0.25,
      'Important': 0.45,
      'Très important': 0.60,
      'Événement extraordinaire': 0.75,
    };
    const exiMap = {
      'Très peu': 0.05,
      'Peu': 0.1,
      'Moyen': 0.2,
      'Important': 0.3,
      'Très important': 0.4,
      'Extraordinaire': 0.5,
    };
    const formMap = {
      'Élève Université': 0.1,
      'Étudiant bénévole': 0.15,
      'Professeur Université': 0.35,
      'Expert': 0.5,
      'PDG': 0.55,
    };
    const locBoost = {
      'Tunis': 0.15,
      'Sfax': 0.10,
      'Sousse': 0.08,
      'Kairouan': 0.05,
      'Bizerte': 0.06,
      'Gabès': 0.05,
      'Ariana': 0.08,
    };

    score += (impMap[niveauImportance] ?? 0.2);
    score += (exiMap[niveauExigeance] ?? 0.2);
    score += (formMap[formateur] ?? 0.2);

    // nombre de places
    final sPlaces = (nombrePlaces <= 0)
        ? 0.0
        : (nombrePlaces >= 100 ? 1.0 : nombrePlaces / 100.0) * 0.25;
    score += sPlaces;

    // durée (plus court = plus dynamique)
    final sDuree = (dureeJours <= 0)
        ? 0.0
        : (dureeJours == 1 ? 0.2 : (dureeJours <= 3 ? 0.15 : 0.05));
    score += sDuree;

    score += (locBoost[localisation] ?? 0.05);

    // normalisation
    score = score / 2.2;
    return score.clamp(0.0, 1.0);
  }
}
