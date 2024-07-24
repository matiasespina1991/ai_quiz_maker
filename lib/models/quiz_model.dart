class QuizQuestion {
  final String question;
  final Map<String, String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: Map<String, String>.from(json['options']),
      correctAnswer: json['correct_answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
    };
  }
}

class Quiz {
  final List<QuizQuestion> quiz;

  Quiz({required this.quiz});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var list = json['quiz'] as List;
    List<QuizQuestion> quizList =
        list.map((i) => QuizQuestion.fromJson(i)).toList();

    return Quiz(quiz: quizList);
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz': quiz.map((q) => q.toJson()).toList(),
    };
  }
}
