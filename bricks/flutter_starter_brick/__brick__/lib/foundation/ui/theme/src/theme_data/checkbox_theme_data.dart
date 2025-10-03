import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';

CheckboxThemeData checkboxThemeData(ColorScheme colorScheme) =>
    CheckboxThemeData(
      checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      fillColor: WidgetStateProperty.resolveWith((states) {
        Color? color;
        if (states.contains(WidgetState.disabled)) {
          color = colorScheme.onSurface.withValues(
            alpha: ThemeDefaults.materialDisabledOpacity,
          );
        } else if (states.contains(WidgetState.selected)) {
          color = colorScheme.primary;
        } else if (!states.contains(WidgetState.selected)) {
          color = Colors.transparent;
        }
        return color;
      }),
      side: WidgetStateBorderSide.resolveWith((states) {
        BorderSide? borderSide;
        const width = ThemeDefaults.checkboxBorderWidth;
        if (states.contains(WidgetState.disabled)) {
          borderSide = BorderSide(
            color: colorScheme.onSurface.withValues(
              alpha: ThemeDefaults.materialDisabledOpacity,
            ),
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
