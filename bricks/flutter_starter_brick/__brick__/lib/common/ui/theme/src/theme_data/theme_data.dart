import 'package:flutter/material.dart' hide ButtonTheme, Typography;

import 'typography.dart';
import 'input_decoration_theme.dart';
import 'elevated_button_theme_data.dart';
import 'text_button_theme_data.dart';
import 'text_selection_theme_data.dart';
import 'checkbox_theme_data.dart';
import 'divider_theme_data.dart';
import 'progress_indicator_theme_data.dart';
import 'scrollbar_theme_data.dart';
import 'dropdown_menu_theme_data.dart';

ThemeData themeData(ColorScheme colorScheme) => ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      canvasColor: colorScheme.surface,
      textSelectionTheme: textSelectionThemeData(colorScheme),
      checkboxTheme: checkboxThemeData(colorScheme),
      dividerTheme: dividerThemeData(colorScheme),
      progressIndicatorTheme: progressIndicatorThemeData(colorScheme),
      scrollbarTheme: scrollbarThemeData(colorScheme),
      elevatedButtonTheme: elevatedButtonThemeData(colorScheme),
      textButtonTheme: textButtonThemeData(colorScheme),
      inputDecorationTheme: inputDecorationTheme(colorScheme),
      dropdownMenuTheme: dropdownMenuThemeData(colorScheme),
      extensions: [
        Typography(colorScheme),
      ],
    );

extension ThemeDataBuildContextExtension on BuildContext {
  ThemeData get themeData => Theme.of(this);
}
