/// DTO mappé directement sur la table `question`.
class QuestionDto {
  final int id;
  final int quizId;
  final String text;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final int correctIndex;
  final String? explanation;
  final String difficulty;
  final String? codeSnippet;
  final String? expectedOutput;
  final int? languageId;

  QuestionDto({
    required this.id,
    required this.quizId,
    required this.text,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctIndex,
    this.explanation,
    required this.difficulty,
    this.codeSnippet,
    this.expectedOutput,
    this.languageId,
  });

  factory QuestionDto.fromMap(Map<String, Object?> m) => QuestionDto(
    id: m['id'] as int,
    quizId: m['quiz_id'] as int,
    text: m['text'] as String,
    optionA: m['option_a'] as String,
    optionB: m['option_b'] as String,
    optionC: m['option_c'] as String,
    optionD: m['option_d'] as String,
    correctIndex: m['correct_index'] as int,
    explanation: m['explanation'] as String?,
    difficulty: m['difficulty'] as String? ?? 'facile',
    codeSnippet: m['code_snippet'] as String?,
    expectedOutput: m['expected_output'] as String?,
    languageId: m['language_id'] as int?,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'quiz_id': quizId,
    'text': text,
    'option_a': optionA,
    'option_b': optionB,
    'option_c': optionC,
    'option_d': optionD,
    'correct_index': correctIndex,
    'explanation': explanation,
    'difficulty': difficulty,
  };
}
