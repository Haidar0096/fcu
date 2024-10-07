import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Manages the theme of the app.
@LazySingletonService()
class ThemeCubit extends HydratedCubit<AppTheme> {
  // initially the theme is set to light theme
  ThemeCubit() : super(AppThemeLight.instance);

  /// Sets the theme to the given theme.
  void setTheme(AppTheme theme) => emit(theme);

  @override
  AppTheme? fromJson(Map<String, dynamic> json) => switch (json['theme']) {
        'light' => AppThemeLight.instance,
        // TODO(dev): Change the next line after adding the dark theme
        _ => AppThemeLight.instance,
      };

  @override
  Map<String, dynamic>? toJson(AppTheme state) => {
        'theme': switch (state) {
          AppThemeLight() => 'light',
        },
      };
}
