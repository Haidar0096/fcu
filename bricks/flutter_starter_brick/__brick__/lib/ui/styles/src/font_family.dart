/// Enum representing the font families used in the application.
enum FontFamily {
  /// Represents the Consolas font family.
  consolas('consolas');

  /// Constructs a [FontFamily] with the given font name.
  /// - [name] is the name of the font family as specified in the
  /// pubspec.yaml file under the fonts/family section.
  const FontFamily(this.name);

  /// The name of the font family as specified in the pubspec.yaml file
  /// under the fonts/family section.
  final String name;
}
