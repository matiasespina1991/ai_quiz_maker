class QuizModel {
  final String question;
  final Map<String, String> options;
  final String correctAnswer;
  final String trivia;

  QuizModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.trivia,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'],
      options: Map<String, String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      trivia: json['trivia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'trivia': trivia,
    };
  }
}

class GeminiQuizResponse {
  final List<QuizModel> quiz;

  GeminiQuizResponse({required this.quiz});

  factory GeminiQuizResponse.fromJson(Map<String, dynamic> json) {
    var list = json['quiz'] as List;
    List<QuizModel> quizList = list.map((i) => QuizModel.fromJson(i)).toList();

    return GeminiQuizResponse(quiz: quizList);
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz': quiz.map((q) => q.toJson()).toList(),
    };
  }
}
