import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lia/foundation/logging/logging.dart';

/// Manages the locale of the app.
class LocalizationCubit extends HydratedCubit<Language> {
  LocalizationCubit({
    required AppLogger appLogger,
    Language? initialLanguage,
  }) : _appLogger = appLogger,
       super(initialLanguage ?? Language.english);

  final AppLogger _appLogger;
  static const String _tag = 'LocalizationCubit';

  /// Sets the language to the given [language].
  void setLanguage(Language language) {
    _appLogger.log(
      'Setting language to: ${language.displayName} (${language.code})',
      tag: _tag,
    );
    emit(language);
  }

  /// Sets the language to the next language in the list of languages.
  void setNextLanguage() {
    final nextLanguage = state.nextLanguage;
    _appLogger.log(
      'Setting next language to: ${nextLanguage.displayName} '
      '(${nextLanguage.code})',
      tag: _tag,
    );
    emit(nextLanguage);
  }

  @override
  Language? fromJson(Map<String, dynamic> json) =>
      Language.values.firstWhereOrNull(
        (l) => l.code == json['language_code'],
      ) ??
      Language.english;

  @override
  Map<String, dynamic>? toJson(Language state) => {'language_code': state.code};
}

/// Instances of this type represent a language in the supported languages set.
enum Language {
  english(textDirection: TextDirection.ltr, displayName: 'English', code: 'en');

  const Language({
    required this.textDirection,
    required this.displayName,
    required this.code,
  });

  /// Whether the language is written from left to right.
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
