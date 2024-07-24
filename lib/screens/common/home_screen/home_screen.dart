import 'dart:developer';
import 'package:ai_quiz_maker_app/widgets/LoadingCircle/loading_circle.dart';
import 'package:ai_quiz_maker_app/widgets/NotificationSnackbar/notification_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:ai_quiz_maker_app/app_settings/app_general_settings.dart';
import 'package:ai_quiz_maker_app/widgets/AppScaffold/app_scaffold.dart';
import '../../../generated/l10n.dart';
import '../../../providers/providers_all.dart';
import '../../../services/gemini_service.dart';
import '../../../utils/ui/is_dark_mode.dart';
import '../../../models/quiz_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool useAppBar = AppGeneralSettings.useTopAppBar;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool quizIsBeingGenerated = false;
  static TextEditingController _topicController = TextEditingController();
  GeminiQuizResponse? _quiz;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Map<int, String?> _selectedAnswers = {};
  Map<int, bool?> _isAnswerCorrect = {};
  int amountOfRequestsTries = 0;

  String _selectedDifficulty = 'Hard';
  String _selectedLanguage = 'Español 🇪🇸';
  int _selectedQuestionCount = 5;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void attemptGenerateQuiz() async {
    if (quizIsBeingGenerated) {
      return;
    }

    setState(() {
      quizIsBeingGenerated = true;
    });

    setState(() {
      _quiz = null;
      _currentPage = 0;
      _selectedAnswers = {};
      _isAnswerCorrect = {};
    });

    if (_topicController.text.isEmpty) {
      setState(() {
        quizIsBeingGenerated = false;
      });
      debugPrint('Topic is empty');
      return;
    }

    final geminiService = GeminiService();
    try {
      print('asa');
      final quiz = throw UnimplementedError();

      await geminiService.generateQuiz(
        topic: _topicController.text,
        difficulty: _selectedDifficulty,
        language: _selectedLanguage,
        questionCount: _selectedQuestionCount,
      );

      log(quiz.toJson().toString());
      setState(() {
        _quiz = quiz;
        _currentPage = 0;
        _selectedAnswers.clear();
        _isAnswerCorrect.clear();
      });
    } catch (e) {
      print('Amount of tries: $amountOfRequestsTries');
      if (amountOfRequestsTries <= 2) {
        setState(() {
          amountOfRequestsTries++;
        });

        print('amountOfRequestsTries: $amountOfRequestsTries');

        attemptGenerateQuiz();
        return;
      }

      print('Error generating quiz: $e');
      setState(() {
        _quiz = null;
        _currentPage = 0;
        _selectedAnswers = {};
        _isAnswerCorrect = {};
        amountOfRequestsTries = 0;
      });
      NotificationSnackbar.showSnackBar(
        icon: Icons.error,
        variant: 'error',
        message: 'Error generating quiz',
        duration: 'short',
      );
    }

    setState(() {
      quizIsBeingGenerated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideFloatingSpeedDialMenu: true,
      isProtected: true,
      appBarTitle: S.of(context).homeScreenTitle,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    isDense: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
                    items: <String>['English 🇬🇧', 'Español 🇪🇸']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      label: Text('Language'),
                      border: OutlineInputBorder(),
                      hintText: 'Select language',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDifficulty = newValue!;
                      });
                    },
                    items: <String>['Easy', 'Medium', 'Hard', 'Very hard']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      label: Text('Difficulty'),
                      border: OutlineInputBorder(),
                      hintText: 'Select difficulty',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              value: _selectedQuestionCount,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedQuestionCount = newValue!;
                });
              },
              items:
                  <int>[5, 10, 15, 20].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value questions'),
                );
              }).toList(),
              decoration: const InputDecoration(
                label: Text('Amount of questions'),
                border: OutlineInputBorder(),
                hintText: 'Select number of questions',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Insert a topic for the quiz',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: attemptGenerateQuiz,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 47),
              ),
              child: quizIsBeingGenerated
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Generating quiz...'),
                        SizedBox(width: 15),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: LoadingCircle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    )
                  : const Text('Generate Quiz'),
            ),
            const SizedBox(height: 20),
            _quiz != null
                ? SizedBox(
                    height: 400,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _quiz!.quiz.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildQuizPage(index, _quiz!.quiz[index]);
                      },
                    ),
                  )
                : Container(),
            const SizedBox(height: 10),
            if (_quiz != null &&
                _isAnswerCorrect[_currentPage] == null &&
                _currentPage < _quiz!.quiz.length)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    _validateAnswer(_currentPage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Check'),
                ),
              ),
            if (_quiz != null &&
                _isAnswerCorrect[_currentPage] != null &&
                _currentPage < _quiz!.quiz.length - 1)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _quiz!.quiz.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Text('Next'),
                ),
              ),
            if (_quiz != null &&
                _isAnswerCorrect[_currentPage] != null &&
                _currentPage == _quiz!.quiz.length - 1)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _showScore,
                  child: const Text('Finish'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizPage(int index, QuizModel question) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                ...question.options.entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAnswers[index] = entry.key;
                      });
                    },
                    child: ListTile(
                      title: Text(entry.value),
                      leading: Radio<String>(
                        value: entry.key,
                        groupValue: _selectedAnswers[index],
                        onChanged: (value) {
                          setState(() {
                            _selectedAnswers[index] = value;
                          });
                        },
                        activeColor: _getRadioColor(index, entry.key),
                      ),
                    ),
                  );
                }).toList(),
                if (_isAnswerCorrect[index] != null)
                  Text(
                    'Correct answer: ${question.options[question.correctAnswer]}',
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRadioColor(int index, String answerKey) {
    if (_isAnswerCorrect[index] == null) {
      return Colors.black;
    }
    if (_selectedAnswers[index] == answerKey) {
      return _isAnswerCorrect[index]! ? Colors.green : Colors.red;
    }
    return Colors.black;
  }

  void _validateAnswer(int index) {
    final correctAnswer = _quiz!.quiz[index].correctAnswer;
    setState(() {
      _isAnswerCorrect[index] = _selectedAnswers[index] == correctAnswer;
    });
  }

  void _showScore() {
    int score = 0;
    _quiz!.quiz.asMap().forEach((index, question) {
      if (_selectedAnswers[index] == question.correctAnswer) {
        score++;
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(10),
          title: const Text('Quiz Completed'),
          content: Scrollbar(
            thickness: 8,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your score is $score out of ${_quiz!.quiz.length}'),
                    const SizedBox(height: 10),
                    ..._quiz!.quiz.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${question.question}'),
                          RichText(
                            text: TextSpan(
                              text: 'Your answer: ',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: question
                                          .options[_selectedAnswers[index]] ??
                                      "Not answered",
                                  style: TextStyle(
                                    fontWeight: _selectedAnswers[index] ==
                                            question.correctAnswer
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (_selectedAnswers[index] ==
                                    question.correctAnswer)
                                  const TextSpan(
                                    text: '✅',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Correct answer: ',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      question.options[question.correctAnswer],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
