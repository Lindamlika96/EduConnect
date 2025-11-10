import 'package:flutter/material.dart';
import '../../di.dart';
import 'login_page.dart';

class RegisterProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const RegisterProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterProfilePage> createState() => _RegisterProfilePageState();
}

class _RegisterProfilePageState extends State<RegisterProfilePage> {
  final _controller = provideUserController();
  final _university = TextEditingController();
  final _age = TextEditingController();
  String? _gender;
  String? _role;
  bool _loading = false;
  String? _message;

  Future<void> _completeRegistration() async {
    if (_gender == null || _role == null || _university.text.isEmpty) {
      setState(() => _message = "⚠️ Merci de remplir tous les champs.");
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await _controller.register(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        university: _university.text.trim(),
        role: _role!,
        age: int.tryParse(_age.text) ?? 0,
        gender: _gender!,
      );

      setState(() => _message = "✅ Compte créé avec succès !");
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      setState(() => _message = "Erreur : ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🟣 Header avec barre de progression
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8A56FF), Color(0xFF0066FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Compléter le profil 👤",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 40,
                  right: 40,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: 1.0, // 100%
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Étape 2 sur 2 : Informations personnelles",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_message != null)
                    Text(
                      _message!,
                      style: TextStyle(
                        color: _message!.startsWith('✅') ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 20),

                  _buildTextField("Université", _university, Icons.school, "Votre université"),
                  const SizedBox(height: 20),

                  _buildTextField("Âge", _age, Icons.cake_outlined, "Ex: 21", type: TextInputType.number),
                  const SizedBox(height: 20),

                  const Text("Genre", style: TextStyle(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Homme"),
                          value: "Homme",
                          groupValue: _gender,
                          onChanged: (val) => setState(() => _gender = val),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Femme"),
                          value: "Femme",
                          groupValue: _gender,
                          onChanged: (val) => setState(() => _gender = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text("Rôle", style: TextStyle(fontWeight: FontWeight.w600)),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: "Étudiant", child: Text("Étudiant")),
                      DropdownMenuItem(value: "Professeur", child: Text("Professeur")),
                    ],
                    decoration: _inputDecoration("Choisissez un rôle", Icons.work_outline),
                    onChanged: (val) => setState(() => _role = val),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A56FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _loading ? null : _completeRegistration,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Créer mon compte ✅",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String hint,
      {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
