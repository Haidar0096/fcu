/// Sealed class hierarchy defining all routes in the application
///
/// Every route fact lives here and only here: the path string, and the
/// screen NAME the screen trail records. The name is a compile-time constant
/// so the trail never has to read a live address, which can carry data that
/// must stay out of a recorded trail.
///
/// App-specific routes follow the same pattern: path constant, name constant,
/// and a `fromPath` arm.
sealed class RoutePath {
  const RoutePath();

  /// Get a RoutePath instance from a path string
  /// Throws [ArgumentError] if the path is not recognized
  static RoutePath fromPath(String pathString) => switch (pathString) {
    CriticalErrorRoutePath.path => const CriticalErrorRoutePath(),
    RandomJokesRoutePath.path => const RandomJokesRoutePath(),
    _ => throw ArgumentError('Unknown route path: $pathString'),
  };
}

/// Critical error screen for unrecoverable errors
final class CriticalErrorRoutePath extends RoutePath {
  const CriticalErrorRoutePath();

  static const String path = '/critical_error';

  /// What the screen trail records when the user lands here.
  static const String name = 'critical_error_screen';
}

/// Random jokes screen - demonstrates API integration and state management
final class RandomJokesRoutePath extends RoutePath {
  const RandomJokesRoutePath();

  static const String path = '/random_jokes';

  /// What the screen trail records when the user lands here.
  static const String name = 'random_jokes';
}
