import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/colors.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/theme_data.dart';

final ThemeData lightThemeData = themeData(_colorScheme);

// A nice resource to generate color schemes:
// https://material-foundation.github.io/material-theme-builder/

const ColorScheme _colorScheme = ColorScheme(
  brightness: Brightness.light,

  /* === Brand colours === */
  primary: primary,
  surfaceTint: primary,
  onPrimary: white,
  primaryContainer: primaryContainer,
  onPrimaryContainer: darkSurface,

  secondary: secondaryTeal,
  onSecondary: white,
  secondaryContainer: secondaryTealContainer,
  onSecondaryContainer: onSecondaryFixed,

  tertiary: tertiaryAmber,
  onTertiary: black,
  tertiaryContainer: tertiaryAmberContainer,
  onTertiaryContainer: onTertiaryFixed,

  /* === Errors === */
  error: errorRed,
  onError: white,
  errorContainer: lightErrorContainer,
  onErrorContainer: lightOnErrorContainer,

  /* === Surfaces & backgrounds === */
  surface: lightSurface,
  onSurface: darkSurface,
  onSurfaceVariant: lightOnSurfaceVariant,
  inverseSurface: darkSurface,
  inversePrimary: primary,
  surfaceDim: lightSurface,
  surfaceBright: white,
  surfaceContainerLowest: white,
  surfaceContainerLow: lightSurfaceContainerLow,
  surfaceContainer: lightSurface,
  surfaceContainerHigh: lightSurfaceContainerHigh,
  surfaceContainerHighest: lightSurfaceContainerHighest,

  /* === Outlines / misc === */
  outline: outlineGrey,
  outlineVariant: lightOutlineVariant,
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
