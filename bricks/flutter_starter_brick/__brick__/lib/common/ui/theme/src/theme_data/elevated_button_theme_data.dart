import 'package:flutter/material.dart';
import 'typography.dart';
import 'package:{{proj_name}}/common/ui/theme/src/theme_data/defaults.dart';



ElevatedButtonThemeData elevatedButtonThemeData(ColorScheme colorScheme) =>
    ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            return colorScheme.surface;
          },
        ),
        shape: WidgetStateProperty.resolveWith(
          (states) {
            final borderSide = BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? colorScheme.onSurface.withOpacity(0.12)
                  : colorScheme.primary,
              width: 1.5,
            );
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultButtonBorderRadius),
              side: borderSide,
            );
          },
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
          Font.defaultTitleFont.textStyle(fontSize: 18),
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
