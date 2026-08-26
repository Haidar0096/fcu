import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/{{proj_name.snakeCase()}}_theme.dart';

/// Manages the theme of the app.
///
/// Conflict matrix: none — [setTheme] is the only action and it is fully
/// synchronous, so no action can sit in an async gap here. A matrix becomes
/// needed the moment a theme arrives over an await (a server-driven theme,
/// a downloaded palette).
class ThemeCubit extends HydratedCubit<{{proj_name.pascalCase()}}Theme> {
  ThemeCubit({
    {{proj_name.pascalCase()}}Theme? initialTheme,
  }) : super(initialTheme ?? {{proj_name.pascalCase()}}ThemeLight.instance);

  /// Sets the theme to the given theme.
  void setTheme({{proj_name.pascalCase()}}Theme theme) {
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
