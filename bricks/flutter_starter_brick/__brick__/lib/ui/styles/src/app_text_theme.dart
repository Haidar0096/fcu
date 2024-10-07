import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

final class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme._({
    required this.title5,
    required this.title4,
    required this.title3,
    required this.title2,
    required this.title1,
    required this.body5,
    required this.body4,
    required this.body3,
    required this.body2,
    required this.body1,
  });

  final TextStyle? title5;
  final TextStyle? title4;
  final TextStyle? title3;
  final TextStyle? title2;
  final TextStyle? title1;
  final TextStyle? body5;
  final TextStyle? body4;
  final TextStyle? body3;
  final TextStyle? body2;
  final TextStyle? body1;

  static const AppTextTheme instance = AppTextTheme._(
    title5: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w700,
      fontSize: 55,
    ),
    title4: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w700,
      fontSize: 50,
    ),
    title3: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w700,
      fontSize: 40,
    ),
    title2: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w700,
      fontSize: 35,
    ),
    title1: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w700,
      fontSize: 30,
    ),
    body5: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w400,
      fontSize: 30,
    ),
    body4: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w400,
      fontSize: 25,
    ),
    body3: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w400,
      fontSize: 20,
    ),
    body2: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w400,
      fontSize: 15,
    ),
    body1: TextStyle(
      fontFamily: FontFamily.consolas,
      fontWeight: FontWeight.w400,
      fontSize: 10,
    ),
  );

  @override
  ThemeExtension<AppTextTheme> copyWith({
    TextStyle? title5,
    TextStyle? title4,
    TextStyle? title3,
    TextStyle? title2,
    TextStyle? title1,
    TextStyle? body5,
    TextStyle? body4,
    TextStyle? body3,
    TextStyle? body2,
    TextStyle? body1,
  }) =>
      AppTextTheme._(
        title5: title5 ?? this.title5,
        title4: title4 ?? this.title4,
        title3: title3 ?? this.title3,
        title2: title2 ?? this.title2,
        title1: title1 ?? this.title1,
        body5: body5 ?? this.body5,
        body4: body4 ?? this.body4,
        body3: body3 ?? this.body3,
        body2: body2 ?? this.body2,
        body1: body1 ?? this.body1,
      );

  @override
  ThemeExtension<AppTextTheme> lerp(
    covariant ThemeExtension<AppTextTheme>? other,
    double t,
  ) {
    if (other == null) return this;
    if (other is! AppTextTheme) return this;
    return AppTextTheme._(
      title5: TextStyle.lerp(title5, other.title5, t),
      title4: TextStyle.lerp(title4, other.title4, t),
      title3: TextStyle.lerp(title3, other.title3, t),
      title2: TextStyle.lerp(title2, other.title2, t),
      title1: TextStyle.lerp(title1, other.title1, t),
      body5: TextStyle.lerp(body5, other.body5, t),
      body4: TextStyle.lerp(body4, other.body4, t),
      body3: TextStyle.lerp(body3, other.body3, t),
      body2: TextStyle.lerp(body2, other.body2, t),
      body1: TextStyle.lerp(body1, other.body1, t),
    );
  }
}
