/// The base class for all environments.
sealed class Environment {
  const Environment(this.name);

  /// The name of the environment.
  final String name;

  String get greeting;
}

/// The development environment.
final class DevEnvironment extends Environment {
  /// Creates the development environment.
  const DevEnvironment() : super('dev_env');

  @override
  String get greeting => 'Hello, world from dev environment!';
}

/// The staging environment.
final class StagEnvironment extends Environment {
  /// Creates the staging environment.
  const StagEnvironment() : super('stag_env');

  @override
  String get greeting => 'Hello, world from staging environment!';
}

/// The production environment.
final class ProdEnvironment extends Environment {
  /// Creates the production environment.
  const ProdEnvironment() : super('prod_env');

  @override
  String get greeting => 'Hello, world from production environment!';
}
