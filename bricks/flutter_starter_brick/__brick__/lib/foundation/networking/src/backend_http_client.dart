import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/src/backend_error_message_parser.dart';
import 'package:{{proj_name}}/foundation/networking/src/dio_http_client.dart';
import 'package:{{proj_name}}/foundation/networking/src/http_interceptor.dart';

const Duration _defaultTimeout = Duration(seconds: 30);

/// Builds the ordered chain of steps a client runs, handed the transport
/// instance the chain will live on.
///
/// The transport is handed over rather than kept out of reach because the
/// reactive renewal step has to send a refused request again on exactly the
/// client that carried it the first time.
typedef OnBuildInterceptorsCallback =
    List<HttpInterceptor> Function(dio.Dio transport);

/// A request handler for backend requests.
///
/// This class sets the base URL, the default headers, the timeouts and the
/// injected error parser — once, here. WHICH chain of steps a given client
/// runs is the caller's one line: the public chain carries no token, the
/// logged-in chain carries and renews one.
final class BackendHttpClient extends DioHttpClient {
  /// Creates a backend handler with the wrapper's default Dio transport.
  factory BackendHttpClient.standard({
    required String baseUrl,
    required AppLogger appLogger,
    required ErrorLogger? errorLogger,
    required bool reportsFailures,
    required OnBuildInterceptorsCallback buildInterceptors,
  }) => BackendHttpClient(
    client: dio.Dio(),
    baseUrl: baseUrl,
    appLogger: appLogger,
    errorLogger: errorLogger,
    reportsFailures: reportsFailures,
    buildInterceptors: buildInterceptors,
  );

  /// Creates a new backend request handler.
  /// - [appLogger] is the logger to be used for logging.
  /// - [errorLogger] is the error logger to be used for logging errors.
  /// - [baseUrl] is the base URL for the backend.
  /// - [buildInterceptors] builds the ordered chain this client runs.
  factory BackendHttpClient({
    required dio.Dio client,
    required String baseUrl,
    required AppLogger appLogger,
    required ErrorLogger? errorLogger,
    required bool reportsFailures,
    required OnBuildInterceptorsCallback buildInterceptors,
  }) {
    client.options
      ..baseUrl = baseUrl
      ..headers = {'Content-Type': 'application/json'}
      ..connectTimeout = _defaultTimeout
      ..receiveTimeout = _defaultTimeout
      ..sendTimeout = _defaultTimeout;

    // The chain is added in the order the builder returns it: the transport
    // runs request steps front to back, so that list IS the documented order.
    client.interceptors.addAll(buildInterceptors(client));

    return BackendHttpClient._(
      client: client,
      serverErrorMessageParser: backendErrorMessageParser,
      appLogger: appLogger,
      errorLogger: errorLogger,
      reportsFailures: reportsFailures,
    );
  }

  BackendHttpClient._({
    required super.client,
    required super.appLogger,
    required super.errorLogger,
    required super.reportsFailures,
    super.serverErrorMessageParser,
  });
}
