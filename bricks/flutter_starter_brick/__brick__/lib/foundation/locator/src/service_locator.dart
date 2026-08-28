import 'dart:async';

import 'package:get_it/get_it.dart';

/// Service locator that encapsulates dependency injection using GetIt.
class ServiceLocator {
  const ServiceLocator._();

  static final GetIt _getIt = GetIt.instance;
  static Completer<void>? _initializedCompleter;

  static Future<void> _initialize(
    void Function(GetIt getIt) registerInstances,
  ) async {
    if (_initializedCompleter != null) return _initializedCompleter!.future;
    _initializedCompleter = Completer<void>();

    registerInstances(_getIt);

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

/// Gives the one composition root temporary access to GetIt registration.
Future<void> initializeServiceLocator(
  void Function(GetIt getIt) registerInstances,
) => ServiceLocator._initialize(registerInstances);
