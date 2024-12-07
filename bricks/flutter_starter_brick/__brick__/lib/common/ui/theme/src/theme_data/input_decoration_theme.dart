import 'package:flutter/material.dart';

const double _defaultBorderWidth = 1;
const double _defaultBorderRadius = 8;

OutlineInputBorder _buildTextFieldBorder({
  required Color color,
  double? borderRadius,
  double? borderWidth,
}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? _defaultBorderRadius),
      borderSide: BorderSide(
        color: color,
        width: borderWidth ?? _defaultBorderWidth,
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
