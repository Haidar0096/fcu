/// The base class for all environments.
sealed class Environment {
  /// Creates an environment with the given name.
  const Environment(this.name);

  /// The name of the environment.
  final String name;
}

/// The development environment.
final class DevelopmentEnvironment extends Environment {
  /// Creates the development environment.
  const DevelopmentEnvironment() : super('development');
}

/// The staging environment.
final class StagingEnvironment extends Environment {
  /// Creates the staging environment.
  const StagingEnvironment() : super('staging');
}

/// The production environment.
final class ProductionEnvironment extends Environment {
  /// Creates the production environment.
  const ProductionEnvironment() : super('production');
}
