import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/typography.dart';
import 'package:{{proj_name}}/resources/resources.dart';
import 'package:flutter/material.dart';

DropdownMenuThemeData dropdownMenuThemeData(ColorScheme colorScheme) =>
    DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: _buildDropdownMenuBorder(color: colorScheme.outline),
        disabledBorder: _buildDropdownMenuBorder(
          color: colorScheme.outline.withValues(alpha: 0.38),
        ),
        focusedBorder: _buildDropdownMenuBorder(color: colorScheme.primary),
        errorBorder: _buildDropdownMenuBorder(color: colorScheme.error),
        focusedErrorBorder: _buildDropdownMenuBorder(color: colorScheme.error),
      ),
      textStyle: Fonts.defaultBodyFont.textStyle(
        fontSize: 18,
        color: colorScheme.onSurface,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(_defaultBorderRadius),
            ),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),
    );

const double _defaultBorderWidth = 1;
const double _defaultBorderRadius = 8;

OutlineInputBorder _buildDropdownMenuBorder({
  required Color color,
  double? borderRadius,
  double? borderWidth,
}) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(borderRadius ?? _defaultBorderRadius),
  borderSide: BorderSide(
    color: color,
    width: borderWidth ?? _defaultBorderWidth,
  ),
);
