/// The base class for all environments.
sealed class Environment {
  /// Creates an environment with the given name.
  const Environment(this.name);

  /// The name of the environment.
  final String name;

  // TODO(dev): Add environment-specific variables here.
  /// Returns an initial counter value according to the environment.
  int get initialCounterValue;
}

/// The development environment.
final class DevelopmentEnvironment extends Environment {
  /// Creates the development environment.
  const DevelopmentEnvironment() : super('development');

  @override
  int get initialCounterValue => 42;
}

/// The staging environment.
final class StagingEnvironment extends Environment {
  /// Creates the staging environment.
  const StagingEnvironment() : super('staging');

  @override
  int get initialCounterValue => 43;
}

/// The production environment.
final class ProductionEnvironment extends Environment {
  /// Creates the production environment.
  const ProductionEnvironment() : super('production');

  @override
  int get initialCounterValue => 44;
}
