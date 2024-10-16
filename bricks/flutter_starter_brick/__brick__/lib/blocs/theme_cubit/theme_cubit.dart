import 'package:{{proj_name}}/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/ui/styles/app_styles.dart';

/// Manages the theme of the app.
@LazySingletonService()
class ThemeCubit extends BaseHydratedCubit<AppTheme> {
  // initially the theme is set to light theme
  ThemeCubit() : super(AppThemeLight.instance);

  /// Sets the theme to the given theme.
  void setTheme(AppTheme theme) => emit(theme);

  @override
  AppTheme? fromJson(Map<String, dynamic> json) => switch (json['theme']) {
        'light' => AppThemeLight.instance,
        // fallback to light theme if an unknown theme is saved
        _ => AppThemeLight.instance,
      };

  @override
  Map<String, dynamic>? toJson(AppTheme state) => {
        'theme': switch (state) {
          AppThemeLight() => 'light',
        },
      };
}
