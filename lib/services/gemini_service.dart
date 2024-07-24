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

  Future<Quiz> generateQuiz({
    required String topic,
    required String difficulty,
  }) async {
    final prompt = '''
    Generate a JSON object with 5 multiple-choice questions about the topic "${topic}". The questions should be of "${difficulty}" difficulty. Each question should have four answer options labeled as A, B, C, and D, and include the correct answer. THE QUESTIONS AND ANSWERS MUST BE IN SPANISH, THIS IS AN APP ORIENTED TO SPANISH-SPEAKERS. Please dont use any code character that could break the json like a "". The JSON structure should look like this:
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
      return Quiz.fromJson(jsonDecode(jsonResponse));
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
