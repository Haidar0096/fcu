import 'package:flutter/material.dart';

CheckboxThemeData checkboxThemeData(ColorScheme colorScheme) =>
    CheckboxThemeData(
      checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      fillColor: WidgetStateProperty.resolveWith((states) {
        Color? color;
        if (states.contains(WidgetState.disabled)) {
          color = colorScheme.onSurface.withValues(alpha: 0.38);
        } else if (states.contains(WidgetState.selected)) {
          color = colorScheme.primary;
        } else if (!states.contains(WidgetState.selected)) {
          color = Colors.transparent;
        }
        return color;
      }),
      side: WidgetStateBorderSide.resolveWith((states) {
        BorderSide? borderSide;
        const width = 1.5;
        if (states.contains(WidgetState.disabled)) {
          borderSide = BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.38),
            width: width,
          );
        } else if (states.contains(WidgetState.selected)) {
          borderSide = BorderSide(color: colorScheme.primary, width: width);
        } else if (!states.contains(WidgetState.selected)) {
          borderSide = BorderSide(color: colorScheme.outline, width: width);
        }
        return borderSide;
      }),
    );
