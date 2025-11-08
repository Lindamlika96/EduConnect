import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizPratiquePage extends StatefulWidget {
  final Map<String, dynamic> question;
  final VoidCallback? onNext;
  final int currentIndex;
  final int total;
  final Duration? timerDuration;
  final VoidCallback? onTimeExpired;

  const QuizPratiquePage({
    Key? key,
    required this.question,
    this.onNext,
    this.currentIndex = 0,
    this.total = 1,
    this.timerDuration,
    this.onTimeExpired,
  }) : super(key: key);

  @override
  State<QuizPratiquePage> createState() => _QuizPratiquePageState();
}

class _QuizPratiquePageState extends State<QuizPratiquePage> {
  final TextEditingController _controller = TextEditingController();
  String result = '';
  bool? isCorrect;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.question['code_snippet'] ?? '';
  }

  void resetCode() {
    setState(() {
      _controller.text = widget.question['code_snippet'] ?? '';
      result = '';
      isCorrect = null;
    });
  }

  Future<void> runCode() async {
    setState(() {
      loading = true;
      result = '';
      isCorrect = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://ce.judge0.com/submissions?base64_encoded=false&wait=true',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'language_id': widget.question['language_id'],
          'source_code': _controller.text,
        }),
      );

      final data = jsonDecode(response.body);
      final output =
          data['stdout'] ??
          data['compile_output'] ??
          data['stderr'] ??
          data['message'] ??
          '⚠️ Aucune sortie';
      final expected = widget.question['expected_output']?.trim() ?? '';
      final cleanedOutput = output.trim();

      setState(() {
        result = cleanedOutput.isEmpty
            ? '⚠️ Aucune sortie reçue'
            : cleanedOutput;
        isCorrect =
            cleanedOutput == expected ||
            cleanedOutput == expected.replaceAll('\n', '');
        loading = false;
      });
    } catch (e) {
      setState(() {
        result = '❌ Erreur réseau : $e';
        isCorrect = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz pratique'),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progression + Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (widget.currentIndex + 1) / widget.total,
                    backgroundColor: Colors.grey[300],
                    color: Colors.deepPurple,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                if (widget.timerDuration != null)
                  TweenAnimationBuilder<Duration>(
                    duration: widget.timerDuration!,
                    tween: Tween(
                      begin: widget.timerDuration,
                      end: Duration.zero,
                    ),
                    onEnd: widget.onTimeExpired,
                    builder: (_, value, __) => Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${value.inSeconds}s',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Question ${widget.currentIndex + 1} / ${widget.total}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Question visible
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.deepPurple[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  question['text'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              '🧠 Code à écrire',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Champ de code sombre
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade700),
              ),
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _controller,
                maxLines: 12,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Écris ton code ici...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                cursorColor: Colors.greenAccent,
              ),
            ),

            const SizedBox(height: 16),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : runCode,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Compiler / Exécuter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: resetCode,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réinitialiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Résultat
            if (loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              const Text(
                '💬 Sortie du compilateur :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Text(
                  result,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (isCorrect != null)
                Text(
                  isCorrect == true
                      ? '✅ Bonne réponse !'
                      : '❌ Mauvaise réponse',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCorrect == true
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              if (isCorrect == false && question['expected_output'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '🎯 Sortie attendue :\n${question['expected_output']}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              if (isCorrect == true && widget.onNext != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: widget.onNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Suivant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
