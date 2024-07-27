import 'package:ai_quiz_maker_app/app_settings/theme_settings.dart';
import 'package:ai_quiz_maker_app/providers/providers_all.dart';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../generated/l10n.dart';
import '../../../models/quiz_model.dart';
import '../../../routes/routes.dart';
import '../../../widgets/AppScaffold/app_scaffold.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final GeminiQuizResponse quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends ConsumerState<QuizScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = true;

  Map<int, String?> _selectedAnswers = {};
  Map<int, bool?> _isAnswerCorrect = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isScrolledToBottom = _scrollController.position.atEdge &&
          _scrollController.position.pixels != 0;
    });
  }

  double buttonWidthOnLocalizations(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 83;
      case 'es':
        return 83;
      default:
        return 83;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return AppScaffold(
      scrollPhysics: const NeverScrollableScrollPhysics(),
      hideFloatingSpeedDialMenu: true,
      useSafeArea: false,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
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
                              color: Colors.black.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(0),
                      icon: Container(
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 23,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
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
                        Icons.close,
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
              height: isSmallScreen ? screenHeight * 0.85 : screenHeight * 0.80,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
      appBarTitle: 'Quiz',
      showScreenTitleInAppBar: true,
      isProtected: true,
    );
  }

  Widget _buildQuizPage(int index, QuizModel question) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final currentLanguage = ref.watch(localeProvider).locale;
    final userClickedOnCheck = _isAnswerCorrect[index] != null;
    final userSelectedAnswer = _selectedAnswers[index];
    final correctAnswer = question.correctAnswer;
    final isAnswerCorrect = _isAnswerCorrect[index];

    return Card(
      color: ThemeSettings.colorPalette.first,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Stack(
                        children: [
                          AutoSizeText(
                            maxLines: isSmallScreen ? 4 : 8,
                            minFontSize: 12,
                            maxFontSize: 33,
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
                            maxLines: isSmallScreen ? 4 : 8,
                            maxFontSize: 33,
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
                    ),
                    const SizedBox(height: 16),

                    /// OPTIONS
                    ...question.options.entries.map((entry) {
                      final correctAnswer =
                          widget.quiz.quiz[index].correctAnswer;
                      final currentEntry = entry.key;
                      return ShakeX(
                        curve: Curves.linear,
                        duration: const Duration(milliseconds: 100),
                        from: 3,
                        animate: userClickedOnCheck &&
                            correctAnswer == currentEntry &&
                            userSelectedAnswer != currentEntry,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: GestureDetector(
                            onTap: !userClickedOnCheck
                                ? () {
                                    setState(() {
                                      _selectedAnswers[index] = entry.key;
                                      HapticFeedback.selectionClick();
                                    });
                                  }
                                : null,
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                                side: BorderSide(
                                  color: userClickedOnCheck &&
                                          correctAnswer == currentEntry
                                      ? Colors.green
                                      : _getRadioColor(index, entry.key),
                                  width: (userClickedOnCheck &&
                                          correctAnswer == currentEntry)
                                      ? 2.1
                                      : userSelectedAnswer == entry.key
                                          ? 1.8
                                          : 0.7,
                                ),
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 20, right: 10),
                                leading: Text(entry.key,
                                    style: TextStyle(
                                      color: userClickedOnCheck &&
                                              correctAnswer == entry.key
                                          ? Colors.green
                                          : userSelectedAnswer == entry.key &&
                                                  userClickedOnCheck
                                              ? _getRadioColor(index, entry.key)
                                              : Colors.black,
                                      fontSize: 16,
                                    )),
                                title: Center(
                                    child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11),
                                  child: Text(
                                    removeDiacritics(entry.value),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.chathura(
                                      textStyle: TextStyle(
                                        color: userClickedOnCheck &&
                                                correctAnswer == entry.key
                                            ? Colors.green
                                            : userSelectedAnswer == entry.key &&
                                                    userClickedOnCheck
                                                ? _getRadioColor(
                                                    index, entry.key)
                                                : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        height: 0.7,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                )),
                                minLeadingWidth: 20,
                                minTileHeight: 54,
                                trailing: Checkbox(
                                  side: BorderSide(
                                    color: userClickedOnCheck &&
                                            correctAnswer == currentEntry
                                        ? Colors.green
                                        : Colors.black,
                                    width: userClickedOnCheck &&
                                            correctAnswer == currentEntry
                                        ? 2.3
                                        : 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  value: userSelectedAnswer == entry.key,
                                  onChanged: !userClickedOnCheck
                                      ? (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              HapticFeedback.selectionClick();
                                              _selectedAnswers[index] =
                                                  entry.key;
                                            } else {
                                              _selectedAnswers[index] = null;
                                            }
                                          });
                                        }
                                      : (bool? value) {},
                                  activeColor: userClickedOnCheck &&
                                          correctAnswer == entry.key
                                      ? Colors.green
                                      : _getRadioColor(index, entry.key),
                                  checkColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (userClickedOnCheck)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Divider(),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                width: 2,
                                color: Colors.green.withOpacity(1),
                              ),
                            ),
                            child: ListTile(
                              trailing: Icon(
                                Icons.info,
                                color: Colors.green.withOpacity(1),
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 7, right: 7, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text:
                                            '${S.of(context).correctAnswer}: ',
                                        style: GoogleFonts.chathura(
                                          textStyle: const TextStyle(
                                            height: 0.7,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: removeDiacritics(question
                                                    .options[correctAnswer] ??
                                                "Not answered"),
                                            style: GoogleFonts.chathura(
                                              textStyle: const TextStyle(
                                                height: 0.7,
                                                fontSize: 30,
                                                fontWeight: FontWeight
                                                    .normal, // Regular for the rest
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          TextSpan(
                                            text: ".",
                                            style: GoogleFonts.chathura(
                                              textStyle: const TextStyle(
                                                height: 0.7,
                                                fontSize: 30,
                                                fontWeight: FontWeight
                                                    .normal, // Regular for the rest
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Text(
                                        removeDiacritics(question.trivia),
                                        style: GoogleFonts.chathura(
                                          textStyle: const TextStyle(
                                            height: 0.7,
                                            letterSpacing: -0.6,
                                            fontSize: 30,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeSettings.colorPalette.first,
              boxShadow: [
                if (!_isScrolledToBottom)
                  BoxShadow(
                    color: Colors.black.withOpacity(1),
                    spreadRadius: 0,
                    blurRadius: 0.1,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 22,
                right: 15,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${index + 1} / ${widget.quiz.quiz.length}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      if (userClickedOnCheck)
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Icon(
                            isAnswerCorrect! ? Icons.check : Icons.close,
                            color: isAnswerCorrect ? Colors.green : Colors.red,
                          ),
                        ),

                      ///amount of correct answers
                      const Text(
                        '  -  ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _isAnswerCorrect.values
                                  .where((element) => element == true)
                                  .length
                                  .toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                      ),
                      if (_isAnswerCorrect[_currentPage] == null &&
                          _currentPage < widget.quiz.quiz.length)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: buttonWidthOnLocalizations(
                                currentLanguage.languageCode),
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius:
                                  ThemeSettings.buttonsBorderRadius.add(
                                const BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 1,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Ink(
                              padding: EdgeInsets.zero,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    ThemeSettings.seedColor,
                                    ThemeSettings.seedColor,
                                    Colors.green,
                                  ],
                                ),
                                borderRadius: ThemeSettings.buttonsBorderRadius,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _validateAnswer(_currentPage);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        ThemeSettings.buttonsBorderRadius,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Stack(
                                      children: [
                                        Icon(
                                          Icons.check,
                                          size: 15,
                                          color: Colors.white,
                                          shadows: [],
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        Text(
                                          S.of(context).check,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            shadows: [],
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
                        ),
                      if (_isAnswerCorrect[_currentPage] != null &&
                          _currentPage < widget.quiz.quiz.length - 1)
                        // create a blue NEXT button with the same style as the CHECK button
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: buttonWidthOnLocalizations(
                                currentLanguage.languageCode),
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  ThemeSettings.buttonsBorderRadius.add(
                                const BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 1,
                                  offset: const Offset(
                                      0, 0), // Ajuste la posición de la sombra
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      ThemeSettings.buttonsBorderRadius,
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 9, bottom: 7),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Stack(
                                      children: [
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 15,
                                          color: Colors.white,
                                          shadows: [],
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        Text(
                                          S.of(context).next,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            shadows: [],
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
                        ),
                      if (_isAnswerCorrect[_currentPage] != null &&
                          _currentPage == widget.quiz.quiz.length - 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: buttonWidthOnLocalizations(
                                currentLanguage.languageCode),
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius:
                                  ThemeSettings.buttonsBorderRadius.add(
                                const BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 1,
                                  offset: const Offset(
                                      0, 0), // Ajuste la posición de la sombra
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _showScore,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      ThemeSettings.buttonsBorderRadius,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Stack(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 15,
                                        color: Colors.white,
                                        shadows: [],
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Text(
                                        S.of(context).finish,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          shadows: [],
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
          ),
        ],
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
    if (answerKey == widget.quiz.quiz[index].correctAnswer) {
      return Colors.green;
    }
    return Colors.black;
  }

  void _validateAnswer(int index) {
    final correctAnswer = widget.quiz.quiz[index].correctAnswer;
    setState(() {
      _isAnswerCorrect[index] = _selectedAnswers[index] == correctAnswer;
    });

    if (_isAnswerCorrect[index] == true) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(question.question),
                          RichText(
                            text: TextSpan(
                              text: 'Your answer: ',
                              style: const TextStyle(
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
                              text: '${S.of(context).correctAnswer}: ',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      question.options[question.correctAnswer],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }),
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
