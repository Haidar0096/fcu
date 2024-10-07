import 'package:{{proj_name}}/ui/styles/src/app_colors.dart';
import 'package:{{proj_name}}/ui/styles/src/font_family.dart';
import 'package:flutter/material.dart';

const double _defaultButtonHeight = 50;
const double _defaultButtonWidth = 100;

const double _defaultButtonBorderRadius = 10;

sealed class AppButtonTheme extends ThemeExtension<AppButtonTheme> {
  const AppButtonTheme({required this.baseElevatedButtonStyle});

  final ButtonStyle? baseElevatedButtonStyle;
}

final class AppButtonThemeLight extends AppButtonTheme {
  const AppButtonThemeLight._({required super.baseElevatedButtonStyle});

  static final AppButtonThemeLight instance = AppButtonThemeLight._(
    baseElevatedButtonStyle: ButtonStyle(
      backgroundColor:
          _buildBackgroundColor(nonDisabledStateColor: AppColors.white),
      shape: _buildOutlineBorder(
        borderSide: BorderSide(color: AppColorsLight.instance.primaryColor),
      ),
      minimumSize: WidgetStateProperty.all(const Size(_defaultButtonWidth, 0)),
      fixedSize: _buildFixedSize(),
      overlayColor:
          _buildOverlayColor(nonDisabledStateColor: AppColors.lightGrey),
      elevation: _buildDefaultElevation(),
      textStyle: _buildDefaultTextStyle(),
      foregroundColor: _buildForegroundColor(
        nonDisabledStateColor: AppColorsLight.instance.primaryColor,
      ),
    ),
  );

  static WidgetStateProperty<Color> _buildForegroundColor({
    required Color nonDisabledStateColor,
  }) =>
      WidgetStateProperty.resolveWith(
        (states) {
          final Color color;
          if (states.contains(WidgetState.disabled)) {
            color = AppColorsLight.instance.onPrimary.withOpacity(.5);
          } else {
            color = nonDisabledStateColor;
          }
          return color;
        },
      );

  static WidgetStateProperty<TextStyle?> _buildDefaultTextStyle() =>
      WidgetStateProperty.all(
        const TextStyle(
          fontFamily: FontFamily.consolas,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      );

  static WidgetStateProperty<double> _buildDefaultElevation() =>
      WidgetStateProperty.all(0);

  static WidgetStateProperty<Color?> _buildOverlayColor({
    required Color nonDisabledStateColor,
  }) =>
      WidgetStateProperty.resolveWith(
        (states) {
          Color? color;
          if (!states.contains(WidgetState.disabled)) {
            color = nonDisabledStateColor.withOpacity(.2);
          }
          return color;
        },
      );

  static WidgetStateProperty<Color> _buildBackgroundColor({
    required Color nonDisabledStateColor,
  }) =>
      WidgetStateProperty.resolveWith(
        (states) {
          final Color color;
          if (states.contains(WidgetState.disabled)) {
            color = AppColorsLight.instance.disabledButtonBackgroundColor;
          } else {
            color = nonDisabledStateColor;
          }
          return color;
        },
      );

  static WidgetStateProperty<Size> _buildFixedSize() =>
      WidgetStateProperty.all(const Size.fromHeight(_defaultButtonHeight));

  static WidgetStateProperty<OutlinedBorder> _buildOutlineBorder({
    BorderSide? borderSide,
  }) =>
      WidgetStateProperty.resolveWith(
        (states) {
          final RoundedRectangleBorder shape;
          if (states.contains(WidgetState.disabled)) {
            shape = RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_defaultButtonBorderRadius),
              side: BorderSide(
                color: AppColorsLight.instance.disabledBorderColor,
              ),
            );
          } else {
            shape = RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_defaultButtonBorderRadius),
              side: borderSide ?? BorderSide.none,
            );
          }
          return shape;
        },
      );

  @override
  ThemeExtension<AppButtonTheme> copyWith({
    ButtonStyle? mainElevatedButtonStyle,
    ButtonStyle? secondaryElevatedButtonStyle,
    ButtonStyle? baseElevatedButtonStyle,
  }) =>
      AppButtonThemeLight._(
        baseElevatedButtonStyle:
            baseElevatedButtonStyle ?? this.baseElevatedButtonStyle,
      );

  @override
  ThemeExtension<AppButtonTheme> lerp(
    covariant ThemeExtension<AppButtonTheme>? other,
    double t,
  ) {
    if (other == null) return this;
    if (other is! AppButtonTheme) return this;
    return AppButtonThemeLight._(
      baseElevatedButtonStyle: ButtonStyle.lerp(
        baseElevatedButtonStyle,
        other.baseElevatedButtonStyle,
        t,
      ),
    );
  }
}
