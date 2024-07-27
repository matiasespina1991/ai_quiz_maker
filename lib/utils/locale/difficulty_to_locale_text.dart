import 'package:flutter/cupertino.dart';

import '../../generated/l10n.dart';

String difficultyToLocaleText(String difficulty, BuildContext context) {
  switch (difficulty) {
    case 'easy':
      return S.of(context).easyDifficulty;
    case 'medium':
      return S.of(context).mediumDifficulty;
    case 'hard':
      return S.of(context).hardDifficulty;
    case 'very hard':
      return S.of(context).veryHardDifficulty;
    default:
      return S.of(context).easyDifficulty;
  }
}
