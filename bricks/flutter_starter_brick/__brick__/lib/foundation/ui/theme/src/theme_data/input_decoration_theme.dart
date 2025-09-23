import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';

OutlineInputBorder _buildTextFieldBorder({
  required Color color,
  double? borderWidth,
}) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(ThemeDefaults.borderRadiusSmall),
  borderSide: BorderSide(
    color: color,
    width: borderWidth ?? ThemeDefaults.borderWidth,
  ),
);

InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) =>
    InputDecorationTheme(
      enabledBorder: _buildTextFieldBorder(
        color: colorScheme.onSurface.withValues(alpha: ThemeDefaults.textFieldEnabledBorderOpacity),
      ),
      disabledBorder: _buildTextFieldBorder(
        color: colorScheme.onSurface.withValues(alpha: ThemeDefaults.materialDisabledOpacity),
      ),
      focusedBorder: _buildTextFieldBorder(color: colorScheme.primary),
      errorBorder: _buildTextFieldBorder(color: colorScheme.error),
      focusedErrorBorder: _buildTextFieldBorder(color: colorScheme.error),
    );
