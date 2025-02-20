import 'dart:async';

import 'package:{{proj_name}}/dependency_injection_impl/src/dependency_injection_impl.config.dart';
import 'package:{{proj_name}}/infrastructure/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/infrastructure/environments/environments.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide Environment;

/// Initializes the dependency container.
@InjectableInit(initializerName: r'$initInjectable', asExtension: false)
Future<void> _initInjectable(
  GetIt getIt, {
  required Environment environment,
}) async => $initInjectable(getIt, environment: environment.name);

/// The ServiceProvider class encapsulates the dependency injection logic
/// and provides access to the services that are registered in the container.
class GetItServiceProvider implements ServiceProvider {
  static final GetIt _getIt = GetIt.instance;

  static Completer<void>? _initializedCompleter;

  /// Initializes the dependency container.
  @override
  Future<void> init({required Environment environment}) async {
    if (_initializedCompleter != null) return _initializedCompleter!.future;
    _initializedCompleter = Completer<void>();
    unawaited(_init(environment: environment));
    return _initializedCompleter!.future;
  }

  static Future<void> _init({required Environment environment}) async {
    _getIt.registerLazySingleton<Environment>(() => environment);

    await _initInjectable(_getIt, environment: environment);
    _initializedCompleter!.complete();
  }

  /// Retrieves a registered instance of type [T] from the dependency container.
  /// - [instanceName]: The name of the instance to retrieve.
  /// - [param1]: The first parameter to pass to the instance's constructor.
  /// - [param2]: The second parameter to pass to the instance's constructor.
  @override
  T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) =>
      _getIt.get<T>(instanceName: instanceName, param1: param1, param2: param2);
}

/// Used to manually register services in the dependency container that are not
/// registered otherwise by annotations.
@module
abstract class RegisterModule {
  // TODO(developer): add manually registered services here.
  /*
  // for example:
  @Named(DependencyInjectionInstanceName.incrementValue)
  int get incrementValue => 1;
  */
}
