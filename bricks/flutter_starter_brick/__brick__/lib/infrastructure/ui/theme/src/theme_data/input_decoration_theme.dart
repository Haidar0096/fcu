import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/defaults.dart';
import 'package:flutter/material.dart';

UnderlineInputBorder _buildTextFieldBorder({
  required Color color,
  double? borderWidth,
}) => UnderlineInputBorder(
  borderSide: BorderSide(
    color: color,
    width: borderWidth ?? ThemeDefaults.borderWidth,
  ),
);

InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) =>
    InputDecorationTheme(
      enabledBorder: _buildTextFieldBorder(
        color: colorScheme.onSurface.withValues(alpha: 0.2),
      ),
      disabledBorder: _buildTextFieldBorder(
        color: colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      focusedBorder: _buildTextFieldBorder(color: colorScheme.primary),
      errorBorder: _buildTextFieldBorder(color: colorScheme.error),
      focusedErrorBorder: _buildTextFieldBorder(color: colorScheme.error),
    );
