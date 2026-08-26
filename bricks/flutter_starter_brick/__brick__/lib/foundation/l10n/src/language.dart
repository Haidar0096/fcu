import 'dart:ui';

/// Instances of this type represent a language in the supported languages set.
enum Language {
  english(textDirection: TextDirection.ltr, displayName: 'English', code: 'en'),
  arabic(textDirection: TextDirection.rtl, displayName: 'العربية', code: 'ar');

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
