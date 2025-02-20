import 'package:{{proj_name}}/resources/resources.dart';
import 'package:flutter/material.dart';

/// Enum representing fonts used in the application.
///
/// This enum provides a centralized way to manage and access font data.
/// Each enum value corresponds to a specific font.
extension FontExtension on Fonts {
  TextStyle textStyle({double? fontSize, Color? color}) => TextStyle(
    fontFamily: fontFamilyName,
    fontStyle: fontStyle,
    fontWeight: fontWeight,
    fontSize: fontSize,
    color: color,
  );
}

final class Typography extends ThemeExtension<Typography> {
  factory Typography(ColorScheme colorScheme) => Typography._(
    title1: _titleStyle(fontSize: 50, colorScheme: colorScheme),
    title2: _titleStyle(fontSize: 44, colorScheme: colorScheme),
    title3: _titleStyle(fontSize: 38, colorScheme: colorScheme),
    title4: _titleStyle(fontSize: 32, colorScheme: colorScheme),
    title5: _titleStyle(fontSize: 26, colorScheme: colorScheme),
    title6: _titleStyle(fontSize: 20, colorScheme: colorScheme),
    title7: _titleStyle(fontSize: 16, colorScheme: colorScheme),
    body1: _bodyStyle(fontSize: 24, colorScheme: colorScheme),
    body2: _bodyStyle(fontSize: 22, colorScheme: colorScheme),
    body3: _bodyStyle(fontSize: 20, colorScheme: colorScheme),
    body4: _bodyStyle(fontSize: 18, colorScheme: colorScheme),
    body5: _bodyStyle(fontSize: 16, colorScheme: colorScheme),
    body6: _bodyStyle(fontSize: 14, colorScheme: colorScheme),
    body7: _bodyStyle(fontSize: 12, colorScheme: colorScheme),
    error: _errorStyle(colorScheme: colorScheme),
  );

  const Typography._({
    required this.title1,
    required this.title2,
    required this.title3,
    required this.title4,
    required this.title5,
    required this.title6,
    required this.title7,
    required this.body1,
    required this.body2,
    required this.body3,
    required this.body4,
    required this.body5,
    required this.body6,
    required this.body7,
    required this.error,
  });

  final TextStyle title1;
  final TextStyle title2;
  final TextStyle title3;
  final TextStyle title4;
  final TextStyle title5;
  final TextStyle title6;
  final TextStyle title7;
  final TextStyle body1;
  final TextStyle body2;
  final TextStyle body3;
  final TextStyle body4;
  final TextStyle body5;
  final TextStyle body6;
  final TextStyle body7;
  final TextStyle error;

  static TextStyle _titleStyle({
    required double fontSize,
    required ColorScheme colorScheme,
  }) => Fonts.defaultTitleFont.textStyle(
    fontSize: fontSize,
    color: colorScheme.onSurface,
  );

  static TextStyle _bodyStyle({
    required double fontSize,
    required ColorScheme colorScheme,
  }) => Fonts.defaultBodyFont.textStyle(
    fontSize: fontSize,
    color: colorScheme.onSurface,
  );

  static TextStyle _errorStyle({required ColorScheme colorScheme}) =>
      Fonts.defaultErrorFont.textStyle(color: colorScheme.error);

  @override
  ThemeExtension<Typography> copyWith({
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? title4,
    TextStyle? title5,
    TextStyle? title6,
    TextStyle? title7,
    TextStyle? body1,
    TextStyle? body2,
    TextStyle? body3,
    TextStyle? body4,
    TextStyle? body5,
    TextStyle? body6,
    TextStyle? body7,
    TextStyle? error,
  }) => Typography._(
    title1: title1 ?? this.title1,
    title2: title2 ?? this.title2,
    title3: title3 ?? this.title3,
    title4: title4 ?? this.title4,
    title5: title5 ?? this.title5,
    title6: title6 ?? this.title6,
    title7: title7 ?? this.title7,
    body1: body1 ?? this.body1,
    body2: body2 ?? this.body2,
    body3: body3 ?? this.body3,
    body4: body4 ?? this.body4,
    body5: body5 ?? this.body5,
    body6: body6 ?? this.body6,
    body7: body7 ?? this.body7,
    error: error ?? this.error,
  );

  @override
  ThemeExtension<Typography> lerp(
    covariant ThemeExtension<Typography>? other,
    double t,
  ) {
    if (other == null) return this;
    if (other is! Typography) return this;
    return Typography._(
      title1: TextStyle.lerp(title1, other.title1, t)!,
      title2: TextStyle.lerp(title2, other.title2, t)!,
      title3: TextStyle.lerp(title3, other.title3, t)!,
      title4: TextStyle.lerp(title4, other.title4, t)!,
      title5: TextStyle.lerp(title5, other.title5, t)!,
      title6: TextStyle.lerp(title6, other.title6, t)!,
      title7: TextStyle.lerp(title7, other.title7, t)!,
      body1: TextStyle.lerp(body1, other.body1, t)!,
      body2: TextStyle.lerp(body2, other.body2, t)!,
      body3: TextStyle.lerp(body3, other.body3, t)!,
      body4: TextStyle.lerp(body4, other.body4, t)!,
      body5: TextStyle.lerp(body5, other.body5, t)!,
      body6: TextStyle.lerp(body6, other.body6, t)!,
      body7: TextStyle.lerp(body7, other.body7, t)!,
      error: TextStyle.lerp(error, other.error, t)!,
    );
  }
}

extension TypographyBuildContextExtension on BuildContext {
  Typography? get typography => Theme.of(this).extension<Typography>();
}
