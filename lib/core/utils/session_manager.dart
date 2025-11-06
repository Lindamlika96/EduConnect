import 'package:shared_preferences/shared_preferences.dart';

/// Gestionnaire de session utilisateur (login/logout) via SharedPreferences.
class SessionManager {
  static const _keyUserEmail = 'user_email';
  static const _keyIsLoggedIn = 'is_logged_in';

  /// Sauvegarde la session utilisateur
  static Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Récupère l'email de l'utilisateur connecté
  static Future<String?> getSessionEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Vérifie si un utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Supprime la session (déconnexion)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyIsLoggedIn);
  }
}
