import 'package:{{proj_name}}/infrastructure/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/src/{{proj_name.snakeCase()}}_theme.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Manages the theme of the app.
@LazySingletonService()
class ThemeCubit extends HydratedCubit<{{proj_name.pascalCase()}}Theme> {
  ThemeCubit([@ignoreParameter {{proj_name.pascalCase()}}Theme? initialTheme])
      : super(initialTheme ?? {{proj_name.pascalCase()}}ThemeLight.instance);

  /// Sets the theme to the given theme.
  void setTheme({{proj_name.pascalCase()}}Theme theme) => emit(theme);

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
