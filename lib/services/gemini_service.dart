import 'dart:convert';
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
        .replaceAll(r'\\\"', r'\"')
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\n', '\n')
        .replaceAll(r'\\t', '\t');
  }

  Future<GeminiQuizResponse> generateQuiz({
    required String topic,
    required String difficulty,
    required String language,
    required int questionCount,
  }) async {
    final prompt = '''
Generate a JSON object with ${questionCount} multiple-choice questions about the topic "${topic}". The questions should be of "${difficulty}" difficulty and in "${language}". Each question should have four answer options labeled as A, B, C, and D, and include the correct answer. Ensure all text is properly escaped to form a valid JSON. The JSON structure should look like this:
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
      "correct_answer": "Correct option label"
    },
    ...
  ]
}
''';

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
