import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/ui/theme/src/theme_data/defaults.dart';

OutlineInputBorder _buildTextFieldBorder({
  required Color color,
  BorderRadius? borderRadius,
  double? borderWidth,
}) =>
    OutlineInputBorder(
      borderRadius: borderRadius ?? defaultInputFieldBorderRadius,
      borderSide: BorderSide(
        color: color,
        width: borderWidth ?? defaultInputBorderWidth,
      ),
    );

InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) =>
    InputDecorationTheme(
      enabledBorder: _buildTextFieldBorder(color: colorScheme.onSurface),
      disabledBorder: _buildTextFieldBorder(
        color: colorScheme.onSurface.withOpacity(0.38),
      ),
      focusedBorder: _buildTextFieldBorder(color: colorScheme.primary),
      errorBorder: _buildTextFieldBorder(color: colorScheme.error),
      focusedErrorBorder: _buildTextFieldBorder(color: colorScheme.error),
    );
