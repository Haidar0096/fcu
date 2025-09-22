import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/colors.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/theme_data.dart';

final ThemeData darkThemeData = themeData(_darkColorScheme);

// A nice resource to generate color schemes:
// https://material-foundation.github.io/material-theme-builder/

const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  /* === Brand colours === */
  primary: primaryBlue,
  surfaceTint: primaryBlue,
  onPrimary: white,
  primaryContainer: Color(0xFF24315D),
  onPrimaryContainer: primaryBlueContainer,

  secondary: secondaryTeal,
  onSecondary: white,
  secondaryContainer: Color(0xFF004D54),
  onSecondaryContainer: secondaryTealContainer,

  tertiary: tertiaryAmber,
  onTertiary: black,
  tertiaryContainer: Color(0xFF6E4B00),
  onTertiaryContainer: tertiaryAmberContainer,

  /* === Errors === */
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  /* === Surfaces & backgrounds === */
  surface: darkBackground,
  onSurface: white,
  onSurfaceVariant: outlineGrey, // Lighter gray for better contrast
  inverseSurface: lightSurface,
  inversePrimary: primaryBlue,
  surfaceDim: darkBackground,
  surfaceBright: mutedGray,
  surfaceContainerLowest: black,
  surfaceContainerLow: darkBackground,
  surfaceContainer: mutedGray,
  surfaceContainerHigh: Color(0xFF2A2E35),
  surfaceContainerHighest: Color(0xFF343941),

  /* === Outlines / misc === */
  outline: outlineGrey,
  outlineVariant: darkGreyBubble,
  shadow: black,
  scrim: black,

  /* === Fixed palette (Material 3 tonal elevation) === */
  primaryFixed: primaryBlueContainer,
  primaryFixedDim: Color(0xFF8E9DE1),
  onPrimaryFixed: darkSurface,
  onPrimaryFixedVariant: Color(0xFF24315D),

  secondaryFixed: secondaryTealContainer,
  secondaryFixedDim: Color(0xFF5EABB2),
  onSecondaryFixed: Color(0xFF002D31),
  onSecondaryFixedVariant: Color(0xFF004D54),

  tertiaryFixed: tertiaryAmberContainer,
  tertiaryFixedDim: Color(0xFFFFC46F),
  onTertiaryFixed: Color(0xFF302100),
  onTertiaryFixedVariant: Color(0xFF6E4B00),
);
