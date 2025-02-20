import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/checkbox_theme_data.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/divider_theme_data.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/dropdown_menu_theme_data.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/elevated_button_theme_data.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/input_decoration_theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/progress_indicator_theme_data.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/scrollbar_theme_data.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/text_button_theme_data.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/text_selection_theme_data.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/theme_data/typography.dart';
import 'package:flutter/material.dart' hide ButtonTheme, Typography;

ThemeData themeData(ColorScheme colorScheme) => ThemeData(
  useMaterial3: true,
  brightness: colorScheme.brightness,
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.surface,
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
  extensions: [Typography(colorScheme)],
);

extension ThemeDataBuildContextExtension on BuildContext {
  ThemeData get themeData => Theme.of(this);
}

extension ThemeDataExtension on ThemeData {
  Color get defaultScrim => colorScheme.scrim.withValues(alpha: 0.32);
}
