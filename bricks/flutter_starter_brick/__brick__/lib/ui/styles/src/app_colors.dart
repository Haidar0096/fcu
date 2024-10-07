import 'dart:ui';

sealed class AppColors {
  const AppColors();

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

final class AppColorsLight extends AppColors {
  const AppColorsLight._();

  static const AppColorsLight instance = AppColorsLight._();

  @override
  Color get primaryColor => AppColors.purple;

  @override
  Color get onPrimary => AppColors.white;

  @override
  Color get secondaryColor => AppColors.pink;

  @override
  Color get onSecondary => AppColors.white;

  @override
  Color get background => AppColors.white;

  @override
  Color get cursorColor => AppColors.purple;

  @override
  Color get selectionHandleColor => AppColors.purple;

  @override
  Color get selectionColor => AppColors.lightPurple;

  @override
  Color get indicationText => const Color(0xFF888888);

  @override
  Color get enabledBorderColor => AppColors.purple;

  @override
  Color get disabledBorderColor => AppColors.strokeGrey.withOpacity(0.5);

  @override
  Color get focusedBorderColor => AppColors.purple;

  @override
  Color get errorBorderColor => AppColors.redValidation;

  @override
  Color get focusedErrorBorderColor => AppColors.redValidation;

  @override
  Color get checkboxCheckColor => onPrimary;

  @override
  Color get selectedCheckboxFillColor => primaryColor;

  @override
  Color get unSelectedCheckboxFillColor => background;

  @override
  Color get disabledCheckboxFillColor => background;

  @override
  Color get disabledButtonBackgroundColor => AppColors.lightGrey;

  @override
  Color get buttonPurple => const Color(0xFF9646C3);

  @override
  Color get barrierColor1 => AppColors.black.withOpacity(0.8);

  @override
  Color get cardShadowColor => const Color.fromRGBO(52, 122, 230, 0.08);

  @override
  Color get selectedChipBorderColor => secondaryColor;

  @override
  Color get dividerColor => AppColors.lightGrey;

  @override
  Color get progressIndicatorColor => AppColors.pink;
}
