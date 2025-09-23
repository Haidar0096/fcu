import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:{{proj_name}}/dependency_injection/src/instance_names.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';
import 'package:{{proj_name}}/foundation/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/foundation/environment_variables/environment_variables.dart';
import 'package:{{proj_name}}/foundation/environments/environments.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/backend_http_client/backend_http_client.dart';
import 'package:{{proj_name}}/foundation/networking/http_client/http_client.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

void registerInstances(GetIt getIt, {required Environment environment}) {
  getIt
    ..registerLazySingleton<Environment>(() => environment)
    ..registerLazySingleton<AppLogger>(() => const AppLogger())
    ..registerLazySingleton<ErrorLogger>(() => const ErrorLogger())
    ..registerLazySingleton<EventLogger>(() => const EventLogger())
    ..registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(appLogger: getIt.get()),
      dispose: (bloc) => bloc.close(),
    )
    ..registerLazySingleton<LocalizationCubit>(
      () => LocalizationCubit(appLogger: getIt.get()),
      dispose: (bloc) => bloc.close(),
    )
    ..registerLazySingleton<AppMetaDataCubit>(
      () => AppMetaDataCubit(getIt.get(), getIt.get()),
      dispose: (bloc) => bloc.close(),
    )
    ..registerLazySingleton<EnvironmentVariables>(
      () => switch (getIt.get<Environment>()) {
        Environment.development => const DevelopmentEnvironmentVariables(),
        Environment.staging => const StagingEnvironmentVariables(),
        Environment.production => const ProductionEnvironmentVariables(),
      },
    )
    ..registerFactory<HttpClient>(
      () => BackendHttpClient(
        baseUrl: getIt.get<EnvironmentVariables>().backendBaseUrl,
        errorLogger: getIt.get(),
        appLogger: getIt.get(),
      ),
      instanceName: InstanceNames.publicBackendHttpClient.name,
    )
    ..registerLazySingleton<RandomJokesApi>(
      () => RandomJokesApi(
        getIt.get<HttpClient>(
          instanceName: InstanceNames.publicBackendHttpClient.name,
        ),
      ),
    )
    ..registerFactory<RandomJokesCubit>(
      () => RandomJokesCubit(
        randomJokesApi: getIt.get(),
        appLogger: getIt.get(),
      ),
    )
    ..registerLazySingleton<SplashCubit>(
      () => SplashCubit(
        appLogger: getIt.get(),
      ),
      dispose: (bloc) => bloc.close(),
    );
}
