import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/colors.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/theme_data.dart';

final ThemeData lightThemeData = themeData(_colorScheme);

// A nice resource to generate color schemes:
// https://material-foundation.github.io/material-theme-builder/

const ColorScheme _colorScheme = ColorScheme(
  brightness: Brightness.light,

  /* === Brand colours === */
  primary: primaryBlue,
  surfaceTint: primaryBlue,
  onPrimary: white,
  primaryContainer: primaryBlueContainer,
  onPrimaryContainer: darkSurface,

  secondary: secondaryTeal,
  onSecondary: white,
  secondaryContainer: secondaryTealContainer,
  onSecondaryContainer: Color(0xFF002D31),

  tertiary: tertiaryAmber,
  onTertiary: black,
  tertiaryContainer: tertiaryAmberContainer,
  onTertiaryContainer: Color(0xFF302100),

  /* === Errors === */
  error: errorRed,
  onError: white,
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  /* === Surfaces & backgrounds === */
  surface: lightSurface,
  onSurface: darkSurface,
  onSurfaceVariant: Color(0xFF4E5866),
  inverseSurface: darkSurface,
  inversePrimary: primaryBlue,
  surfaceDim: lightSurface,
  surfaceBright: white,
  surfaceContainerLowest: white,
  surfaceContainerLow: Color(0xFFF6F8FA),
  surfaceContainer: lightSurface,
  surfaceContainerHigh: Color(0xFFEDEFF2),
  surfaceContainerHighest: Color(0xFFE4E7EB),

  /* === Outlines / misc === */
  outline: outlineGrey,
  outlineVariant: Color(0xFFBFC6CF),
  shadow: black,
  scrim: black,

  /* === Fixed palette (Material 3 tonal elevation) === */
  primaryFixed: primaryBlueContainer,
  primaryFixedDim: primaryFixedDim,
  onPrimaryFixed: darkSurface,
  onPrimaryFixedVariant: onPrimaryFixedVariant,

  secondaryFixed: secondaryTealContainer,
  secondaryFixedDim: secondaryFixedDim,
  onSecondaryFixed: onSecondaryFixed,
  onSecondaryFixedVariant: onSecondaryFixedVariant,

  tertiaryFixed: tertiaryAmberContainer,
  tertiaryFixedDim: tertiaryFixedDim,
  onTertiaryFixed: onTertiaryFixed,
  onTertiaryFixedVariant: onTertiaryFixedVariant,
);
