import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/db/app_database.dart';
import 'package:educonnect_mobile/core/utils/notifiers.dart'; // 🔔 notification de mise à jour

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onProfileUpdated; // callback optionnel pour mise à jour

  const EditProfilePage({
    super.key,
    required this.userData,
    this.onProfileUpdated,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _universityController;
  late TextEditingController _passwordController;
  late TextEditingController _ageController;

  String _gender = 'Homme';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _universityController =
        TextEditingController(text: widget.userData['university']);
    _passwordController =
        TextEditingController(text: widget.userData['password']);
    _ageController =
        TextEditingController(text: widget.userData['age']?.toString() ?? '');
    _gender = (widget.userData['gender'] == 'Femme') ? 'Femme' : 'Homme';
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return "-";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    final db = await AppDatabase.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final int? age = int.tryParse(_ageController.text.trim());

    await db.update(
      'users',
      {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'university': _universityController.text.trim(),
        'password': _passwordController.text.trim(),
        'age': age,
        'gender': _gender,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [widget.userData['id']],
    );

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profil mis à jour avec succès !")),
      );

      // 🔄 Notifie la mise à jour (écoutée par DrawerNavigationPage)
      profileUpdatedNotifier.value = !profileUpdatedNotifier.value;

      // ✅ Rafraîchit le profil si callback fourni
      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!();
      }

      // 🔙 Attendre légèrement avant de revenir à la page précédente
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = _formatDate(widget.userData['created_at']);
    final updatedAt = _formatDate(widget.userData['updated_at']);

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le profil")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🧾 Champs de saisie
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nom complet"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _universityController,
                decoration: const InputDecoration(labelText: "Université"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mot de passe"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Âge"),
              ),
              const SizedBox(height: 15),
              InputDecorator(
                decoration: const InputDecoration(labelText: "Genre"),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                      DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                    ],
                    onChanged: (val) {
                      setState(() => _gender = val ?? 'Homme');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 🕒 Informations de création/modification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Créé le : $createdAt",
                      style: const TextStyle(color: Colors.grey)),
                  Text("Modifié le : $updatedAt",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 30),

              // 💾 Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveProfile,
                  icon: const Icon(Icons.save),
                  label: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enregistrer"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF0066FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
