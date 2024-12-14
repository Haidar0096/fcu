import 'dart:ui';

import 'package:{{proj_name}}/common/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/common/dependency_injection/dependency_injection.dart';

/// Manages the locale of the app.
@LazySingletonService()
class LocalizationCubit extends BaseHydratedCubit<Language> {
  // initially the locale is set to english
  LocalizationCubit() : super(Language.english);

  /// Sets the language to the given [language].
  void setLanguage(Language language) => emit(language);

  /// Sets the language to the next language in the list of languages.
  void setNextLanguage() => emit(state.nextLanguage);

  @override
  Language? fromJson(Map<String, dynamic> json) =>
      Language.values.firstWhere((l) => l.code == json['language_code']);

  @override
  Map<String, dynamic>? toJson(Language state) => {'language_code': state.code};
}

/// Instances of this type represent a language in the supported languages set.
enum Language {
  english(
    textDirection: TextDirection.ltr,
    displayName: 'English',
    code: 'en',
  ),
  // TODO(developer): Edit the supported languages here if needed and add
  // the corresponding ARB file.
  spanish(
    textDirection: TextDirection.ltr,
    displayName: 'Español',
    code: 'es',
  );

  const Language({
    required this.textDirection,
    required this.displayName,
    required this.code,
  });

  /// The text direction of the language.
  final TextDirection textDirection;

  /// The display name of the language, can be displayed to the user.
  final String displayName;

  /// A unique code that represents the language.
  final String code;

  /// Returns the next language in the list of languages. This is done using
  /// round-robin fashion, i.e. it returns the next language in the list of
  /// languages, and if the current language is the last language in the list,
  /// it returns the first language in the list.
  Language get nextLanguage =>
      Language.values[(index + 1) % Language.values.length];
}
