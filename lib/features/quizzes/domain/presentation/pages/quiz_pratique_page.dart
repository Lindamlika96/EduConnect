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
      result = 'Running code...';
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
        result +=
            '\n${cleanedOutput.isEmpty ? '⚠️ Aucune sortie reçue' : cleanedOutput}';
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

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Code Editor'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progression + Timer
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (widget.currentIndex + 1) / widget.total,
                    backgroundColor: Colors.grey[800],
                    color: Colors.blueAccent,
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
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),

            // Question
            Text(
              question['text'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Code editor
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                maxLines: 10,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.greenAccent,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Écris ton code ici...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                cursorColor: Colors.greenAccent,
              ),
            ),

            const SizedBox(height: 12),

            // 3 points colorés
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(Colors.red),
                const SizedBox(width: 8),
                _buildDot(Colors.yellow),
                const SizedBox(width: 8),
                _buildDot(Colors.green),
              ],
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : runCode,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: resetCode,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Output console
            if (loading)
              const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              )
            else ...[
              const Text(
                '💬 Output:',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: Text(
                  result.isEmpty ? 'Running code...' : result,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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
