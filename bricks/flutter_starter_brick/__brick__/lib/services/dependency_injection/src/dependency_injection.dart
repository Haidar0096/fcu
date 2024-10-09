import 'package:{{proj_name}}/services/dependency_injection/src/dependency_injection.config.dart';
{{#has_envs}}import 'package:{{proj_name}}/services/environments/environments.dart';{{/has_envs}}
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide Environment;

// Typedefs for injectable's annotations to hide the package from
// the application code, so that it can be replaced with another DI package
// if needed.
/// Annotation for classes that should be registered as services and available
/// via the dependency injection container.
typedef Service = Injectable;

/// Annotation for classes that should be registered as singleton services and
/// available via the dependency injection container.
typedef SingletonService = Singleton;

/// Annotation for classes that should be registered as lazy singleton services
/// and available via the dependency injection container.
typedef LazySingletonService = LazySingleton;

/// Initializes the dependency container.
@InjectableInit(
  initializerName: r'$initInjectable',
  asExtension: false,
)
Future<void> _initInjectable(
  GetIt getIt{{#has_envs}},
  {required Environment environment,}{{/has_envs}}
) async =>
    $initInjectable(
      getIt{{#has_envs}},
      environment: environment.name,{{/has_envs}}
    );

/// The ServiceProvider class encapsulates the dependency injection logic
/// and provides access to the services that are registered in the container.
class ServiceProvider {
  static final GetIt _getIt = GetIt.instance;

  static bool _initialized = false;

  /// Initializes the dependency container.
  static Future<void> init(
    {{#has_envs}}{required Environment environment,}{{/has_envs}}
  ) async {
    if (_initialized) return;
    _initialized = true;
    {{#has_envs}}
    _getIt.registerLazySingleton<Environment>(() => environment);
    {{/has_envs}}
    await _initInjectable(
      _getIt{{#has_envs}},
      environment: environment,{{/has_envs}}
    );
  }

  /// Retrieves a registered instance of type [T] from the dependency container.
  static T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) =>
      _getIt.get<T>(instanceName: instanceName);
}

/// Used to manually register services in the dependency container that are not
/// registered otherwise by annotations.
@module
abstract class RegisterModule {
  // TODO(dev): add manually registered services here.
  @Named('increment_value')
  int get incrementValue => 1;
}
