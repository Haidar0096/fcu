import 'package:{{proj_name}}/common/dependency_injection/dependency_injection.dart';
{{#has_envs}}import 'package:{{proj_name}}/common/environments/environments.dart';{{/has_envs}}
import 'package:{{proj_name}}/common/logging/logging.dart';
import 'package:{{proj_name}}/app/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main{{#has_envs}}Common{{/has_envs}}({{#has_envs}}Environment env{{/has_envs}}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceProvider.init({{#has_envs}}environment: env{{/has_envs}});

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  ServiceProvider.get<ErrorLogger>().registerErrorHandlers();

  runApp(const RootAppWidget());
}
