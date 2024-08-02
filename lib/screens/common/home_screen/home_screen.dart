import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../generated/l10n.dart';
import '../../../providers/providers_all.dart';
import '../../../services/gemini_service.dart';
import '../../../services/wikipedia_service.dart';
import '../../../utils/locale/difficulty_to_locale_text.dart';
import '../../../utils/locale/language_code_to_language_name.dart';
import '../../../widgets/LoadingCircle/loading_circle.dart';
import '../../../widgets/NotificationSnackbar/notification_snackbar.dart';
import '../../../app_settings/app_general_settings.dart';
import '../../../widgets/AppScaffold/app_scaffold.dart';
import '../quiz_screen/quiz_screen.dart';
import '../../../models/wikipedia_response_model.dart'; // Importa el nuevo modelo

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool useAppBar = AppGeneralSettings.useTopAppBar;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool quizIsBeingGenerated = false;
  static final TextEditingController _topicController = TextEditingController();
  int amountOfRequestsTries = 0;

  String _selectedDifficulty = 'hard';
  String _selectedLanguage = 'es';
  int _selectedQuestionCount = 5;
  WikipediaResponseModel? _wikipediaResponse;
  Map<String, String> wikipediaArticleUrl = {
    'searchString': '',
    'url': '',
  };

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
    });

    if (_topicController.text.isEmpty) {
      setState(() {
        quizIsBeingGenerated = false;
      });
      debugPrint('Topic is empty.');
      return;
    }

    String? wikipediaArticleContent = '';

    final wikipediaService = WikipediaService();
    if (wikipediaArticleUrl['url'] != null &&
        wikipediaArticleUrl['url']!.isNotEmpty) {
      try {
        wikipediaArticleContent = await wikipediaService.fetchArticleContent(
          wikipediaArticleUrl['url']!,
          _selectedLanguage,
        );
      } catch (e) {
        debugPrint('Error fetching article content: $e');
      }
    }

    final geminiService = GeminiService();
    try {
      var quiz = await geminiService.generateQuiz(
        topic: _topicController.text,
        difficulty: _selectedDifficulty,
        languageCode: _selectedLanguage,
        questionCount: _selectedQuestionCount,
        wikipediaArticleContent: wikipediaArticleContent,
        wikipediaArticleUrl:
            _topicController.text == wikipediaArticleUrl['searchString']
                ? wikipediaArticleUrl
                : null,
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

      if (mounted) {
        NotificationSnackbar.showSnackBar(
          icon: Icons.error,
          variant: 'error',
          message: S.of(context).errorGeneratingQuizMessage,
          duration: 'short',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final currentLocale = ref.watch(localeProvider).locale;
    return AppScaffold(
      useTopAppBar: false,
      hideFloatingSpeedDialMenu: true,
      isProtected: true,
      appBarTitle: S.of(context).homeScreenTitle,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight - 100,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'AI Quiz Generator',
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.black.withOpacity(0.70),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Column(
                children: [
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
                                const EdgeInsets.symmetric(horizontal: 19),
                            labelText: S.of(context).languageLabel,
                            border: const OutlineInputBorder(),
                            hintText: S.of(context).selectLanguageHint,
                            hintStyle: const TextStyle(color: Colors.grey),
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
                                const EdgeInsets.symmetric(horizontal: 19),
                            labelText: S.of(context).difficultyLabel,
                            border: const OutlineInputBorder(),
                            hintText: S.of(context).selectDifficultyHint,
                            hintStyle: const TextStyle(color: Colors.grey),
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
                      border: const OutlineInputBorder(),
                      hintText: S.of(context).selectQuestionCountHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TypeAheadField<String>(
                    autoFlipDirection: true,
                    autoFlipMinHeight: 110,
                    controller: _topicController,
                    hideOnEmpty: true,
                    hideOnLoading: true,
                    suggestionsCallback: (pattern) async {
                      _wikipediaResponse = await WikipediaService()
                          .fetchSuggestions(pattern, currentLocale);
                      return _wikipediaResponse!.suggestions;
                    },
                    itemBuilder: (context, suggestion) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 19, vertical: 9),
                        child: Text(suggestion,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.50),
                              fontSize: 14,
                            )),
                      );
                    },
                    onSelected: (suggestion) {
                      _topicController.text = suggestion;
                      final index =
                          _wikipediaResponse!.suggestions.indexOf(suggestion);
                      final url =
                          _wikipediaResponse!.wikipediaArticlesUrls[index];

                      setState(() {
                        wikipediaArticleUrl = {
                          'searchString': suggestion,
                          'url': url,
                        };
                      });
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          suffixIcon: _topicController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    color: Colors.black.withOpacity(0.6),
                                    Icons.clear,
                                    size: 21,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      controller.clear();
                                      _topicController.clear();
                                      wikipediaArticleUrl = {
                                        'searchString': '',
                                        'wikipediaArticlesUrls': '',
                                      };
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 19, vertical: 17),
                          border: const OutlineInputBorder(),
                          hintText: S.of(context).insertTopicHint,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      );
                    },
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
                              const SizedBox(width: 15),
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
              Spacer(),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  alignment: Alignment.center,
                  child: Text(
                    'Powered by Wikipedia and Gemini AI',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
