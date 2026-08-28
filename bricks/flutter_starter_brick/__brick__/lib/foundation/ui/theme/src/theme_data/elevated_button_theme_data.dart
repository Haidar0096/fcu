import 'package:flutter/material.dart' hide Typography;
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/typography.dart';
import 'package:{{proj_name}}/resources/resources.dart';

ElevatedButtonThemeData elevatedButtonThemeData(ColorScheme colorScheme) =>
    ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(
              alpha: ThemeDefaults.overlayAlpha,
            );
          }
          return colorScheme.surface;
        }),
        shape: WidgetStateProperty.resolveWith((states) {
          final borderSide = BorderSide(
            color:
                states.contains(WidgetState.disabled)
                    ? colorScheme.onSurface.withValues(
                      alpha: ThemeDefaults.overlayAlpha,
                    )
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
