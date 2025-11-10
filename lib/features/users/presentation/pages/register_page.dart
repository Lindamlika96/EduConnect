import 'package:flutter/material.dart';
import 'register_profile_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _agreeTerms = false;
  String? _message;

  void _goToProfileStep() {
    if (_password.text.trim() != _confirmPassword.text.trim()) {
      setState(() => _message = "❌ Les mots de passe ne correspondent pas.");
      return;
    }
    if (!_agreeTerms) {
      setState(() => _message = "❌ Vous devez accepter les conditions d’utilisation.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterProfilePage(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text.trim(),
        ),
      ),
    );
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
                  height: 230,
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
                      "Créer un compte ✨",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                // Barre de progression
                Positioned(
                  bottom: 20,
                  left: 40,
                  right: 40,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: 0.5, // 50%
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Étape 1 sur 2 : Informations du compte",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.startsWith('✅') ? Colors.green : Colors.red,
                        ),
                      ),
                    ),

                  _buildTextField("Nom complet", _name, Icons.person_outline, "Votre nom complet"),
                  const SizedBox(height: 20),
                  _buildTextField("Email", _email, Icons.email_outlined, "exemple@mail.com"),
                  const SizedBox(height: 20),
                  _buildTextField("Mot de passe", _password, Icons.lock_outline, "********", obscure: true),
                  const SizedBox(height: 20),
                  _buildTextField("Confirmer le mot de passe", _confirmPassword,
                      Icons.lock_person_outlined, "********", obscure: true),

                  Row(
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        onChanged: (val) => setState(() => _agreeTerms = val!),
                      ),
                      const Expanded(
                        child: Text(
                          "J’accepte les conditions générales d’utilisation",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🚀 Bouton suivant
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
                      onPressed: _goToProfileStep,
                      child: const Text(
                        "Suivant ➡️",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Déjà un compte ? "),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            color: Color(0xFF0066FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String hint, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
