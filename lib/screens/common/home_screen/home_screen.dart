import 'dart:developer';
import 'package:ai_quiz_maker_app/widgets/LoadingCircle/loading_circle.dart';
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
  Quiz? _quiz;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Map<int, String?> _selectedAnswers = {};

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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isProtected: true,
      appBarTitle: S.of(context).homeScreenTitle,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
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
              onPressed: () async {
                if (quizIsBeingGenerated) {
                  return;
                }
                setState(() {
                  quizIsBeingGenerated = true;
                });

                if (_topicController.text.isEmpty) {
                  debugPrint('Topic is empty');
                  return;
                }

                final geminiService = GeminiService();
                try {
                  final quiz = await geminiService.generateQuiz(
                    topic: _topicController.text,
                    difficulty: 'hard',
                  );

                  log(quiz.toJson().toString());
                  setState(() {
                    _quiz = quiz;
                    _currentPage = 0;
                    _selectedAnswers.clear();
                  });
                } catch (e) {
                  print('Error generating quiz: $e');
                }

                setState(() {
                  quizIsBeingGenerated = false;
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 47),
              ),
              child: quizIsBeingGenerated
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: LoadingCircle(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    )
                  : const Text('Trigger AI'),
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
            if (_quiz != null && _currentPage < _quiz!.quiz.length - 1)
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
            if (_quiz != null && _currentPage == _quiz!.quiz.length - 1)
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

  Widget _buildQuizPage(int index, QuizQuestion question) {
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
                  return ListTile(
                    title: Text(entry.value),
                    leading: Radio<String>(
                      value: entry.key,
                      groupValue: _selectedAnswers[index],
                      onChanged: (value) {
                        setState(() {
                          _selectedAnswers[index] = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
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
          title: const Text('Quiz Completed'),
          content: SingleChildScrollView(
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
                      // Text(
                      //     'Your answer: ${question.options[_selectedAnswers[index]] ?? "Not answered"}',
                      //     style: TextStyle(
                      //       fontWeight: _selectedAnswers[index] ==
                      //               question.correctAnswer
                      //           ? FontWeight.bold
                      //           : FontWeight.normal,
                      //     )),

                      RichText(
                          text: TextSpan(
                        text: 'Your answer: ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: question.options[_selectedAnswers[index]] ??
                                "Not answered",
                            style: TextStyle(
                              fontWeight: _selectedAnswers[index] ==
                                      question.correctAnswer
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (_selectedAnswers[index] == question.correctAnswer)
                            const TextSpan(
                              text: '✅',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                        ],
                      )),

                      RichText(
                          text: TextSpan(
                        text: 'Correct answer: ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: question.options[question.correctAnswer],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                      // Text(
                      //     'Correct answer: ${question.options[question.correctAnswer]}',
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //     )),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ],
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
