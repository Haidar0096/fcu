import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/defaults.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/typography.dart';
import 'package:{{proj_name}}/resources/resources.dart';
import 'package:flutter/material.dart';

TextButtonThemeData textButtonThemeData(ColorScheme colorScheme) =>
    TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeDefaults.buttonBorderRadius,
            ),
          ),
        ),
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
