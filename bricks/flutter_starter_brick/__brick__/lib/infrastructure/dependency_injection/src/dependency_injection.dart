import 'dart:async';

import 'package:{{proj_name}}/infrastructure/environments/environments.dart';
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

/// Constructor params annotated with [ignoreParameter]
/// will be ignored by when generating the
/// resolver function.
const ignoreParameter = ignoreParam;

/// The ServiceProvider class encapsulates the dependency injection logic
/// and provides access to the services that are registered in the container.
abstract class ServiceProvider {
  /// Initializes the dependency container.
  Future<void> init({required Environment environment});

  /// Retrieves a registered instance of type [T] from the dependency container.
  /// - [instanceName]: The name of the instance to retrieve.
  /// - [param1]: The first parameter to pass to the instance's constructor.
  /// - [param2]: The second parameter to pass to the instance's constructor.
  T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  });
}
