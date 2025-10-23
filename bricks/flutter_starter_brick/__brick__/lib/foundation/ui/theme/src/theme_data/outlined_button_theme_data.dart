import 'package:flutter/material.dart' hide Typography;
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/typography.dart';
import 'package:{{proj_name}}/resources/resources.dart';

OutlinedButtonThemeData outlinedButtonThemeData(ColorScheme colorScheme) =>
    OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStateProperty.resolveWith((states) {
          final borderSide = BorderSide(
            color:
                states.contains(WidgetState.disabled)
                    ? colorScheme.onSurface.withValues(
                      alpha: ThemeDefaults.buttonDisabledOverlayAlpha,
                    )
                    : colorScheme.primary,
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
            alpha: ThemeDefaults.buttonDisabledOverlayAlpha,
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
