import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/colors.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/theme_data.dart';
import 'package:flutter/material.dart';

final ThemeData lightThemeData = themeData(_colorScheme);

// A nice resource to generate color schemes:
// https://material-foundation.github.io/material-theme-builder/

const ColorScheme _colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xff755b00),
  surfaceTint: Color(0xff755b00),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffffd250),
  onPrimaryContainer: Color(0xff513f00),
  secondary: Color(0xff715c1e),
  onSecondary: Color(0xffffffff),
  secondaryContainer: Color(0xffffe196),
  onSecondaryContainer: Color(0xff5a4607),
  tertiary: Color(0xff536500),
  onTertiary: Color(0xffffffff),
  tertiaryContainer: Color(0xffc6e451),
  onTertiaryContainer: Color(0xff394600),
  error: errorRed,
  onError: Color(0xffffffff),
  errorContainer: Color(0xffffdad6),
  onErrorContainer: Color(0xff410002),
  surface: Color(0xffffffff),
  onSurface: Color(0xff201b10),
  onSurfaceVariant: Color(0xff4e4632),
  outline: Color(0xff80765f),
  outlineVariant: Color(0xffd2c5ab),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xff353024),
  inversePrimary: Color(0xfff3c000),
  primaryFixed: Color(0xffffe08f),
  onPrimaryFixed: Color(0xff241a00),
  primaryFixedDim: Color(0xfff3c000),
  onPrimaryFixedVariant: Color(0xff584400),
  secondaryFixed: Color(0xfffee094),
  onSecondaryFixed: Color(0xff241a00),
  secondaryFixedDim: Color(0xffe0c47b),
  onSecondaryFixedVariant: Color(0xff584405),
  tertiaryFixed: Color(0xffd1f05b),
  onTertiaryFixed: Color(0xff171e00),
  tertiaryFixedDim: Color(0xffb5d342),
  onTertiaryFixedVariant: Color(0xff3e4c00),
  surfaceDim: Color(0xfffafafa),
  surfaceBright: Color(0xffffffff),
  surfaceContainerLowest: Color(0xffffffff),
  surfaceContainerLow: Color(0xfffafafa),
  surfaceContainer: Color(0xfff5f5f5),
  surfaceContainerHigh: Color(0xfff0f0f0),
  surfaceContainerHighest: Color(0xffebebeb),
);
