import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/db/app_database.dart';
import '../../di.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/notifiers.dart'; // 👈 import ajouté ici
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    // 👂 Rafraîchir automatiquement si le profil est mis à jour ailleurs
    profileUpdatedNotifier.addListener(_loadUserInfo);
  }

  /// 🔹 Charger les infos utilisateur depuis SQLite
  Future<void> _loadUserInfo() async {
    final db = await AppDatabase.database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [widget.email]);
    if (result.isNotEmpty) {
      setState(() => userData = result.first);
    }
  }

  @override
  void dispose() {
    // 🔕 Supprimer l’écouteur pour éviter les fuites mémoire
    profileUpdatedNotifier.removeListener(_loadUserInfo);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = provideUserController();

    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = userData!['name'] ?? "Utilisateur";
    final email = userData!['email'] ?? widget.email;
    final university = userData!['university'] ?? "Non renseignée";
    final role = userData!['role'] ?? "Étudiant";
    final age = userData!['age']?.toString() ?? "-";
    final gender = userData!['gender'] ?? "-";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🧑‍🎓 Avatar
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🧾 Informations utilisateur
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            _buildInfoRow("Université", university),
            _buildInfoRow("Rôle", role),
            _buildInfoRow("Âge", age),
            _buildInfoRow("Genre", gender),

            const Divider(height: 30),
            _buildDateRow("Créé le", userData!['created_at']),
            _buildDateRow("Mis à jour le", userData!['updated_at']),

            const SizedBox(height: 40),

            // 🔒 Bouton Déconnexion
            ElevatedButton.icon(
              onPressed: () async {
                await controller.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Ligne d’infos (libellé + valeur)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// 🔹 Ligne de dates formatées
  Widget _buildDateRow(String label, dynamic timestamp) {
    if (timestamp == null) return const SizedBox.shrink();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formatted =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    return _buildInfoRow(label, formatted);
  }
}
