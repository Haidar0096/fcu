import 'package:{{proj_name}}/ui/styles/src/app_button_theme.dart';
import 'package:{{proj_name}}/ui/styles/src/app_colors.dart';
import 'package:{{proj_name}}/ui/styles/src/app_dropdown_menu_theme.dart';
import 'package:{{proj_name}}/ui/styles/src/app_text_field_theme.dart';
import 'package:{{proj_name}}/ui/styles/src/app_text_theme.dart';
import 'package:flutter/material.dart';

sealed class AppTheme {
  const AppTheme();

  ThemeData get themeData;
}

class AppThemeLight extends AppTheme {
  const AppThemeLight._();

  static const AppThemeLight instance = AppThemeLight._();

  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme(),
        textSelectionTheme: _lightTextSelectionThemeData(),
        checkboxTheme: _lightCheckboxThemeData(),
        dividerTheme: _lightDividerThemeData(),
        progressIndicatorTheme: _lightProgressIndicatorThemeData(),
        scrollbarTheme: _lightScrollbarThemeData(),
        extensions: [
          AppTextTheme.instance,
          AppTextFieldThemeLight.instance,
          AppButtonThemeLight.instance,
          AppDropdownMenuThemeLight.instance,
        ],
      );

  ScrollbarThemeData _lightScrollbarThemeData() => const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(10),
        radius: Radius.circular(20),
      );

  DividerThemeData _lightDividerThemeData() => DividerThemeData(
        thickness: 1,
        color: AppColorsLight.instance.dividerColor,
      );

  ColorScheme _lightColorScheme() => ColorScheme.fromSeed(
        seedColor: AppColorsLight.instance.primaryColor,
        primary: AppColorsLight.instance.primaryColor,
        secondary: AppColorsLight.instance.secondaryColor,
        onPrimary: AppColorsLight.instance.onPrimary,
        onSecondary: AppColorsLight.instance.onSecondary,
        surface: AppColorsLight.instance.background,
      );

  TextSelectionThemeData _lightTextSelectionThemeData() =>
      TextSelectionThemeData(
        cursorColor: AppColorsLight.instance.cursorColor,
        selectionHandleColor: AppColorsLight.instance.selectionHandleColor,
        selectionColor: AppColorsLight.instance.selectionColor,
      );

  CheckboxThemeData _lightCheckboxThemeData() => CheckboxThemeData(
        checkColor:
            WidgetStateProperty.all(AppColorsLight.instance.checkboxCheckColor),
        fillColor: WidgetStateProperty.resolveWith(
          (states) {
            Color? color;
            if (states.contains(WidgetState.disabled)) {
              color = AppColorsLight.instance.disabledCheckboxFillColor;
            } else if (states.contains(WidgetState.selected)) {
              color = AppColorsLight.instance.selectedCheckboxFillColor;
            } else if (!states.contains(WidgetState.selected)) {
              color = AppColorsLight.instance.unSelectedCheckboxFillColor;
            }
            return color;
          },
        ),
        side: WidgetStateBorderSide.resolveWith(
          (states) {
            BorderSide? borderSide;
            const width = 1.5;
            if (states.contains(WidgetState.disabled)) {
              borderSide = BorderSide(
                color: AppColorsLight.instance.disabledBorderColor,
                width: width,
              );
            } else if (states.contains(WidgetState.selected)) {
              borderSide = BorderSide(
                color: AppColorsLight.instance.focusedBorderColor,
                width: width,
              );
            } else if (!states.contains(WidgetState.selected)) {
              borderSide = BorderSide(
                color: AppColorsLight.instance.enabledBorderColor,
                width: width,
              );
            }
            return borderSide;
          },
        ),
      );

  ProgressIndicatorThemeData _lightProgressIndicatorThemeData() =>
      ProgressIndicatorThemeData(
        color: AppColorsLight.instance.progressIndicatorColor,
      );
}
