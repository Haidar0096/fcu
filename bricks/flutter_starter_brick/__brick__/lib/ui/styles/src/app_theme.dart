import 'package:{{proj_name}}/ui/styles/src/app_button_theme.dart';
import 'package:{{proj_name}}/ui/styles/src/app_colors_theme.dart';
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
          AppTextThemeLight.instance,
          AppTextFieldThemeLight.instance,
          AppButtonThemeLight.instance,
          AppDropdownMenuThemeLight.instance,
          AppColorsThemeLight.instance,
        ],
      );

  ScrollbarThemeData _lightScrollbarThemeData() => const ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(10),
        radius: Radius.circular(20),
      );

  DividerThemeData _lightDividerThemeData() => DividerThemeData(
        thickness: 1,
        color: AppColorsThemeLight.instance.dividerColor,
      );

  ColorScheme _lightColorScheme() => ColorScheme.fromSeed(
        seedColor: AppColorsThemeLight.instance.primaryColor,
        primary: AppColorsThemeLight.instance.primaryColor,
        secondary: AppColorsThemeLight.instance.secondaryColor,
        onPrimary: AppColorsThemeLight.instance.onPrimary,
        onSecondary: AppColorsThemeLight.instance.onSecondary,
        surface: AppColorsThemeLight.instance.background,
      );

  TextSelectionThemeData _lightTextSelectionThemeData() =>
      TextSelectionThemeData(
        cursorColor: AppColorsThemeLight.instance.cursorColor,
        selectionHandleColor: AppColorsThemeLight.instance.selectionHandleColor,
        selectionColor: AppColorsThemeLight.instance.selectionColor,
      );

  CheckboxThemeData _lightCheckboxThemeData() => CheckboxThemeData(
        checkColor: WidgetStateProperty.all(
          AppColorsThemeLight.instance.checkboxCheckColor,
        ),
        fillColor: WidgetStateProperty.resolveWith(
          (states) {
            Color? color;
            if (states.contains(WidgetState.disabled)) {
              color = AppColorsThemeLight.instance.disabledCheckboxFillColor;
            } else if (states.contains(WidgetState.selected)) {
              color = AppColorsThemeLight.instance.selectedCheckboxFillColor;
            } else if (!states.contains(WidgetState.selected)) {
              color = AppColorsThemeLight.instance.unSelectedCheckboxFillColor;
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
                color: AppColorsThemeLight.instance.disabledBorderColor,
                width: width,
              );
            } else if (states.contains(WidgetState.selected)) {
              borderSide = BorderSide(
                color: AppColorsThemeLight.instance.focusedBorderColor,
                width: width,
              );
            } else if (!states.contains(WidgetState.selected)) {
              borderSide = BorderSide(
                color: AppColorsThemeLight.instance.enabledBorderColor,
                width: width,
              );
            }
            return borderSide;
          },
        ),
      );

  ProgressIndicatorThemeData _lightProgressIndicatorThemeData() =>
      ProgressIndicatorThemeData(
        color: AppColorsThemeLight.instance.progressIndicatorColor,
      );
}
