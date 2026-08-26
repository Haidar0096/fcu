import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:{{proj_name}}/foundation/l10n/src/language.dart';

/// Manages the locale of the app.
///
/// Conflict matrix: none — the only actions are synchronous selections of a
/// language, so no two actions can sit in an async gap together. A matrix
/// becomes needed the moment a language change has to await anything.
class LocalizationCubit extends HydratedCubit<Language> {
  LocalizationCubit({Language? initialLanguage})
    : super(initialLanguage ?? Language.english);

  /// Sets the language to the given [language].
  void setLanguage(Language language) {
    emit(language);
  }

  /// Sets the language to the next language in the list of languages.
  void setNextLanguage() {
    final nextLanguage = state.nextLanguage;
    emit(nextLanguage);
  }

  @override
  Language? fromJson(Map<String, dynamic> json) =>
      switch (json['language_code']) {
        'en' => Language.english,
        'ar' => Language.arabic,
        // Fall back to English if an unknown language code was saved.
        _ => Language.english,
      };

  @override
  Map<String, dynamic>? toJson(Language state) => {'language_code': state.code};
}
