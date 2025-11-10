import 'package:flutter/material.dart';
import '../controllers/password_reset_controller.dart';
import 'verify_code_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _controller = PasswordResetController();
  bool _loading = false;
  String _message = '';

  void _sendCode() async {
    setState(() => _loading = true);
    final msg = await _controller.sendResetCode(_emailController.text);
    setState(() {
      _loading = false;
      _message = msg;
    });
    if (msg.contains('Code envoyé')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodePage(email: _emailController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Adresse e-mail'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _sendCode,
              child: const Text('Envoyer le code'),
            ),
            const SizedBox(height: 10),
            Text(_message, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
