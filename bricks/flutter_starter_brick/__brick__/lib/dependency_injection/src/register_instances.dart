import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:{{proj_name}}/dependency_injection/src/instance_names.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes.dart';
import 'package:{{proj_name}}/features/random_jokes/src/apis/jokes_api.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/app_meta_data.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/src/repositories/app_meta_data_repository.dart';
import 'package:{{proj_name}}/foundation/environment_variables/environment_variables.dart';
import 'package:{{proj_name}}/foundation/environments/environments.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/networking.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

void registerInstances(
  GetIt getIt, {
  required EnvironmentVariables environmentVariables,
}) {
  getIt
    ..registerLazySingleton<Environment>(() => environmentVariables.environment)
    ..registerLazySingleton<EnvironmentVariables>(() => environmentVariables)
    ..registerLazySingleton<AppLogger>(() => const AppLogger())
    ..registerLazySingleton<FlowBuffer>(FlowBuffer.new)
    ..registerLazySingleton<ErrorLogger>(
      () => ErrorLogger(
        reportSender: getIt.get(),
        flowBuffer: getIt.get(),
        appShortName: EnvironmentVariables.appShortName,
      ),
    )
    ..registerLazySingleton<EventLogger>(() => const EventLogger())
    ..registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(),
      dispose: (bloc) => bloc.close(),
    )
    ..registerLazySingleton<LocalizationCubit>(
      () => LocalizationCubit(),
      dispose: (bloc) => bloc.close(),
    )
    ..registerSingletonAsync<SharedPreferences>(SharedPreferences.getInstance)
    ..registerSingletonAsync<AppMetaDataRepository>(() async {
      await getIt.isReady<SharedPreferences>();
      return AppMetaDataRepository(sharedPreferences: getIt.get());
    })
    ..registerSingletonAsync<AppMetaDataCubit>(() async {
      await getIt.isReady<AppMetaDataRepository>();
      return AppMetaDataCubit(
        repository: getIt.get(),
        appLogger: getIt.get(),
        errorLogger: getIt.get(),
      );
    }, dispose: (bloc) => bloc.close())
    ..registerFactory<HttpClient>(
      () => BackendHttpClient(
        baseUrl: getIt.get<EnvironmentVariables>().backendBaseUrl,
        errorLogger: getIt.get(),
        appLogger: getIt.get(),
      ),
      instanceName: InstanceNames.publicBackendHttpClient.name,
    )
    ..registerLazySingleton<ParkedReportStore>(
      () => ParkedReportStore(sharedPreferences: getIt.get()),
    )
    // ---------------------------------------------------------------------
    // THE REPORT SENDER — and the one seam this starter deliberately leaves
    // open.
    //
    // THE RECEIVER TAKES A REPORT WITH NO LOGIN TOKEN. That is settled, and
    // it is why nothing here attaches one: a crash that happens before the
    // user logs in still has to be reported. The receiver is rate limited
    // per calling address and strips secrets again on arrival — the sender
    // is never trusted — so the open door costs nothing here.
    //
    // Two things are NOT settled, and neither may be guessed at:
    //
    //   1. WHICH CLIENT the sender rides. The rule says the report goes out
    //      through the app's own HttpClient. This starter registers exactly
    //      one client, the public one, so that is the one handed over. The
    //      moment the project adds an authenticated client, someone has to
    //      say which of the two carries reports.
    //   2. THE RECEIVER'S PATH, which sits in EnvironmentVariables beside
    //      the base URL. It ships EMPTY and is filled in from the answer
    //      given at project setup; while it is empty every report parks on
    //      the device instead of being posted at an address nobody chose.
    //
    // Nothing here works around either: no second client is registered, no
    // address is invented, and a failed upload is parked like any other.
    //
    // The client arrives as a resolver rather than as a value because the
    // one client reports its own failures through ErrorLogger, which is fed
    // by this very sender: resolving it here would close a circle the
    // container cannot build. The resolver names the SAME one client the
    // line above registers — it defers WHEN, never WHICH.
    // ---------------------------------------------------------------------
    ..registerLazySingleton<ReportSender>(
      () => switch (getIt.get<EnvironmentVariables>().reportSenderKind) {
        ReportSenderKind.ownBackend => BackendReportSender(
          resolveHttpClient: () => getIt.get<HttpClient>(
            instanceName: InstanceNames.publicBackendHttpClient.name,
          ),
          parkedReports: getIt.get(),
          receiverPath: getIt.get<EnvironmentVariables>().reportReceiverPath,
        ),
      },
    )
    ..registerLazySingleton<JokesApi>(
      () => JokesApi(
        getIt.get<HttpClient>(
          instanceName: InstanceNames.publicBackendHttpClient.name,
        ),
      ),
    )
    ..registerFactory<JokesCubit>(() => JokesCubit(jokesApi: getIt.get()))
    ..registerFactory<SplashCubit>(SplashCubit.new);
}
