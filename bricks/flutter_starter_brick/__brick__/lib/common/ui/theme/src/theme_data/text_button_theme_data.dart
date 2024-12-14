import 'package:{{proj_name}}/common/ui/theme/src/theme_data/defaults.dart';
import 'package:{{proj_name}}/common/ui/theme/src/theme_data/typography.dart';
import 'package:flutter/material.dart';

TextButtonThemeData textButtonThemeData(ColorScheme colorScheme) =>
    TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultButtonBorderRadius),
          ),
        ),
        minimumSize: const WidgetStatePropertyAll(
          Size(defaultButtonWidth, 0),
        ),
        fixedSize: const WidgetStatePropertyAll(
          Size.fromHeight(defaultButtonHeight),
        ),
        maximumSize: const WidgetStatePropertyAll(Size.infinite),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) return null;
            return colorScheme.primary.withOpacity(0.12);
          },
        ),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: WidgetStateProperty.all(
          Font.defaultTitleFont.textStyle(fontSize: 16),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return colorScheme.primary;
          },
        ),
      ),
    );
