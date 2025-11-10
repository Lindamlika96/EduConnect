import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:educonnect_mobile/core/db/app_database.dart';

class PasswordResetController {
  // ⚙️ Lien vers ton backend Node.js
  // 💡 10.0.2.2 = localhost depuis l'émulateur Android
  static const String baseUrl = "http://10.0.2.2:3000";

  // 1️⃣ Envoi du code de vérification
  Future<String> sendResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return "Code envoyé à $email ✅";
      } else {
        final data = jsonDecode(response.body);
        return "Erreur : ${data['message'] ?? 'Échec de l’envoi'}";
      }
    } catch (e) {
      return "Erreur de connexion au serveur : $e";
    }
  }

  // 2️⃣ Vérification du code reçu par e-mail
  Future<String> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/verify-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "code": code}),
      );

      if (response.statusCode == 200) {
        return "Code valide ✅";
      } else {
        return "Code invalide ❌";
      }
    } catch (e) {
      return "Erreur de connexion au serveur : $e";
    }
  }

  // 3️⃣ Réinitialisation du mot de passe
  Future<String> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );

      if (response.statusCode == 200) {
        // ✅ Met à jour aussi le mot de passe dans la base locale SQLite
        final updated = await AppDatabase.updateUserPassword(email, newPassword);

        if (updated == 1) {
          return "Mot de passe réinitialisé avec succès ✅";
        } else {
          return "Utilisateur introuvable dans la base locale ❌";
        }
      } else {
        return "Échec de la réinitialisation ❌";
      }
    } catch (e) {
      return "Erreur de connexion au serveur : $e";
    }
  }
}
