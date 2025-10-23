import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';

TextSelectionThemeData textSelectionThemeData(ColorScheme colorScheme) {
  final cursorColor =
      colorScheme.brightness == Brightness.dark
          ? colorScheme
              .onSurface // White in dark theme
          : colorScheme.primary; // Blue in light theme

  return TextSelectionThemeData(
    cursorColor: cursorColor,
    selectionHandleColor: colorScheme.primary,
    selectionColor: colorScheme.primaryContainer.withValues(
      alpha: ThemeDefaults.textSelectionOpacity,
    ),
  );
}
