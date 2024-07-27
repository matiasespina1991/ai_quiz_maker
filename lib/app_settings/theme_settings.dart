import 'package:flutter/material.dart';
import '../models/general_models.dart';
import '../models/theme_models.dart';

class ThemeSettings {
  static const String defaultThemeMode = 'light';
  static const bool forceDefaultThemeMode = true;
  static const bool useMaterial3 = true;
  static const bool useSafeArea = true;
  static const EdgeInsetsGeometry scaffoldPadding = EdgeInsets.only(
    top: 0,
    bottom: 0,
    left: 10,
    right: 10,
  );
  static double appBarHeight = 50;
  static const Color seedColor = Colors.green;
  static const bool forceSeedColor = false;
  static const String defaultScrollPhysics =
      'always'; // 'never', 'always', 'clamp'
  static const bool useFlutterToast = false;
  static const String textInputBorderStyle = 'border'; // 'border' / 'no-border'
  static const bool glassTextInputs = true;
  static const double buttonsElevation = 2;
  static const double buttonsHeight = 47;
  static const double buttonsOpacity = 0.9;
  static const String noInternetNotificationType =
      'modal'; // 'snackbar' / 'modal' / 'dialog'
  static const int secondsUntilNoInternetNotification = 5;

  static const LottieAnimationBackground primaryLottieBackgroundAnimation =
      LottieAnimationBackground(
    animationPath: 'lib/assets/lottie_animations/animation9.json',
    width: 200,
    x: 0,
    y: 0,
    blur: 80,
    active: true,
    opacity: 0.8,
  );

  static const LottieAnimationBackground secondaryLottieBackgroundAnimation =
      LottieAnimationBackground(
    animationPath: 'lib/assets/lottie_animations/animation4.json',
    width: 200,
    x: 0,
    y: 390,
    blur: 80,
    active: true,
    opacity: 0.8,
  );

  static const ternaryLottieBackgroundAnimation = LottieAnimationBackground(
    animationPath: 'lib/assets/lottie_animations/animation10.json',
    width: 200,
    x: 0,
    y: 0,
    blur: 50,
    active: true,
    opacity: 0.5,
  );

  static const errorColor = Colors.red;

  static ColorPalette colorPalette = ColorPalette(
    first: const Color(0xffff8cbc),
    second: const Color(0xFFBDBDBD),
    third: const Color(0xFF9E9E9E),
    fourth: const Color(0xFF757575),
    fifth: const Color(0xFF616161),
  );

  static const ThemeColors scaffoldBackgroundColor = ThemeColors(
    lightModePrimary: Color(0xFFFFF8FE),
    darkModePrimary: Color(0xFF121212),
  );

  static const ThemeColors appBarBackgroundColor = ThemeColors(
    lightModePrimary: Colors.transparent,
    darkModePrimary: Colors.transparent,
  );

  static const ThemeColors primaryTextColor = ThemeColors(
    lightModePrimary: Colors.black,
    darkModePrimary: Colors.white,
  );

  static const ThemeColors secondaryTextColor = ThemeColors(
    lightModePrimary: Colors.black,
    darkModePrimary: Colors.white,
  );

  static const ThemeColors hintTextColor = ThemeColors(
    lightModePrimary: Colors.grey,
    darkModePrimary: Colors.grey,
  );

  static const ThemeColors cardBackgroundColor = ThemeColors(
    lightModePrimary: Colors.blueGrey,
    darkModePrimary: Colors.white,
  );

  static const ThemeColors primaryContainerBackgroundColor = ThemeColors(
    lightModePrimary: Colors.blueGrey,
    darkModePrimary: Colors.blueGrey,
  );

  static const ThemeColors appbarOnBackgroundColor = ThemeColors(
    lightModePrimary: Colors.black,
    darkModePrimary: Colors.white,
  );
  static const ThemeColors elevatedButtonBackgroundColor = ThemeColors(
    lightModePrimary: seedColor,
    darkModePrimary: Colors.white,
  );

  static const ThemeColors elevatedButtonTextColor = ThemeColors(
    lightModePrimary: Colors.white,
    darkModePrimary: Colors.black,
  );

  static const ThemeColors outlinedButtonBackgroundColor = ThemeColors(
    lightModePrimary: Colors.blueGrey,
    darkModePrimary: Colors.blueGrey,
  );

  static const ThemeColors outlinedButtonTextColor = ThemeColors(
    lightModePrimary: Colors.black,
    darkModePrimary: Colors.white,
  );

  static const ThemeColors textButtonTextColor = ThemeColors(
    lightModePrimary: Colors.black,
    darkModePrimary: Colors.white,
  );

  static const BorderRadius buttonsBorderRadius = BorderRadius.all(
    Radius.circular(10),
  );

  static const BorderRadius inputsBorderRadius = BorderRadius.all(
    Radius.circular(15),
  );

  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(40),
  );

  static const BorderRadius chipBorderRadius = BorderRadius.all(
    Radius.circular(5),
  );

  static const Color snackBarErrorBackgroundColor = errorColor;
  static const Color snackBarErrorTextColor = Colors.white;
  static const Color snackBarSuccessBackgroundColor = Colors.green;
  static const Color snackBarSuccessTextColor = Colors.white;
  static const Color snackBarInfoBackgroundColor = Colors.black;
  static const Color snackBarInfoTextColor = Colors.white;

  static const FontConfig appBarTextStyle = FontConfig(
    name: 'Roboto',
    isGoogleFont: true,
  );

  static const FontConfig primaryTextStyle = FontConfig(
    name: 'Wallop',
    isGoogleFont: false,
  );

  static const FontConfig secondaryTextStyle = FontConfig(
    name: 'Chathura',
    isGoogleFont: true,
  );

  static const FontConfig tertiaryTextStyle = FontConfig(
    name: 'Lato',
    isGoogleFont: true,
  );

  static const FontConfig snackbarTextStyle = FontConfig(
    name: 'Roboto',
    isGoogleFont: true,
  );

  static const double appBarTitleFontSize = 20;
  static const double bodyLargeFontSize = 14;
  static const double bodyMediumFontSize = 13;
  static const double bodySmallFontSize = 12;
  static const double snackbarFontSize = 14;

  static const TextThemes textThemes = TextThemes(
    primaryFont: primaryTextStyle,
    secondaryFont: secondaryTextStyle,
    tertiaryFont: tertiaryTextStyle,
  );
}

class ColorPalette {
  final Color first;
  final Color second;
  final Color third;
  final Color fourth;
  final Color fifth;

  ColorPalette({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
  });
}
