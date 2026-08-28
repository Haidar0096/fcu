import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:{{proj_name}}/app/app.dart';
import 'package:{{proj_name}}/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/app_meta_data.dart';
import 'package:{{proj_name}}/foundation/environment_variables/environment_variables.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/locator/locator.dart';
import 'package:{{proj_name}}/foundation/ui/global_loader/global_loader.dart';
import 'package:{{proj_name}}/foundation/ui/navigation/navigation.dart';

Future<void> main() async {
  // The build's values are read before any error road exists: a missing
  // required value must stop the app here, loudly, never be swallowed.
  final environmentVariables = EnvironmentVariables();

  await runZonedGuarded<Future<void>>(
    () async {
      // Crash reporting first: the three global error channels hook before
      // dependency injection and storage exist, so a failure in either of
      // those is still recorded.
      ErrorLogger.registerErrorHandlers(_resolveErrorLogger);

      WidgetsFlutterBinding.ensureInitialized();
      configureUrlStrategy();

      // No push, analytics, or store service needs boot-time initialization.

      if (platformIsAndroid || platformIsIos) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
      // Desktop and web skip the phone-only orientation lock.

      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );

      // Storage before dependency injection: a state holder built while the
      // container wires itself must find its storage already assigned.
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory(
                (await getApplicationSupportDirectory()).path,
              ),
      );

      await initializeDependencies(environmentVariables);

      GlobalLoader.init(
        appLogger: serviceLocator.get<AppLogger>(),
        errorLogger: serviceLocator.get<ErrorLogger>(),
        rootNavigatorKey: rootNavigatorKey,
      );

      // Reports an earlier launch could not send ride out now, down the same
      // one road a fresh report takes. Never awaited: a drain must not hold
      // the launch up, and it surfaces nothing either way.
      unawaited(serviceLocator.get<ErrorLogger>().sendParkedReports());

      // No additional project-specific boot service is known yet.
      runApp(const RootAppWidget());
    },
    (error, stackTrace) {
      unawaited(
        _resolveErrorLogger()?.recordError(
          error: error,
          stackTrace: stackTrace,
        ),
      );
    },
  );
}

/// Resolves the app's one report road, tolerantly.
///
/// The error channels are hooked before the container exists, so this both
/// checks the road is registered and swallows a failure to build it: the
/// error road must never itself throw.
ErrorLogger? _resolveErrorLogger() {
  try {
    return serviceLocator.tryGet<ErrorLogger>();
  } catch (_) {
    return null;
  }
}
