import 'package:{{proj_name}}/ui/styles/src/app_colors.dart';
import 'package:flutter/material.dart';

const double _defaultBorderWidth = 1;
const double _defaultBorderRadius = 8;

OutlineInputBorder _buildDropdownMenuBorder({
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

sealed class AppDropdownMenuTheme extends ThemeExtension<AppDropdownMenuTheme> {
  const AppDropdownMenuTheme({
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

final class AppDropdownMenuThemeLight extends AppDropdownMenuTheme {
  const AppDropdownMenuThemeLight._({
    super.enabledBorder,
    super.disabledBorder,
    super.focusedBorder,
    super.errorBorder,
    super.focusedErrorBorder,
  });

  static final AppDropdownMenuThemeLight instance = AppDropdownMenuThemeLight._(
    enabledBorder: _buildDropdownMenuBorder(
      color: AppColorsLight.instance.enabledBorderColor,
    ),
    disabledBorder: _buildDropdownMenuBorder(
      color: AppColorsLight.instance.disabledBorderColor,
    ),
    focusedBorder: _buildDropdownMenuBorder(
      color: AppColorsLight.instance.focusedBorderColor,
    ),
    errorBorder: _buildDropdownMenuBorder(
      color: AppColorsLight.instance.errorBorderColor,
    ),
    focusedErrorBorder: _buildDropdownMenuBorder(
      color: AppColorsLight.instance.focusedErrorBorderColor,
    ),
  );

  @override
  ThemeExtension<AppDropdownMenuTheme> copyWith({
    InputBorder? enabledBorder,
    InputBorder? disabledBorder,
    InputBorder? focusedBorder,
    InputBorder? errorBorder,
    InputBorder? focusedErrorBorder,
  }) =>
      AppDropdownMenuThemeLight._(
        enabledBorder: enabledBorder ?? this.enabledBorder,
        disabledBorder: disabledBorder ?? this.disabledBorder,
        focusedBorder: focusedBorder ?? this.focusedBorder,
        errorBorder: errorBorder ?? this.errorBorder,
        focusedErrorBorder: focusedErrorBorder ?? this.focusedErrorBorder,
      );

  @override
  ThemeExtension<AppDropdownMenuTheme> lerp(
    covariant ThemeExtension<AppDropdownMenuTheme>? other,
    double t,
  ) {
    if (other == null) return this;
    if (other is! AppDropdownMenuTheme) return this;
    // TODO(dev): this lerp can be improved by providing more smoother
    // transition between the old and new values of the AppDropdownMenuTheme
    if (t < 0.5) return this;
    return other;
  }
}
