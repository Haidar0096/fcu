import 'package:{{proj_name}}/infrastructure/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/infrastructure/environments/environments.dart';
import 'package:{{proj_name}}/shared/variables/src/global_variables.dart';

@LazySingletonService()
sealed class EnvironmentVariables {
  @FactoryConstructor()
  factory EnvironmentVariables() => _instance;

  const EnvironmentVariables._();

  static final EnvironmentVariables _instance = switch (serviceProvider
      .get<Environment>()) {
    DevelopmentEnvironment() => DevelopmentEnvironmentVariables(),
    StagingEnvironment() => StagingEnvironmentVariables(),
    ProductionEnvironment() => ProductionEnvironmentVariables(),
  };

  String get jokesBackendBaseUrl;
}

final class DevelopmentEnvironmentVariables extends EnvironmentVariables {
  DevelopmentEnvironmentVariables() : super._();

  @override
  String get jokesBackendBaseUrl => 'https://api.chucknorris.io';
}

final class StagingEnvironmentVariables extends EnvironmentVariables {
  StagingEnvironmentVariables() : super._();

  @override
  String get jokesBackendBaseUrl => 'https://api.chucknorris.io';
}

final class ProductionEnvironmentVariables extends EnvironmentVariables {
  ProductionEnvironmentVariables() : super._();

  @override
  String get jokesBackendBaseUrl => 'https://api.chucknorris.io';
}
