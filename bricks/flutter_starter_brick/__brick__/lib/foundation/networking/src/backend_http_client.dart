import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/src/backend_error_message_parser.dart';
import 'package:{{proj_name}}/foundation/networking/src/dio_http_client.dart';

const Duration _defaultTimeout = Duration(seconds: 30);

/// A request handler for backend requests.
///
/// This class sets the base URL, the default headers, the timeouts and the
/// injected error parser — once, here.
final class BackendHttpClient extends DioHttpClient {
  /// Creates a backend handler with the wrapper's default Dio transport.
  factory BackendHttpClient.standard({
    required String baseUrl,
    required AppLogger appLogger,
    required ErrorLogger? errorLogger,
    required bool reportsFailures,
  }) => BackendHttpClient(
    client: dio.Dio(),
    baseUrl: baseUrl,
    appLogger: appLogger,
    errorLogger: errorLogger,
    reportsFailures: reportsFailures,
  );

  /// Creates a new backend request handler.
  /// - [appLogger] is the logger to be used for logging.
  /// - [errorLogger] is the error logger to be used for logging errors.
  /// - [baseUrl] is the base URL for the backend.
  factory BackendHttpClient({
    required dio.Dio client,
    required String baseUrl,
    required AppLogger appLogger,
    required ErrorLogger? errorLogger,
    required bool reportsFailures,
  }) {
    client.options
      ..baseUrl = baseUrl
      ..headers = {'Content-Type': 'application/json'}
      ..connectTimeout = _defaultTimeout
      ..receiveTimeout = _defaultTimeout
      ..sendTimeout = _defaultTimeout;

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
