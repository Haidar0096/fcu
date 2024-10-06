/// The base class for all environments.
sealed class Environment {
  /// Creates an environment with the given name.
  const Environment(this.name);

  /// The name of the environment.
  final String name;

  // TODO(dev): Add environment-specific variables here.
  /// Returns a greeting message for the environment.
  String get greeting;
}

/// The development environment.
final class DevelopmentEnvironment extends Environment {
  /// Creates the development environment.
  const DevelopmentEnvironment() : super('development');

  @override
  String get greeting => 'Hello, world from dev environment!';
}

/// The staging environment.
final class StagingEnvironment extends Environment {
  /// Creates the staging environment.
  const StagingEnvironment() : super('staging');

  @override
  String get greeting => 'Hello, world from staging environment!';
}

/// The production environment.
final class ProductionEnvironment extends Environment {
  /// Creates the production environment.
  const ProductionEnvironment() : super('production');

  @override
  String get greeting => 'Hello, world from production environment!';
}
