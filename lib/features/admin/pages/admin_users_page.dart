import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/db/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/login_page.dart';
import '../../../../core/utils/session_manager.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<Map<String, dynamic>> users = [];

  // 🔹 Variables du mini-dashboard
  int usersCount = 0;
  int coursesCount = 0;
  int eventsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// ================================
  /// 🔹 Chargement des données globales
  /// ================================
  Future<void> _loadDashboardData() async {
    final db = await AppDatabase.database;
    final resultUsers = await db.query('users');
    final resultCourses = await db.query('course');
    final resultEvents = await db.query('events');

    setState(() {
      users = resultUsers;
      usersCount = resultUsers.length;
      coursesCount = resultCourses.length;
      eventsCount = resultEvents.length;
    });
  }

  /// 🔹 Supprimer un utilisateur
  Future<void> _deleteUser(int id) async {
    final db = await AppDatabase.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    _loadDashboardData();
  }

  /// 🔹 Ajouter ou modifier un utilisateur
  Future<void> _addOrEditUser({Map<String, dynamic>? user}) async {
    final nameController = TextEditingController(text: user?['name']);
    final emailController = TextEditingController(text: user?['email']);
    final passwordController = TextEditingController(text: user?['password']);
    final roleController = TextEditingController(text: user?['role'] ?? 'Étudiant');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user == null ? "➕ Ajouter un utilisateur" : "✏️ Modifier un utilisateur"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nom")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Mot de passe")),
              TextField(controller: roleController, decoration: const InputDecoration(labelText: "Rôle (Étudiant / Professeur / Admin)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final db = await AppDatabase.database;
              final now = DateTime.now().millisecondsSinceEpoch;

              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires.")),
                );
                return;
              }

              final data = {
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
                'password': passwordController.text.trim(),
                'role': roleController.text.trim(),
                'created_at': user?['created_at'] ?? now,
                'updated_at': now,
              };

              if (user == null) {
                await db.insert('users', data, conflictAlgorithm: ConflictAlgorithm.replace);
              } else {
                await db.update('users', data, where: 'id = ?', whereArgs: [user['id']]);
              }

              Navigator.pop(context);
              _loadDashboardData();
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  /// ================================
  /// 🔹 Widget carte de statistiques
  /// ================================
  Widget _buildStatCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Déconnexion de l’administrateur
  Future<void> _logoutAdmin() async {
    await SessionManager.clearSession(); // supprime la session
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  /// ================================
  /// 🔹 Interface principale
  /// ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👩‍💼 Admin – Tableau de bord"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDashboardData),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _addOrEditUser()),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logoutAdmin), // 🚪 Déconnexion
        ],
      ),
      body: users.isEmpty
          ? const Center(child: Text("Aucun utilisateur enregistré"))
          : Column(
        children: [
          const SizedBox(height: 10),

          /// 🧭 Section Dashboard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("Utilisateurs", usersCount, Colors.blue),
              _buildStatCard("Cours", coursesCount, Colors.green),
              _buildStatCard("Événements", eventsCount, Colors.orange),
            ],
          ),

          const Divider(thickness: 1, height: 30),

          /// 📋 Liste des utilisateurs
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                final name = (u['name'] ?? '').trim();
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        initial,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    title: Text(name.isNotEmpty ? name : 'Utilisateur inconnu'),
                    subtitle: Text("${u['email'] ?? 'email inconnu'} (${u['role'] ?? 'N/A'})"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _addOrEditUser(user: u),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteUser(u['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
