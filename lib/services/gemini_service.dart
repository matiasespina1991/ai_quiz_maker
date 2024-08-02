import 'dart:convert';
import 'package:ai_quiz_maker_app/utils/locale/language_code_to_language_name.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/cupertino.dart';
import '../models/quiz_model.dart';
import 'error_reporting_service.dart';

class GeminiService {
  final model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-1.5-pro-001',
  );

  String _extractJson(String responseText) {
    final regex = RegExp(r'\{.*\}', dotAll: true);
    final match = regex.firstMatch(responseText);
    if (match != null) {
      return match.group(0) ?? '';
    } else {
      return '';
    }
  }

  String _sanitizeJson(String jsonResponse) {
    return jsonResponse
        .replaceAll(r'\\\"', r'\"') // Handle escaped quotes
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\n', '\n')
        .replaceAll(r'\\t', '\t')
        .replaceAll(r'\\', ''); // Remove all backslashes
  }

  Future<GeminiQuizResponse> generateQuiz({
    required String? wikipediaArticleContent,
    required String topic,
    required String difficulty,
    required String languageCode,
    required int questionCount,
    Map<String, dynamic>? wikipediaArticleUrl,
  }) async {
    final prompt = '''
Generate a JSON object with $questionCount multiple-choice questions about the topic "$topic". The questions should be of "$difficulty" difficulty and in "${languageCodeToLanguageName(languageCode)}". Each question should have four answer options labeled as A, B, C, and D, and include the correct answer and a short trivia about the correct answer. The trivia should provide an interesting fact or explanation that is not obvious. For example, explain why Paris is called the 'City of Light', give an interesting size comparison for Jupiter, or mention an award the author won. Ensure all text is properly escaped to form a valid JSON. Please don't include double quotes after inside the "quiz" array in the JSON object, except for "quiz", "question", "trivia", "options" an "correct_answer" that should have double quotes, only use single quotes for strings. For example, use 'text' instead of "text". ${wikipediaArticleContent != null ? 'Please help yourself with the following to build the questions and answers using the following content extracted from wikipedia about this topic: <<$wikipediaArticleContent>> [END OF WIKIPEDIA ARTICLE CONTENT]. Dont hesitate to use your knowledge aswell' : ''} The JSON structure should look like this:
{
  "quiz": [
    {
      "question": "Question text",
      "options": {
        "A": "Option 1",
        "B": "Option 2",
        "C": "Option 3",
        "D": "Option 4"
      },
      "correct_answer": "Correct option label",
      "trivia": "Short trivia about the correct answer"
    },
    ...
  ]
}
''';

    print('Prompt: $prompt');
    try {
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text?.isEmpty ?? true) {
        throw Exception('Empty response from AI model');
      }

      final jsonResponse = _extractJson(response.text!);
      final sanitizedJson = _sanitizeJson(jsonResponse);
      return GeminiQuizResponse.fromJson(jsonDecode(sanitizedJson));
    } catch (e, stackTrace) {
      await ErrorReportingService.reportError(e, stackTrace, null,
          screen: 'GeminiService',
          errorLocation: 'generateQuiz',
          additionalInfo: []);
      debugPrint('Error generating quiz: $e');

      rethrow;
    }
  }
}
