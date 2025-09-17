import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/{{proj_name.snakeCase()}}_theme.dart';

/// Manages the theme of the app.
class ThemeCubit extends HydratedCubit<{{proj_name.pascalCase()}}Theme> {
  ThemeCubit({
    required AppLogger appLogger,
    {{proj_name.pascalCase()}}Theme? initialTheme,
  }) : _appLogger = appLogger,
       super(initialTheme ?? {{proj_name.pascalCase()}}ThemeLight.instance);

  final AppLogger _appLogger;
  static const String _tag = 'ThemeCubit';

  /// Sets the theme to the given theme.
  void setTheme({{proj_name.pascalCase()}}Theme theme) {
    final themeName = switch (theme) {
      {{proj_name.pascalCase()}}ThemeLight() => 'light',
      {{proj_name.pascalCase()}}ThemeDark() => 'dark',
    };
    _appLogger.log('Setting theme to: $themeName', tag: _tag);
    emit(theme);
  }

  @override
  {{proj_name.pascalCase()}}Theme? fromJson(Map<String, dynamic> json) => switch (json['theme']) {
    'light' => {{proj_name.pascalCase()}}ThemeLight.instance,
    'dark' => {{proj_name.pascalCase()}}ThemeDark.instance,
    // fallback to light theme if an unknown theme is saved
    _ => {{proj_name.pascalCase()}}ThemeLight.instance,
  };

  @override
  Map<String, dynamic>? toJson({{proj_name.pascalCase()}}Theme state) => {
    'theme': switch (state) {
      {{proj_name.pascalCase()}}ThemeLight() => 'light',
      {{proj_name.pascalCase()}}ThemeDark() => 'dark',
    },
  };
}
