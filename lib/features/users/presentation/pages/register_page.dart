import 'package:flutter/material.dart';
import '../../di.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _controller = provideUserController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _agreeTerms = false;

  Future<void> _register() async {
    if (_password.text.trim() != _confirmPassword.text.trim()) {
      setState(() => _message = "❌ Les mots de passe ne correspondent pas.");
      return;
    }
    if (!_agreeTerms) {
      setState(() => _message = "❌ Vous devez accepter les conditions d’utilisation.");
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await _controller.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      setState(() => _message = "✅ Compte créé avec succès !");
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
            // 🎨 Header dégradé
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

                  const Text("Nom complet", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Votre nom complet",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _email,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "exemple@mail.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Mot de passe", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "********",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Confirmer le mot de passe",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_person_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "********",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  // ✅ Case à cocher
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

                  // 🚀 Bouton d’inscription
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
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Créer un compte",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔁 Lien retour vers connexion
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
                              color: Color(0xFF0066FF), fontWeight: FontWeight.w600),
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
}
