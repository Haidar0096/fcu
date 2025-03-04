import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:{{proj_name}}/common/variables/variables.dart';
import 'package:{{proj_name}}/common/widgets/widgets.dart';
import 'package:{{proj_name}}/infrastructure/environments/environments.dart';
import 'package:{{proj_name}}/infrastructure/logging/logging.dart';

Future<void> mainCommon(Environment env) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set app to fullscreen initially without any system bars
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  await serviceProvider.init(environment: env);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  serviceProvider.get<ErrorLogger>().registerErrorHandlers();

  runApp(const RootAppWidget());
}
