/// UI model for displaying a joke
final class UiJoke {
  const UiJoke({
    required this.id,
    required this.content,
  });

  /// Unique identifier for the joke
  final String id;

  /// The joke content to display
  final String content;
}
