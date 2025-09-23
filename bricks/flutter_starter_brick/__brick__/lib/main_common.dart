import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:{{proj_name}}/app/app.dart';
import 'package:{{proj_name}}/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/foundation/environments/environments.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/ui/navigation/navigation.dart';
import 'package:{{proj_name}}/foundation/ui/services/services.dart';
import 'package:path_provider/path_provider.dart';

Future<void> mainCommon(Environment env) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set app to fullscreen initially without any system bars
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  // Initialize the service provider
  await ServiceLocator.init(environment: env);

  // Initialize GlobalLoader singleton
  GlobalLoader.init(
    appLogger: serviceLocator.get<AppLogger>(),
    rootNavigatorKey: rootNavigatorKey,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  serviceLocator.get<ErrorLogger>().registerErrorHandlers();

  runApp(const RootAppWidget());
}
