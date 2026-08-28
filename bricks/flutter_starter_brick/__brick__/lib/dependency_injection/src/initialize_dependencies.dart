import 'package:{{proj_name}}/dependency_injection/src/register_instances.dart';
import 'package:{{proj_name}}/foundation/environments/environments.dart';
import 'package:{{proj_name}}/foundation/locator/src/service_locator.dart';

/// Registers and resolves the application's dependency graph once.
Future<void> initializeDependencies(Environment environment) =>
    initializeServiceLocator(
      (getIt) => registerInstances(getIt, environment: environment),
    );
