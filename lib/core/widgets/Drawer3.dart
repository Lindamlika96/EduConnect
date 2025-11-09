import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/db/app_database.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/profile_page.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/edit_profile_page.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/settings_page.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/login_page.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/notifiers.dart'; // ✅ pour écouter les mises à jour

class DrawerNavigationPage extends StatefulWidget {
  final String email;
  const DrawerNavigationPage({super.key, required this.email});

  @override
  State<DrawerNavigationPage> createState() => _DrawerNavigationPageState();
}

class _DrawerNavigationPageState extends State<DrawerNavigationPage> {
  int _selectedIndex = 0;

  final List<String> _titles = ["Profil", "Modifier profil", "Paramètres"];

  @override
  void initState() {
    super.initState();

    // 🔄 Écoute si le profil a été mis à jour → revient automatiquement sur la page Profil
    profileUpdatedNotifier.addListener(() {
      setState(() {
        _selectedIndex = 0; // revient sur "Profil"
      });
    });
  }

  @override
  void dispose() {
    profileUpdatedNotifier.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      /// 🧩 Page 1 : Profil
      ProfilePage(email: widget.email),

      /// 🧩 Page 2 : Modifier le profil
      FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return EditProfilePage(userData: snapshot.data!);
        },
      ),

      /// 🧩 Page 3 : Paramètres
      const SettingsPage2(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFF0066FF),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0066FF)),
              child: Center(
                child: Text(
                  "EduConnect",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),

            /// 🌐 Navigation vers Profil
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () => _onSelectPage(0),
            ),

            /// ✏️ Navigation vers Modifier le profil
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: const Text('Modifier profil'),
              onTap: () => _onSelectPage(1),
            ),

            /// ⚙️ Navigation vers Paramètres
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Paramètres'),
              onTap: () => _onSelectPage(2),
            ),

            const Divider(),

            /// 🚪 Déconnexion
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                await SessionManager.clearSession();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
    );
  }

  /// 🔹 Récupération des données utilisateur à jour
  Future<Map<String, dynamic>?> _getUserData() async {
    final db = await AppDatabase.database;
    final result =
    await db.query('users', where: 'email = ?', whereArgs: [widget.email]);
    return result.isNotEmpty ? result.first : null;
  }

  /// 🔹 Changement de page après clic sur le menu
  void _onSelectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // ferme le Drawer après clic
  }
}
