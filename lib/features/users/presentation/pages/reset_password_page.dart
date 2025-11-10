import 'package:flutter/material.dart';
import '../controllers/password_reset_controller.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _controller = PasswordResetController();
  bool _loading = false;
  String _message = '';

  void _resetPassword() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _message = "Les mots de passe ne correspondent pas");
      return;
    }

    setState(() => _loading = true);
    final msg = await _controller.resetPassword(widget.email, _passwordController.text);
    setState(() {
      _loading = false;
      _message = msg;
    });
    if (msg.contains('réinitialisé')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Réinitialiser'),
            ),
            const SizedBox(height: 10),
            Text(_message, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
