import 'package:flutter/material.dart';

sealed class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  const AppColorsTheme();

  // Colors
  static const Color green = Color(0xFF47C87D);
  static const Color blue = Color(0xFF347AE6);
  static const Color darkGrey = Color(0xFF2E3B52);
  static const Color midGrey = Color(0xFF6C757D);
  static const Color lightGrey = Color(0xFFCCCCCC);
  static const Color strokeGrey = Color(0xFFCED4DA);
  static const Color pink = Color(0xFFFF0090);
  static const Color purple = Color(0xFF46196E);
  static const Color lightPurple = Color(0xFFF7EEFF);
  static const Color gold = Color(0xFFFA9D28);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color redValidation = Color(0xFFFF3654);
  static const Color yellowValidation = Color(0xFFFCCA46);

  // Theme
  Color get primaryColor;

  Color get onPrimary;

  Color get secondaryColor;

  Color get onSecondary;

  Color get background;

  // Cursor
  Color get cursorColor;

  Color get selectionHandleColor;

  Color get selectionColor;

  // Text
  Color get indicationText;

  // Border
  Color get enabledBorderColor;

  Color get disabledBorderColor;

  Color get focusedBorderColor;

  Color get errorBorderColor;

  Color get focusedErrorBorderColor;

  // Checkbox
  Color get checkboxCheckColor;

  Color get selectedCheckboxFillColor;

  Color get unSelectedCheckboxFillColor;

  Color get disabledCheckboxFillColor;

  // Button
  Color get disabledButtonBackgroundColor;
  
  Color get onDisabledButtonBackgroundColor;

  Color get buttonPurple;

  // Barrier
  Color get barrierColor1;

  // Card
  Color get cardShadowColor;

  // Chip
  Color get selectedChipBorderColor;

  // Divider
  Color get dividerColor;

  // Progress Indicator
  Color get progressIndicatorColor;
}

final class AppColorsThemeLight extends AppColorsTheme {
  const AppColorsThemeLight._({
    required this.primaryColor,
    required this.onPrimary,
    required this.secondaryColor,
    required this.onSecondary,
    required this.background,
    required this.cursorColor,
    required this.selectionHandleColor,
    required this.selectionColor,
    required this.indicationText,
    required this.enabledBorderColor,
    required this.disabledBorderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.focusedErrorBorderColor,
    required this.checkboxCheckColor,
    required this.selectedCheckboxFillColor,
    required this.unSelectedCheckboxFillColor,
    required this.disabledCheckboxFillColor,
    required this.disabledButtonBackgroundColor,
    required this.onDisabledButtonBackgroundColor,
    required this.buttonPurple,
    required this.barrierColor1,
    required this.cardShadowColor,
    required this.selectedChipBorderColor,
    required this.dividerColor,
    required this.progressIndicatorColor,
  });

  static const AppColorsThemeLight instance = AppColorsThemeLight._(
    primaryColor: AppColorsTheme.purple,
    onPrimary: AppColorsTheme.white,
    secondaryColor: AppColorsTheme.pink,
    onSecondary: AppColorsTheme.white,
    background: AppColorsTheme.white,
    cursorColor: AppColorsTheme.purple,
    selectionHandleColor: AppColorsTheme.purple,
    selectionColor: AppColorsTheme.lightPurple,
    indicationText: Color(0xFF888888),
    enabledBorderColor: AppColorsTheme.purple,
    disabledBorderColor: Color(0x80CED4DA),
    focusedBorderColor: AppColorsTheme.purple,
    errorBorderColor: AppColorsTheme.redValidation,
    focusedErrorBorderColor: AppColorsTheme.redValidation,
    checkboxCheckColor: AppColorsTheme.white,
    selectedCheckboxFillColor: AppColorsTheme.purple,
    unSelectedCheckboxFillColor: AppColorsTheme.white,
    disabledCheckboxFillColor: AppColorsTheme.white,
    disabledButtonBackgroundColor: AppColorsTheme.lightGrey,
    onDisabledButtonBackgroundColor: AppColorsTheme.white,
    buttonPurple: Color(0xFF9646C3),
    barrierColor1: Color(0xCC000000),
    cardShadowColor: Color.fromRGBO(52, 122, 230, 0.08),
    selectedChipBorderColor: AppColorsTheme.pink,
    dividerColor: AppColorsTheme.lightGrey,
    progressIndicatorColor: AppColorsTheme.pink,
  );

  @override
  final Color primaryColor;
  @override
  final Color onPrimary;
  @override
  final Color secondaryColor;
  @override
  final Color onSecondary;
  @override
  final Color background;
  @override
  final Color cursorColor;
  @override
  final Color selectionHandleColor;
  @override
  final Color selectionColor;
  @override
  final Color indicationText;
  @override
  final Color enabledBorderColor;
  @override
  final Color disabledBorderColor;
  @override
  final Color focusedBorderColor;
  @override
  final Color errorBorderColor;
  @override
  final Color focusedErrorBorderColor;
  @override
  final Color checkboxCheckColor;
  @override
  final Color selectedCheckboxFillColor;
  @override
  final Color unSelectedCheckboxFillColor;
  @override
  final Color disabledCheckboxFillColor;
  @override
  final Color disabledButtonBackgroundColor;
  @override
  final Color onDisabledButtonBackgroundColor;
  @override
  final Color buttonPurple;
  @override
  final Color barrierColor1;
  @override
  final Color cardShadowColor;
  @override
  final Color selectedChipBorderColor;
  @override
  final Color dividerColor;
  @override
  final Color progressIndicatorColor;

  @override
  ThemeExtension<AppColorsTheme> copyWith({
    Color? primaryColor,
    Color? onPrimary,
    Color? secondaryColor,
    Color? onSecondary,
    Color? background,
    Color? cursorColor,
    Color? selectionHandleColor,
    Color? selectionColor,
    Color? indicationText,
    Color? enabledBorderColor,
    Color? disabledBorderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    Color? focusedErrorBorderColor,
    Color? checkboxCheckColor,
    Color? selectedCheckboxFillColor,
    Color? unSelectedCheckboxFillColor,
    Color? disabledCheckboxFillColor,
    Color? disabledButtonBackgroundColor,
    Color? onDisabledButtonBackgroundColor,
    Color? buttonPurple,
    Color? barrierColor1,
    Color? cardShadowColor,
    Color? selectedChipBorderColor,
    Color? dividerColor,
    Color? progressIndicatorColor,
  }) =>
      AppColorsThemeLight._(
        primaryColor: primaryColor ?? this.primaryColor,
        onPrimary: onPrimary ?? this.onPrimary,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        onSecondary: onSecondary ?? this.onSecondary,
        background: background ?? this.background,
        cursorColor: cursorColor ?? this.cursorColor,
        selectionHandleColor: selectionHandleColor ?? this.selectionHandleColor,
        selectionColor: selectionColor ?? this.selectionColor,
        indicationText: indicationText ?? this.indicationText,
        enabledBorderColor: enabledBorderColor ?? this.enabledBorderColor,
        disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
        focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
        errorBorderColor: errorBorderColor ?? this.errorBorderColor,
        focusedErrorBorderColor:
            focusedErrorBorderColor ?? this.focusedErrorBorderColor,
        checkboxCheckColor: checkboxCheckColor ?? this.checkboxCheckColor,
        selectedCheckboxFillColor:
            selectedCheckboxFillColor ?? this.selectedCheckboxFillColor,
        unSelectedCheckboxFillColor:
            unSelectedCheckboxFillColor ?? this.unSelectedCheckboxFillColor,
        disabledCheckboxFillColor:
            disabledCheckboxFillColor ?? this.disabledCheckboxFillColor,
        disabledButtonBackgroundColor:
            disabledButtonBackgroundColor ?? this.disabledButtonBackgroundColor,
        onDisabledButtonBackgroundColor: onDisabledButtonBackgroundColor ??
            this.onDisabledButtonBackgroundColor,
        buttonPurple: buttonPurple ?? this.buttonPurple,
        barrierColor1: barrierColor1 ?? this.barrierColor1,
        cardShadowColor: cardShadowColor ?? this.cardShadowColor,
        selectedChipBorderColor:
            selectedChipBorderColor ?? this.selectedChipBorderColor,
        dividerColor: dividerColor ?? this.dividerColor,
        progressIndicatorColor:
            progressIndicatorColor ?? this.progressIndicatorColor,
      );

  @override
  ThemeExtension<AppColorsTheme> lerp(
    ThemeExtension<AppColorsTheme>? other,
    double t,
  ) {
    if (other is! AppColorsThemeLight) {
      return this;
    }
    return AppColorsThemeLight._(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      cursorColor: Color.lerp(cursorColor, other.cursorColor, t)!,
      selectionHandleColor:
          Color.lerp(selectionHandleColor, other.selectionHandleColor, t)!,
      selectionColor: Color.lerp(selectionColor, other.selectionColor, t)!,
      indicationText: Color.lerp(indicationText, other.indicationText, t)!,
      enabledBorderColor:
          Color.lerp(enabledBorderColor, other.enabledBorderColor, t)!,
      disabledBorderColor:
          Color.lerp(disabledBorderColor, other.disabledBorderColor, t)!,
      focusedBorderColor:
          Color.lerp(focusedBorderColor, other.focusedBorderColor, t)!,
      errorBorderColor:
          Color.lerp(errorBorderColor, other.errorBorderColor, t)!,
      focusedErrorBorderColor: Color.lerp(
        focusedErrorBorderColor,
        other.focusedErrorBorderColor,
        t,
      )!,
      checkboxCheckColor:
          Color.lerp(checkboxCheckColor, other.checkboxCheckColor, t)!,
      selectedCheckboxFillColor: Color.lerp(
        selectedCheckboxFillColor,
        other.selectedCheckboxFillColor,
        t,
      )!,
      unSelectedCheckboxFillColor: Color.lerp(
        unSelectedCheckboxFillColor,
        other.unSelectedCheckboxFillColor,
        t,
      )!,
      disabledCheckboxFillColor: Color.lerp(
        disabledCheckboxFillColor,
        other.disabledCheckboxFillColor,
        t,
      )!,
      disabledButtonBackgroundColor: Color.lerp(
        disabledButtonBackgroundColor,
        other.disabledButtonBackgroundColor,
        t,
      )!,
      onDisabledButtonBackgroundColor: Color.lerp(
        onDisabledButtonBackgroundColor,
        other.onDisabledButtonBackgroundColor,
        t,
      )!,
      buttonPurple: Color.lerp(buttonPurple, other.buttonPurple, t)!,
      barrierColor1: Color.lerp(barrierColor1, other.barrierColor1, t)!,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t)!,
      selectedChipBorderColor: Color.lerp(
        selectedChipBorderColor,
        other.selectedChipBorderColor,
        t,
      )!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      progressIndicatorColor:
          Color.lerp(progressIndicatorColor, other.progressIndicatorColor, t)!,
    );
  }
}
