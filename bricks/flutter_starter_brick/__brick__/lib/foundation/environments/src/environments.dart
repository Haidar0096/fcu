/// The environment types for the application.
enum Environment {
  /// The development environment.
  development('development'),

  /// The staging environment.
  staging('staging'),

  /// The production environment.
  production('production');

  /// Creates an environment with the given name.
  const Environment(this.name);

  /// The name of the environment.
  final String name;
}
