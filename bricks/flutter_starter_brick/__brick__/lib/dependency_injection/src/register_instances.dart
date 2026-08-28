import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:{{proj_name}}/dependency_injection/src/instance_names.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/random_jokes_screen.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/apis/jokes_api.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/app_meta_data.dart';
import 'package:{{proj_name}}/foundation/environment_variables/environment_variables.dart';
import 'package:{{proj_name}}/foundation/environments/environments.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/locator/locator.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/networking.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

void registerInstances({
  required ServiceRegistry getIt,
  required EnvironmentVariables environmentVariables,
}) {
  getIt
    ..registerLazySingleton<AppLogger>(() => const AppLogger())
    ..registerLazySingleton<ErrorLogger>(
      () => ErrorLogger(
        reportSender: getIt.get(),
        flowBuffer: getIt.get(),
        appShortName: EnvironmentVariables.appShortName,
      ),
    )
    ..registerLazySingleton<EventLogger>(() => const EventLogger())
    ..registerLazySingleton<FlowBuffer>(FlowBuffer.new)
    ..registerLazySingleton<Environment>(() => environmentVariables.environment)
    ..registerLazySingleton<EnvironmentVariables>(() => environmentVariables)
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
      return AppMetaDataRepository(
        androidId: const AndroidId(),
        appLogger: getIt.get(),
        deviceInfoPlugin: DeviceInfoPlugin(),
        errorLogger: getIt.get(),
        sharedPreferences: getIt.get(),
        uuid: const Uuid(),
      );
    })
    ..registerLazySingleton<AppMetaDataCubit>(
      () => AppMetaDataCubit(repository: getIt.get()),
      dispose: (bloc) => bloc.close(),
    )
    ..registerFactory<HttpClient>(
      () => BackendHttpClient.standard(
        baseUrl: getIt.get<EnvironmentVariables>().backendBaseUrl,
        errorLogger: getIt.get(),
        appLogger: getIt.get(),
        reportsFailures: true,
      ),
      instanceName: InstanceNames.publicBackendHttpClient.name,
    )
    ..registerFactory<HttpClient>(
      () => BackendHttpClient.standard(
        baseUrl: getIt.get<EnvironmentVariables>().backendBaseUrl,
        errorLogger: null,
        appLogger: getIt.get(),
        reportsFailures: false,
      ),
      instanceName: InstanceNames.reportUploadHttpClient.name,
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
    //   1. WHICH AUTH CLIENT future authenticated APIs ride. The report
    //      sender already has its public no-report client, so an upload
    //      failure cannot report itself recursively.
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
    // container cannot build. The resolver names the dedicated report client
    // above — it defers WHEN, never WHICH.
    // ---------------------------------------------------------------------
    ..registerLazySingleton<ReportSender>(
      () => switch (getIt.get<EnvironmentVariables>().reportSenderKind) {
        ReportSenderKind.ownBackend => BackendReportSender(
          resolveHttpClient: () => getIt.get<HttpClient>(
            instanceName: InstanceNames.reportUploadHttpClient.name,
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
