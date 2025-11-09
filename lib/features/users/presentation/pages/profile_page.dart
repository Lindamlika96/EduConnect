import 'package:flutter/material.dart';
import '../../di.dart';
import 'login_page.dart';
import '../../../admin/pages/admin_users_page.dart'; // ✅ import ajouté pour accéder à la page Admin

class ProfilePage extends StatelessWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final controller = provideUserController();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenue 👋', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),

            // ✅ Bouton pour ouvrir la page Admin
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminUsersPage()),
                );
              },
              child: const Text("👩‍💼 Ouvrir la page Admin"),
            ),

            const SizedBox(height: 20),

            // 🔒 Bouton de déconnexion
            ElevatedButton.icon(
              onPressed: () async {
                await controller.logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
