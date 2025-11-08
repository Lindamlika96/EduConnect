class Question {
  final int id;
  final int quizId;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String difficulty;
  final String? codeSnippet;
  final String? expectedOutput;
  final int? languageId;

  Question({
    required this.id,
    required this.quizId,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
    required this.difficulty,
    this.codeSnippet,
    this.expectedOutput,
    this.languageId,
  });

  factory Question.fromMap(Map<String, Object?> m) => Question(
    id: m['id'] as int,
    quizId: m['quiz_id'] as int,
    text: m['text'] as String,
    options: [
      m['option_a'] as String,
      m['option_b'] as String,
      m['option_c'] as String,
      m['option_d'] as String,
    ],
    correctIndex: m['correct_index'] as int,
    explanation: m['explanation'] as String?,
    difficulty: m['difficulty'] as String? ?? 'facile',
    codeSnippet: m['code_snippet'] as String?,
    expectedOutput: m['expected_output'] as String?,
    languageId: m['language_id'] as int?,
  );
}
