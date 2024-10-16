import 'package:{{proj_name}}/ui/styles/src/app_colors_theme.dart';
import 'package:flutter/material.dart';

const double _defaultBorderWidth = 1;
const double _defaultBorderRadius = 8;

OutlineInputBorder _buildTextFieldBorder({
  required Color color,
  double? borderRadius,
  double? borderWidth,
}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? _defaultBorderRadius),
      borderSide: BorderSide(
        color: color,
        width: borderWidth ?? _defaultBorderWidth,
      ),
    );

sealed class AppTextFieldTheme extends ThemeExtension<AppTextFieldTheme> {
  const AppTextFieldTheme({
    required this.enabledBorder,
    required this.disabledBorder,
    required this.focusedBorder,
    required this.errorBorder,
    required this.focusedErrorBorder,
  });

  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
}

final class AppTextFieldThemeLight extends AppTextFieldTheme {
  const AppTextFieldThemeLight._({
    super.enabledBorder,
    super.disabledBorder,
    super.focusedBorder,
    super.errorBorder,
    super.focusedErrorBorder,
  });

  static final AppTextFieldThemeLight instance = AppTextFieldThemeLight._(
    enabledBorder: _buildTextFieldBorder(
      color: AppColorsThemeLight.instance.enabledBorderColor,
    ),
    disabledBorder: _buildTextFieldBorder(
      color: AppColorsThemeLight.instance.disabledBorderColor,
    ),
    focusedBorder: _buildTextFieldBorder(
      color: AppColorsThemeLight.instance.focusedBorderColor,
    ),
    errorBorder: _buildTextFieldBorder(
      color: AppColorsThemeLight.instance.errorBorderColor,
    ),
    focusedErrorBorder: _buildTextFieldBorder(
      color: AppColorsThemeLight.instance.focusedErrorBorderColor,
    ),
  );

  @override
  ThemeExtension<AppTextFieldTheme> copyWith({
    InputBorder? enabledBorder,
    InputBorder? disabledBorder,
    InputBorder? focusedBorder,
    InputBorder? errorBorder,
    InputBorder? focusedErrorBorder,
  }) =>
      AppTextFieldThemeLight._(
        enabledBorder: enabledBorder ?? this.enabledBorder,
        disabledBorder: disabledBorder ?? this.disabledBorder,
        focusedBorder: focusedBorder ?? this.focusedBorder,
        errorBorder: errorBorder ?? this.errorBorder,
        focusedErrorBorder: focusedErrorBorder ?? this.focusedErrorBorder,
      );

  @override
  ThemeExtension<AppTextFieldTheme> lerp(
    covariant ThemeExtension<AppTextFieldTheme>? other,
    double t,
  ) {
    if (other == null) return this;
    if (other is! AppTextFieldTheme) return this;
    if (t < 0.5) return this;
    return other;
  }
}
