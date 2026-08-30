import 'package:flutter/material.dart' hide Typography;
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/typography.dart';
import 'package:{{proj_name}}/resources/resources.dart';

DropdownMenuThemeData dropdownMenuThemeData(ColorScheme colorScheme) =>
    DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: _buildDropdownMenuBorder(color: colorScheme.outline),
        disabledBorder: _buildDropdownMenuBorder(
          color: colorScheme.outline.withValues(
            alpha: ThemeDefaults.materialDisabledOpacity,
          ),
        ),
        focusedBorder: _buildDropdownMenuBorder(color: colorScheme.primary),
        errorBorder: _buildDropdownMenuBorder(color: colorScheme.error),
        focusedErrorBorder: _buildDropdownMenuBorder(color: colorScheme.error),
      ),
      textStyle: Typography.defaultDropdownFont.textStyle.copyWith(
        fontSize: 14,
        color: colorScheme.onSurface,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeDefaults.borderRadiusSmall,
            ),
            side: BorderSide(
              color: colorScheme.outlineVariant,
              width: ThemeDefaults.borderWidth,
            ),
          ),
        ),
      ),
    );

OutlineInputBorder _buildDropdownMenuBorder({
  required Color color,
  double? borderRadius,
  double? borderWidth,
}) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(
    borderRadius ?? ThemeDefaults.borderRadiusSmall,
  ),
  borderSide: BorderSide(
    color: color,
    width: borderWidth ?? ThemeDefaults.borderWidth,
  ),
);
