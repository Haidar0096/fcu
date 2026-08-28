import 'package:flutter/material.dart' hide Typography;
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/typography.dart';
import 'package:{{proj_name}}/resources/resources.dart';

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
        maximumSize: const WidgetStatePropertyAll(
          Size(ThemeDefaults.buttonMaxWidth, double.infinity),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return null;
          return colorScheme.primary.withValues(
            alpha: ThemeDefaults.overlayAlpha,
          );
        }),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: WidgetStateProperty.all(
          Typography.defaultButtonFont.textStyle.copyWith(
            fontSize: ThemeDefaults.buttonTextSize,
          ),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(
              alpha: ThemeDefaults.materialDisabledOpacity,
            );
          }
          return colorScheme.primary;
        }),
      ),
    );
