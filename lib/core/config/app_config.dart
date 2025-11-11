// lib/core/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Fournit les valeurs de configuration de l’app (API keys, flags…)
class AppConfig {
  AppConfig._();

  /// Clé Gemini lue depuis .env (ne pas committer .env)
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY manquante. Ajoute-la dans un fichier .env à la racine.',
      );
    }
    return key;
  }

  /// Modèle Gemini utilisé pour les résumés.
  static const String geminiModel = 'gemini-1.5-flash';
}
