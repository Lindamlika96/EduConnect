import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../../di.dart';
import 'login_page.dart';


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
