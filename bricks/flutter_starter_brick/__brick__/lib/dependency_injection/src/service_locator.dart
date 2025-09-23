import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:{{proj_name}}/dependency_injection/src/register_instances.dart';
import 'package:{{proj_name}}/foundation/environments/environments.dart';

/// Service locator that encapsulates dependency injection using GetIt.
class ServiceLocator {
  const ServiceLocator._();

  static final GetIt _getIt = GetIt.instance;
  static Completer<void>? _initializedCompleter;

  /// Initializes the dependency container.
  static Future<void> init({required Environment environment}) async {
    if (_initializedCompleter != null) return _initializedCompleter!.future;
    _initializedCompleter = Completer<void>();

    // Register all instances
    registerInstances(_getIt, environment: environment);

    // Wait for all async registrations to complete
    await _getIt.allReady();

    _initializedCompleter!.complete();
  }

  /// Retrieves a registered instance from the container.
  T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) =>
      _getIt.get<T>(instanceName: instanceName, param1: param1, param2: param2);

  /// Tries to get a registered instance. Returns null if not found.
  T? tryGet<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    if (_getIt.isRegistered<T>(instanceName: instanceName)) {
      return _getIt.get<T>(
        instanceName: instanceName,
        param1: param1,
        param2: param2,
      );
    }
    return null;
  }
}

/// Global instance for accessing the service locator
const serviceLocator = ServiceLocator._();
