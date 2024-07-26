import 'package:ai_quiz_maker_app/app_settings/theme_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/quiz_model.dart';
import '../../../routes/routes.dart';
import '../../../widgets/AppScaffold/app_scaffold.dart';
import '../../../widgets/LoadingCircle/loading_circle.dart';
import '../../../widgets/NotificationSnackbar/notification_snackbar.dart';

class QuizScreen extends StatefulWidget {
  final GeminiQuizResponse quiz;

  QuizScreen({required this.quiz});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController _pageController = PageController();

  Map<int, String?> _selectedAnswers = {};
  Map<int, bool?> _isAnswerCorrect = {};
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AppScaffold(
      hideFloatingSpeedDialMenu: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage == 0)
                  const SizedBox()
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: IconButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80),
                            side: BorderSide(
                              color: Colors.black.withOpacity(1),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(0),
                      icon: Container(
                        padding: const EdgeInsets.only(
                            left: 10), // Ajustá este valor según necesites
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_ios,
                        ),
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 10),
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Center(
                      child: Icon(
                        Icons.refresh,
                        size: 30,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedAnswers = {};
                        _isAnswerCorrect = {};
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              Routes.homeScreen.builder(context)));
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.85,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.quiz.quiz.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildQuizPage(index, widget.quiz.quiz[index]);
                },
              ),
            ),
          ],
        ),
      ),
      appBarTitle: 'Quiz',
      showScreenTitleInAppBar: true,
      isProtected: true,
    );
  }

  Widget _buildQuizPage(int index, QuizModel question) {
    return Card(
      color: const Color(0xffff8cbc),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 23,
                    ),
                    Stack(
                      children: [
                        AutoSizeText(
                          maxLines: 4,
                          minFontSize: 12,
                          question.question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              height: 1.07,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontSize: 37,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                              fontFamily: 'Wallop'),
                        ),
                        AutoSizeText(
                          maxLines: 4,
                          minFontSize: 12,
                          question.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            height: 1.07,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 0.0,
                                color: Colors.black,
                                offset: Offset(-3.0, 2.0),
                              ),
                            ],
                            fontSize: 37,
                            color: Colors.white,
                            fontFamily: 'Wallop',
                          ),
                        ),
                      ],
                    ),
                    // Stack(
                    //   children: [
                    //     AutoSizeText(
                    //       maxLines: 4,
                    //       question.question,
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //           letterSpacing: 0.0,
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 37,
                    //           foreground: Paint()
                    //             ..style = PaintingStyle.stroke
                    //             ..strokeWidth = 2
                    //             ..color = Colors.black,
                    //           fontFamily: 'Wallop'),
                    //     ),
                    //     AutoSizeText(
                    //       maxLines: 4,
                    //       question.question,
                    //       textAlign: TextAlign.center,
                    //       style: const TextStyle(
                    //         letterSpacing: 0.0,
                    //         fontWeight: FontWeight.bold,
                    //         shadows: [
                    //           Shadow(
                    //             blurRadius: 0.0,
                    //             color: Colors.black,
                    //             offset: Offset(-3.0, 2.0),
                    //           ),
                    //         ],
                    //         fontSize: 37,
                    //         color: Colors.white,
                    //         fontFamily: 'Wallop',
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 23),
                    ...question.options.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: GestureDetector(
                          onTap: _isAnswerCorrect[index] == null
                              ? () {
                                  setState(() {
                                    _selectedAnswers[index] = entry.key;
                                  });
                                }
                              : null,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: _getRadioColor(index, entry.key),
                                width: _selectedAnswers[index] == entry.key
                                    ? 1.8
                                    : 0.7,
                              ),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.only(left: 20, right: 5),
                              leading: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 17),
                              ),
                              title: Center(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                child: Text(
                                  removeDiacritics(entry.value),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.chathura(
                                    textStyle: const TextStyle(
                                        height: 0.7,
                                        fontSize: 31,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              )),
                              minLeadingWidth: 42,
                              minTileHeight: 54,
                              trailing: Checkbox(
                                value: _selectedAnswers[index] == entry.key,
                                onChanged: _isAnswerCorrect[index] == null
                                    ? (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedAnswers[index] = entry.key;
                                          } else {
                                            _selectedAnswers[index] = null;
                                          }
                                        });
                                      }
                                    : (bool? value) {},
                                activeColor: _getRadioColor(index, entry.key),
                                checkColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    if (_isAnswerCorrect[index] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Text(
                          'Correct answer: ${question.options[question.correctAnswer]}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 4,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${index + 1} / ${widget.quiz.quiz.length}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: Container(
                      //     width: 90,
                      //     height: 50,
                      //     child: ElevatedButton(
                      //       onPressed: () => {
                      //         /// go to home page
                      //         Navigator.of(context).push(MaterialPageRoute(
                      //             builder: (context) =>
                      //                 Routes.homeScreen.builder(context)))
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.orangeAccent,
                      //       ),
                      //       child: const Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Stack(
                      //             children: [
                      //               Icon(
                      //                 Icons.refresh,
                      //                 size: 15,
                      //                 color: Colors.white,
                      //                 shadows: [
                      //                   Shadow(
                      //                     blurRadius: 1.0,
                      //                     color: Colors.black,
                      //                     offset: Offset(-0.7, 1.0),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //           Stack(
                      //
                      //             children: [
                      //               Text(
                      //                 'Restart',
                      //                 style: TextStyle(
                      //                   // color: Colors.white,
                      //                   fontSize: 11,
                      //                   shadows: [
                      //                     Shadow(
                      //                       blurRadius: 1.0,
                      //                       color: Colors.black,
                      //                       offset: Offset(-0.7, 1.0),
                      //                     ),
                      //                   ],
                      //                   color: Colors.white,
                      //                   fontFamily: 'Wallop',
                      //                 ),
                      //               ),
                      //             ],
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        width: 8,
                      ),
                      if (_isAnswerCorrect[_currentPage] == null &&
                          _currentPage < widget.quiz.quiz.length)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 90,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                _validateAnswer(_currentPage);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 15,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 1.0,
                                            color: Colors.black,
                                            offset: Offset(-0.7, 1.0),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      // Text(
                                      //   'Check',
                                      //   style: TextStyle(
                                      //       // color: Colors.white,
                                      //       fontSize: 12,
                                      //       foreground: Paint()
                                      //         ..style = PaintingStyle.stroke
                                      //         ..strokeWidth = 0.8
                                      //         ..color = Colors.black,
                                      //       fontFamily: 'Wallop'),
                                      // ),
                                      Text(
                                        'Check',
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: 12,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 1.0,
                                              color: Colors.black,
                                              offset: Offset(-0.7, 1.0),
                                            ),
                                          ],
                                          color: Colors.white,
                                          fontFamily: 'Wallop',
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_isAnswerCorrect[_currentPage] != null &&
                          _currentPage < widget.quiz.quiz.length - 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 90,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 15,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 1.0,
                                            color: Colors.black,
                                            offset: Offset(-0.7, 1.0),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Text(
                                        'Next',
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: 12,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 1.0,
                                              color: Colors.black,
                                              offset: Offset(-0.7, 1.0),
                                            ),
                                          ],
                                          color: Colors.white,
                                          fontFamily: 'Wallop',
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_isAnswerCorrect[_currentPage] != null &&
                          _currentPage == widget.quiz.quiz.length - 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 90,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _showScore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 15,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 1.0,
                                            color: Colors.black,
                                            offset: Offset(-0.7, 1.0),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Text(
                                        'Finish',
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: 12,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 1.0,
                                              color: Colors.black,
                                              offset: Offset(-0.7, 1.0),
                                            ),
                                          ],
                                          color: Colors.white,
                                          fontFamily: 'Wallop',
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    final correctAnswer = widget.quiz.quiz[index].correctAnswer;
    setState(() {
      _isAnswerCorrect[index] = _selectedAnswers[index] == correctAnswer;
    });
  }

  void _showScore() {
    int score = 0;
    widget.quiz.quiz.asMap().forEach((index, question) {
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
                    Text(
                        'Your score is $score out of ${widget.quiz.quiz.length}'),
                    const SizedBox(height: 10),
                    ...widget.quiz.quiz.asMap().entries.map((entry) {
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
