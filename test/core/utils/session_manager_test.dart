import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:educonnect_mobile/core/utils/session_manager.dart';

void main() {
  // Groupe de tests dédiés au SessionManager
  group('SessionManager', () {
    // Cette fonction s'exécute avant chaque test pour garantir un environnement propre.
    setUp(() {
      // On initialise SharedPreferences avec des valeurs "mock" (factices).
      // Cela permet d'isoler les tests sans toucher aux vraies données stockées sur l'appareil.
      // L'objet vide {} signifie que chaque test commence avec des préférences vides.
      SharedPreferences.setMockInitialValues({});
    });

    test('doit retourner false pour isLoggedIn et null pour l\'email si aucune session n\'est sauvegardée', () async {
      // **Vérification**
      // On s'assure qu'au départ, personne n'est connecté.
      final isLoggedIn = await SessionManager.isLoggedIn();
      final email = await SessionManager.getSessionEmail();

      // **Assertion**
      // `isLoggedIn` doit être `false` et l'email `null`.
      expect(isLoggedIn, isFalse);
      expect(email, isNull);
    });

    test('doit sauvegarder une session et marquer l\'utilisateur comme connecté', () async {
      // **Préparation**
      // L'email que nous allons simuler.
      const testEmail = 'test@example.com';

      // **Action**
      // On appelle la méthode pour sauvegarder la session.
      await SessionManager.saveSession(testEmail);

      // **Vérification**
      // On récupère l'état de connexion et l'email stocké.
      final isLoggedIn = await SessionManager.isLoggedIn();
      final storedEmail = await SessionManager.getSessionEmail();

      // **Assertion**
      // On vérifie que `isLoggedIn` est bien `true` et que l'email correspond.
      expect(isLoggedIn, isTrue);
      expect(storedEmail, testEmail);
    });

    test('doit supprimer la session et marquer l\'utilisateur comme déconnecté', () async {
      // **Préparation**
      // On commence par connecter un utilisateur pour avoir une session à supprimer.
      const testEmail = 'test@example.com';
      await SessionManager.saveSession(testEmail);

      // Vérification initiale (optionnelle mais recommandée)
      expect(await SessionManager.isLoggedIn(), isTrue, reason: "L\'utilisateur devrait être connecté avant de tester la déconnexion.");

      // **Action**
      // On appelle la méthode pour effacer la session.
      await SessionManager.clearSession();

      // **Vérification**
      // On récupère à nouveau l'état de connexion et l'email.
      final isLoggedIn = await SessionManager.isLoggedIn();
      final storedEmail = await SessionManager.getSessionEmail();

      // **Assertion**
      // On s'assure que l'utilisateur n'est plus connecté et que l'email a été effacé.
      expect(isLoggedIn, isFalse);
      expect(storedEmail, isNull);
    });
  });
}
