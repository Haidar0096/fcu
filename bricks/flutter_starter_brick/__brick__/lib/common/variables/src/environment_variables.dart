import 'package:{{proj_name}}/infrastructure/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/infrastructure/environments/environments.dart';
import 'package:{{proj_name}}/common/variables/src/global_variables.dart';

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

  /**
 * TODO({{dev_name}}): Add your environment variables here
 * example:
 * String get apiUrl;
 */
}

final class DevelopmentEnvironmentVariables extends EnvironmentVariables {
  DevelopmentEnvironmentVariables() : super._();
  /**
 * TODO({{dev_name}}): Add your environment variables here
 * example:
 * @override
 * String get apiUrl => 'https://api.example-dev.com';
 */
}

final class StagingEnvironmentVariables extends EnvironmentVariables {
  StagingEnvironmentVariables() : super._();

  /**
 * TODO({{dev_name}}): Add your environment variables here
 * example:
 * @override
 * String get apiUrl => 'https://api.example-stg.com';
 */
}

final class ProductionEnvironmentVariables extends EnvironmentVariables {
  ProductionEnvironmentVariables() : super._();

  /**
 * TODO({{dev_name}}): Add your environment variables here
 * example:
 * @override
 * String get apiUrl => 'https://api.example-prd.com';
 */
}
