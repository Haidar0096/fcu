import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:{{proj_name}}/dependency_injection/src/instance_names.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/random_jokes_screen.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/apis/jokes_api.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/app_meta_data.dart';
import 'package:{{proj_name}}/foundation/authentication/authentication.dart';
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
    // ---------------------------------------------------------------------
    // THE TOKEN PLUMBING — shipped before any login exists, deliberately.
    //
    // Adding login must be ONE change: the screens and the auth API. If the
    // plumbing arrived with them, every project would build it again, and a
    // token would be attached at a call site until someone noticed.
    //
    // The store ships EMPTY: nothing writes a token because nothing logs in.
    // The renewal ships UNWIRED and says so loudly if it is ever reached —
    // the renewal address and the shape the server answers in are the
    // project's, and the starter guesses neither.
    // ---------------------------------------------------------------------
    ..registerLazySingleton<AuthTokenStore>(AuthTokenStore.standard)
    // ONE coordinator for the whole app, which is what makes renewal
    // single-flight true: a copy per client or per request would each hold
    // their own in-flight completer, and ten refusals would spend the refresh
    // credential ten times.
    ..registerLazySingleton<AuthTokenRenewalCoordinator>(
      () => AuthTokenRenewalCoordinator(renewTokens: unwiredAuthTokenRenewal),
      dispose: (coordinator) => coordinator.close(),
    )
    ..registerFactory<HttpClient>(
      () => BackendHttpClient.standard(
        baseUrl: getIt.get<EnvironmentVariables>().backendBaseUrl,
        errorLogger: getIt.get(),
        appLogger: getIt.get(),
        reportsFailures: true,
        buildInterceptors: publicInterceptorsBuilder(),
      ),
      instanceName: InstanceNames.publicBackendHttpClient.name,
    )
    ..registerFactory<HttpClient>(
      () => BackendHttpClient.standard(
        baseUrl: getIt.get<EnvironmentVariables>().backendBaseUrl,
        errorLogger: getIt.get(),
        appLogger: getIt.get(),
        reportsFailures: true,
        buildInterceptors: loggedInInterceptorsBuilder(
          tokenStore: getIt.get(),
          renewalCoordinator: getIt.get(),
        ),
      ),
      instanceName: InstanceNames.loggedInBackendHttpClient.name,
    )
    ..registerFactory<HttpClient>(
      () => BackendHttpClient.standard(
        baseUrl: getIt.get<EnvironmentVariables>().backendBaseUrl,
        errorLogger: null,
        appLogger: getIt.get(),
        reportsFailures: false,
        buildInterceptors: publicInterceptorsBuilder(),
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
    // it is why the sender rides the public no-report client: a crash that
    // happens before the user logs in still has to be reported. The receiver
    // is rate limited per calling address and strips secrets again on arrival
    // — the sender is never trusted — so the open door costs nothing here.
    //
    // THE RECEIVER'S PATH is not settled and may not be guessed. It sits in
    // EnvironmentVariables beside the base URL, ships EMPTY, and is filled in
    // from the answer given at project setup; while it is empty every report
    // parks on the device instead of being posted at an address nobody chose.
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
    // The jokes endpoint needs no login, so its API takes the PUBLIC client.
    // Every API names exactly one client, and it is named here — never inside
    // the API class.
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
