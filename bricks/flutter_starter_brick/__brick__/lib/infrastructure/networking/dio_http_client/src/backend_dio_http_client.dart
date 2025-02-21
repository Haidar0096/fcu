import 'package:dio/dio.dart';
import 'package:{{proj_name}}/infrastructure/logging/logging.dart';
import 'package:{{proj_name}}/infrastructure/networking/dio_http_client/src/dio_http_client.dart';
import 'package:{{proj_name}}/infrastructure/networking/dio_http_client/src/interceptors.dart';

const Duration _defaultTimeout = Duration(seconds: 30);

/// A request handler for backend requests.
///
/// This class is responsible for managing HTTP requests to the backend,
/// including setting up the Dio client with appropriate interceptors
/// and error handling mechanisms.
class BackendDioHttpClient extends DioHttpClient {
  /// Creates a new backend request handler.
  /// - [appLogger] is the logger to be used for logging.
  /// - [errorLogger] is the error logger to be used for logging errors.
  /// - [baseUrl] is the base URL for the backend.
  factory BackendDioHttpClient({
    required String baseUrl,
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: _defaultTimeout,
        receiveTimeout: _defaultTimeout,
        sendTimeout: _defaultTimeout,
      ),
    );

    // Add interceptors for logging and error handling
    dio.interceptors.addAll([
      ErrorLoggerInterceptor(appLogger: appLogger, errorLogger: errorLogger),
    ]);

    return BackendDioHttpClient._(client: dio);
  }

  BackendDioHttpClient._({required super.client});
}
