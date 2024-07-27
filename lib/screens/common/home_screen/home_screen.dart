import 'package:ai_quiz_maker_app/utils/locale/difficulty_to_locale_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../generated/l10n.dart';
import '../../../providers/providers_all.dart';
import '../../../services/gemini_service.dart';
import '../../../utils/locale/language_code_to_language_name.dart';
import '../../../widgets/LoadingCircle/loading_circle.dart';
import '../../../widgets/NotificationSnackbar/notification_snackbar.dart';
import '../../../app_settings/app_general_settings.dart';
import '../../../widgets/AppScaffold/app_scaffold.dart';
import '../../../models/quiz_model.dart';
import '../quiz_screen/quiz_screen.dart';

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
  int amountOfRequestsTries = 0;

  String _selectedDifficulty = 'hard';
  String _selectedLanguage = 'es';
  int _selectedQuestionCount = 5;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void attemptGenerateQuiz() async {
    if (quizIsBeingGenerated) {
      return;
    }

    setState(() {
      quizIsBeingGenerated = true;
      _quiz = null;
    });

    if (_topicController.text.isEmpty) {
      setState(() {
        quizIsBeingGenerated = false;
      });
      debugPrint(S.of(context).topicIsEmptyMessage);
      return;
    }

    final geminiService = GeminiService();
    try {
      var quiz = await geminiService.generateQuiz(
        topic: _topicController.text,
        difficulty: _selectedDifficulty,
        languageCode: _selectedLanguage,
        questionCount: _selectedQuestionCount,
      );

      setState(() {
        quizIsBeingGenerated = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(quiz: quiz),
          ),
        );
      }
    } catch (e) {
      if (amountOfRequestsTries < 2) {
        setState(() {
          amountOfRequestsTries++;
        });
        debugPrint('Amount of tries: $amountOfRequestsTries');
      }

      debugPrint('Error generating quiz: $e');
      setState(() {
        quizIsBeingGenerated = false;
        amountOfRequestsTries = 0;
      });
      NotificationSnackbar.showSnackBar(
        icon: Icons.error,
        variant: 'error',
        message: S.of(context).errorGeneratingQuizMessage,
        duration: 'short',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return AppScaffold(
      useTopAppBar: false,
      hideFloatingSpeedDialMenu: true,
      isProtected: true,
      appBarTitle: S.of(context).homeScreenTitle,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight - 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedLanguage,
                          isDense: true,
                          onChanged: (String? newValue) {
                            ref
                                .watch(localeProvider)
                                .setLocale(Locale(newValue!));
                            setState(() {
                              _selectedLanguage = newValue;
                            });
                          },
                          items: <String>['en', 'es']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(languageCodeToLanguageName(value)),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 19),
                            labelText: S.of(context).languageLabel,
                            border: OutlineInputBorder(),
                            hintText: S.of(context).selectLanguageHint,
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
                          items: <String>['easy', 'medium', 'hard', 'very hard']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child:
                                  Text(difficultyToLocaleText(value, context)),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 19),
                            labelText: S.of(context).difficultyLabel,
                            border: OutlineInputBorder(),
                            hintText: S.of(context).selectDifficultyHint,
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
                    items: <int>[5, 10, 15, 20]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value ${S.of(context).questions}'),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: S.of(context).amountOfQuestionsLabel,
                      border: OutlineInputBorder(),
                      hintText: S.of(context).selectQuestionCountHint,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 14),
                  TextField(
                    controller: _topicController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 21,
                        ),
                        onPressed: () {
                          _topicController.clear();
                        },
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 19, vertical: 17),
                      border: OutlineInputBorder(),
                      hintText: S.of(context).insertTopicHint,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: attemptGenerateQuiz,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 47),
                    ),
                    child: quizIsBeingGenerated
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(S.of(context).generatingQuizMessage),
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
                        : Text(S.of(context).generateQuizButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
