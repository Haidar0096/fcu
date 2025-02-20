import 'package:flutter/material.dart';

TextSelectionThemeData textSelectionThemeData(ColorScheme colorScheme) =>
    TextSelectionThemeData(
      cursorColor: colorScheme.primary,
      selectionHandleColor: colorScheme.primary,
      selectionColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
    );
