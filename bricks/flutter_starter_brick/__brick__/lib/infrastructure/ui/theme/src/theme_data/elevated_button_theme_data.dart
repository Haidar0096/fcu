import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/defaults.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/typography.dart';
import 'package:{{proj_name}}/resources/resources.dart';
import 'package:flutter/material.dart';

ElevatedButtonThemeData elevatedButtonThemeData(ColorScheme colorScheme) =>
    ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.12);
          }
          return colorScheme.surface;
        }),
        shape: WidgetStateProperty.resolveWith((states) {
          final borderSide = BorderSide(
            color:
                states.contains(WidgetState.disabled)
                    ? colorScheme.onSurface.withValues(alpha: 0.12)
                    : colorScheme.onSurface,
            width: ThemeDefaults.borderWidth,
          );
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeDefaults.buttonBorderRadius,
            ),
            side: borderSide,
          );
        }),
        minimumSize: const WidgetStatePropertyAll(
          Size(ThemeDefaults.buttonWidth, 0),
        ),
        fixedSize: const WidgetStatePropertyAll(
          Size.fromHeight(ThemeDefaults.buttonHeight),
        ),
        maximumSize: const WidgetStatePropertyAll(Size.infinite),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return null;
          return colorScheme.primary.withValues(alpha: 0.12);
        }),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: WidgetStateProperty.all(
          Fonts.defaultTitleFont.textStyle(fontSize: 16),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          return colorScheme.primary;
        }),
      ),
    );
