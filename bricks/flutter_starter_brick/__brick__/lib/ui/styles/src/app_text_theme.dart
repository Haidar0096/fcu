import 'package:{{proj_name}}/ui/styles/src/app_colors_theme.dart';
import 'package:{{proj_name}}/ui/styles/src/font_family.dart';
import 'package:flutter/material.dart';

/// Defines the text styles for the application.
sealed class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme({
    required this.title1,
    required this.title2,
    required this.title3,
    required this.title4,
    required this.title5,
    required this.title6,
    required this.body1,
    required this.body2,
    required this.body3,
    required this.body4,
    required this.body5,
    required this.body6,
  });

  /// Largest title style
  final TextStyle title1;

  /// Second largest title style
  final TextStyle title2;

  /// Third largest title style
  final TextStyle title3;

  /// Fourth largest title style
  final TextStyle title4;

  /// Fifth largest title style
  final TextStyle title5;

  /// Smallest title style
  final TextStyle title6;

  /// Largest body text style
  final TextStyle body1;

  /// Second largest body text style
  final TextStyle body2;

  /// Third largest body text style
  final TextStyle body3;

  /// Fourth largest body text style
  final TextStyle body4;

  /// Fifth largest body text style
  final TextStyle body5;

  /// Smallest body text style
  final TextStyle body6;
}

/// Light theme implementation of [AppTextTheme].
final class AppTextThemeLight extends AppTextTheme {
  const AppTextThemeLight._({
    required super.title1,
    required super.title2,
    required super.title3,
    required super.title4,
    required super.title5,
    required super.title6,
    required super.body1,
    required super.body2,
    required super.body3,
    required super.body4,
    required super.body5,
    required super.body6,
  });

  static const Color _textColor = AppColorsTheme.black;

  /// Singleton instance of [AppTextThemeLight].
  static AppTextThemeLight instance = AppTextThemeLight._(
    title1: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w700,
      fontSize: 50,
      color: _textColor,
    ),
    title2: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w700,
      fontSize: 44,
      color: _textColor,
    ),
    title3: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w700,
      fontSize: 38,
      color: _textColor,
    ),
    title4: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: _textColor,
    ),
    title5: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w700,
      fontSize: 26,
      color: _textColor,
    ),
    title6: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: _textColor,
    ),
    body1: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w400,
      fontSize: 24,
      color: _textColor,
    ),
    body2: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w400,
      fontSize: 22,
      color: _textColor,
    ),
    body3: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w400,
      fontSize: 20,
      color: _textColor,
    ),
    body4: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w400,
      fontSize: 18,
      color: _textColor,
    ),
    body5: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: _textColor,
    ),
    body6: TextStyle(
      fontFamily: FontFamily.consolas.name,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: _textColor,
    ),
  );

  /// Creates a copy of this [AppTextThemeLight] but with the given fields
  /// replaced with the new values.
  @override
  ThemeExtension<AppTextTheme> copyWith({
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? title4,
    TextStyle? title5,
    TextStyle? title6,
    TextStyle? body1,
    TextStyle? body2,
    TextStyle? body3,
    TextStyle? body4,
    TextStyle? body5,
    TextStyle? body6,
  }) =>
      AppTextThemeLight._(
        title1: title1 ?? this.title1,
        title2: title2 ?? this.title2,
        title3: title3 ?? this.title3,
        title4: title4 ?? this.title4,
        title5: title5 ?? this.title5,
        title6: title6 ?? this.title6,
        body1: body1 ?? this.body1,
        body2: body2 ?? this.body2,
        body3: body3 ?? this.body3,
        body4: body4 ?? this.body4,
        body5: body5 ?? this.body5,
        body6: body6 ?? this.body6,
      );

  /// Linearly interpolate between two [AppTextTheme]s.
  @override
  ThemeExtension<AppTextTheme> lerp(
    covariant ThemeExtension<AppTextTheme>? other,
    double t,
  ) {
    if (other == null) return this;
    if (other is! AppTextThemeLight) return this;
    return AppTextThemeLight._(
      title1: TextStyle.lerp(title1, other.title1, t)!,
      title2: TextStyle.lerp(title2, other.title2, t)!,
      title3: TextStyle.lerp(title3, other.title3, t)!,
      title4: TextStyle.lerp(title4, other.title4, t)!,
      title5: TextStyle.lerp(title5, other.title5, t)!,
      title6: TextStyle.lerp(title6, other.title6, t)!,
      body1: TextStyle.lerp(body1, other.body1, t)!,
      body2: TextStyle.lerp(body2, other.body2, t)!,
      body3: TextStyle.lerp(body3, other.body3, t)!,
      body4: TextStyle.lerp(body4, other.body4, t)!,
      body5: TextStyle.lerp(body5, other.body5, t)!,
      body6: TextStyle.lerp(body6, other.body6, t)!,
    );
  }
}
