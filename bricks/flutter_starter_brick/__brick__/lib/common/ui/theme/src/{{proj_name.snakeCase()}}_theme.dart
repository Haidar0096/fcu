import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/ui/theme/src/theme_data/light_theme_data.dart';
import 'package:{{proj_name}}/common/ui/theme/src/theme_data/dark_theme_data.dart';

sealed class {{proj_name.pascalCase()}}Theme {
  const {{proj_name.pascalCase()}}Theme();

  ThemeData get themeData;
}

final class {{proj_name.pascalCase()}}ThemeLight extends {{proj_name.pascalCase()}}Theme {
  const {{proj_name.pascalCase()}}ThemeLight._();

  static const {{proj_name.pascalCase()}}ThemeLight instance =
      {{proj_name.pascalCase()}}ThemeLight._();

  @override
  ThemeData get themeData => lightThemeData;
}

final class {{proj_name.pascalCase()}}ThemeDark extends {{proj_name.pascalCase()}}Theme {
  const {{proj_name.pascalCase()}}ThemeDark._();

  static const {{proj_name.pascalCase()}}ThemeDark instance =
      {{proj_name.pascalCase()}}ThemeDark._();

  @override
  ThemeData get themeData => darkThemeData;
}
