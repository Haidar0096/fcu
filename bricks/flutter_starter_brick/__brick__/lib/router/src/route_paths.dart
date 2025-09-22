/// Sealed class hierarchy defining all routes in the application
///
/// TODO({{dev_name}}): Add your app-specific routes here following the same pattern
sealed class RoutePath {
  const RoutePath();

  /// Whether this route is the splash route
  bool get isSplashRoute => this is SplashRoutePath;

  /// Whether this route is the random jokes route
  bool get isRandomJokesRoute => this is RandomJokesRoutePath;

  /// Whether this route is the critical error route
  bool get isCriticalErrorRoute => this is CriticalErrorRoutePath;

  /// Get a RoutePath instance from a path string
  /// Throws [ArgumentError] if the path is not recognized
  static RoutePath fromPath(String pathString) => switch (pathString) {
    SplashRoutePath.path => const SplashRoutePath(),
    CriticalErrorRoutePath.path => const CriticalErrorRoutePath(),
    RandomJokesRoutePath.path => const RandomJokesRoutePath(),
    _ => throw ArgumentError('Unknown route path: $pathString'),
  };
}

/// Splash screen shown on app launch
final class SplashRoutePath extends RoutePath {
  const SplashRoutePath();

  static const String path = '/splash_screen';
}

/// Critical error screen for unrecoverable errors
final class CriticalErrorRoutePath extends RoutePath {
  const CriticalErrorRoutePath();

  static const String path = '/critical_error';
}

/// Random jokes screen - demonstrates API integration and state management
final class RandomJokesRoutePath extends RoutePath {
  const RandomJokesRoutePath();

  static const String path = '/random_jokes';
}
