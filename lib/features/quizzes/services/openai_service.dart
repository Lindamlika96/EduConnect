import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey =
      "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";

  Future<String> getExplanation(
    String question,
    String userAnswer,
    String correctAnswer,
  ) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "Tu es un professeur qui explique les réponses de quiz.",
          },
          {
            "role": "user",
            "content":
                "Question: $question\nRéponse de l'utilisateur: $userAnswer\nBonne réponse: $correctAnswer\nExplique pourquoi.",
          },
        ],
        "max_tokens": 200,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      print("❌ Erreur OpenAI (getExplanation): ${response.body}");
      throw Exception("Erreur API OpenAI: ${response.body}");
    }
  }

  /// Résumé personnalisé de fin de quiz
  Future<String> generateQuizSummary(
    List<dynamic> questions,
    List<int> userAnswers,
    int score,
    int total,
  ) async {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < questions.length; i++) {
      buffer.writeln("Q${i + 1}: ${questions[i].text}");
      buffer.writeln(
        "Réponse utilisateur: ${userAnswers[i] == -1 ? "Pas de réponse" : questions[i].options[userAnswers[i]]}",
      );
      buffer.writeln(
        "Bonne réponse: ${questions[i].options[questions[i].correctIndex]}",
      );
      buffer.writeln("---");
    }

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "Tu es un coach pédagogique qui analyse les résultats d'un quiz et propose un plan de révision clair et motivant.",
          },
          {
            "role": "user",
            "content":
                "Score: $score/$total\nVoici les réponses:\n${buffer.toString()}\nDonne un résumé personnalisé et un plan de révision.",
          },
        ],
        "max_tokens": 300,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      print("❌ Erreur OpenAI (generateQuizSummary): ${response.body}");
      throw Exception("Erreur API OpenAI: ${response.body}");
    }
  }
}
