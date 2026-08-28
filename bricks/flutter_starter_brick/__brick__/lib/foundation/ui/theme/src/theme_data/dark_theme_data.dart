import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/colors.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/theme_data.dart';

final ThemeData darkThemeData = themeData(_darkColorScheme);

// A nice resource to generate color schemes:
// https://material-foundation.github.io/material-theme-builder/

const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  /* === Brand colours === */
  primary: primary,
  surfaceTint: primary,
  onPrimary: white,
  primaryContainer: onPrimaryFixedVariant,
  onPrimaryContainer: primaryContainer,

  secondary: secondaryTeal,
  onSecondary: white,
  secondaryContainer: onSecondaryFixedVariant,
  onSecondaryContainer: secondaryTealContainer,

  tertiary: tertiaryAmber,
  onTertiary: black,
  tertiaryContainer: onTertiaryFixedVariant,
  onTertiaryContainer: tertiaryAmberContainer,

  /* === Errors === */
  error: darkError,
  onError: darkOnError,
  errorContainer: darkErrorContainer,
  onErrorContainer: darkOnErrorContainer,

  /* === Surfaces & backgrounds === */
  surface: darkBackground,
  onSurface: white,
  onSurfaceVariant: outlineGrey, // Lighter gray for better contrast
  inverseSurface: lightSurface,
  inversePrimary: primary,
  surfaceDim: darkBackground,
  surfaceBright: mutedGray,
  surfaceContainerLowest: black,
  surfaceContainerLow: darkBackground,
  surfaceContainer: mutedGray,
  surfaceContainerHigh: darkSurfaceContainerHigh,
  surfaceContainerHighest: darkSurfaceContainerHighest,

  /* === Outlines / misc === */
  outline: outlineGrey,
  outlineVariant: darkGreyBubble,
  shadow: black,
  scrim: black,

  /* === Fixed palette (Material 3 tonal elevation) === */
  primaryFixed: primaryContainer,
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
