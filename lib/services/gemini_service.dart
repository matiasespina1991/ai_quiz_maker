// import 'package:firebase_vertexai/firebase_vertexai.dart';
// import 'package:flutter/cupertino.dart';
//
// import '../services/error_reporting_service.dart';
//
// class GeminiService {
//   final model = FirebaseVertexAI.instance.generativeModel(
//     model: 'gemini-1.5-pro-001',
//   );
//
//   String _extractJson(String responseText) {
//     final regex = RegExp(r'\{.*\}', dotAll: true);
//     final match = regex.firstMatch(responseText);
//     if (match != null) {
//       return match.group(0) ?? '';
//     } else {
//       return '';
//     }
//   }
//
//   Future<String> improveTranscription(String text) async {
//     final prompt = '''
//     Input Text: $text
//
//     Instructions for the AI: This text has been transcribed from an audio input and may contain inaccuracies in punctuation and wording. Your task is to improve the text by correcting any errors and making it more coherent and cohesive. Ensure that the improved text is a faithful representation of what the user intended to say, and correct words if necessary to maintain coherence. And ALWAYS return the text in its original language. If the text is empty or contains no errors, return the original text as is. Never reply anything with your own words or opinions.
//
//     Expected Output: The improved text, well-punctuated and corrected, in a readable format.
//     ''';
//
//     try {
//       final response = await model.generateContent([Content.text(prompt)]);
//
//       if (response.text?.isEmpty ?? true) {
//         return text;
//       }
//
//       return response.text ?? text;
//     } catch (e) {
//       return text;
//     }
//   }
//
//   Future<String> generateAutoWriteText({required String language}) async {
//     String textLanguage = 'english';
//
//     if (language == 'es') {
//       textLanguage = 'spanish';
//     } else if (language == 'fr') {
//       textLanguage = 'french';
//     } else if (language == 'de') {
//       textLanguage = 'german';
//     }
//
//     try {
//       final prompt = '''
// Generate a detailed therapy request in ${textLanguage} language for an individual looking for a therapist. The request should include personal details (dont write '[your age] [your gender identity] [your race/ethnicity]' don't EVER use brackets, you invent the name and details), specific challenges, and preferences for the therapist and therapy methods. The text should be around not more than 200 characters. You should only write one, not two or three.
//
// Example: My name is John Doe, and I am a black individual living in Germany. I've been struggling to find a therapist who understands my cultural background and the unique challenges I face. Specifically, I am looking for a black therapist who can relate to my experiences and provide culturally sensitive therapy. I've encountered issues such as racial discrimination, microaggressions, and feelings of isolation. Additionally, I have faced difficulties with anxiety, low self-esteem, and trust issues stemming from past relationships. I am currently very heartbroken due to a recent breakup with my ex, which has exacerbated my feelings of depression and loneliness. Despite my efforts, it has been incredibly difficult to find a black therapist in Germany who meets these criteria.
//
// I have also been experiencing significant stress and burnout from work, which has affected my overall well-being and ability to maintain a healthy work-life balance. My sleep patterns are irregular, often suffering from insomnia, which further impacts my mental health. I've also struggled with body image issues and disordered eating, leading to a negative self-perception and constant worry about my appearance. These compounded issues have made it challenging to engage in social activities, and I often feel socially anxious and withdrawn.
//
// I am interested in therapies that focus on overcoming racial trauma, building self-esteem, and fostering personal growth. I also have a keen interest in astrology, and I find Jungian analysis very insightful. However, my previous experiences with therapy have left me feeling skeptical and uncertain about the effectiveness of traditional methods. I am looking for a therapist who can offer alternative approaches and help me navigate my interest in non-traditional therapeutic practices. I am particularly drawn to therapy sessions that incorporate elements of spirituality and holistic healing. It is crucial for me to find a therapist who can understand and address my multifaceted challenges and provide a compassionate and effective treatment plan.
//
// There are also certain types of therapists and therapeutic approaches I would like to avoid. For instance, I do not want a therapist who strictly follows cognitive-behavioral therapy (CBT), as I have found it too rigid and not in alignment with my needs. I also prefer not to work with a psychiatrist, as I am not looking for medication-based treatment. I am uncomfortable with therapists who focus heavily on psychoanalysis or Freudian theories, as I do not resonate with those methods. Additionally, I would like to avoid therapists who dismiss or are skeptical of holistic and spiritual approaches to mental health. It is also important to me that my therapist does not have a clinical, impersonal approach, as I value a more empathetic and personalized therapeutic relationship.
//     ''';
//
//       final response = await model.generateContent([Content.text(prompt)]);
//       print('Response: ${response.text}');
//
//       if (response.text?.isEmpty ?? true) {
//         return '';
//       }
//
//       return response.text ?? '';
//     } catch (e, stackTrace) {
//       await ErrorReportingService.reportError(e, stackTrace, null,
//           screen: 'GeminiService',
//           errorLocation: 'getAspectsForTherapist',
//           additionalInfo: []);
//       debugPrint('Error generating auto write text: $e');
//       return '';
//     }
//   }
// }
