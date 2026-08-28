import 'package:{{proj_name}}/dependency_injection/src/register_instances.dart';
import 'package:{{proj_name}}/foundation/environment_variables/environment_variables.dart';
import 'package:{{proj_name}}/foundation/locator/src/service_locator.dart';

/// Registers and resolves the application's dependency graph once.
Future<void> initializeDependencies(
  EnvironmentVariables environmentVariables,
) => initializeServiceLocator(
  (getIt) =>
      registerInstances(getIt, environmentVariables: environmentVariables),
);
