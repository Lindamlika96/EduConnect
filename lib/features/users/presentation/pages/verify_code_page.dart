import 'package:flutter/material.dart';
import '../controllers/password_reset_controller.dart';
import 'reset_password_page.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _codeController = TextEditingController();
  final _controller = PasswordResetController();
  bool _loading = false;
  String _message = '';

  void _verifyCode() async {
    setState(() => _loading = true);
    final msg = await _controller.verifyCode(widget.email, _codeController.text);
    setState(() {
      _loading = false;
      _message = msg;
    });
    if (msg.contains('Code valide')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: widget.email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérifier le code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code de vérification'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('Vérifier'),
            ),
            const SizedBox(height: 10),
            Text(_message, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
