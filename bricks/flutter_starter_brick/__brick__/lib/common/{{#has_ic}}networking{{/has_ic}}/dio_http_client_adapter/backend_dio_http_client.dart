import 'package:dio/dio.dart';
import 'package:{{proj_name}}/common/logging/logging.dart';

import 'dio_http_client_adapter.dart';
import 'interceptors.dart';

const Duration _defaultTimeout = Duration(seconds: 30);

/// A request handler for backend requests.
///
/// This class is responsible for managing HTTP requests to the backend,
/// including setting up the Dio client with appropriate interceptors
/// and error handling mechanisms.
class BackendDioHttpClient extends DioHttpClientAdapter {
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
        headers: {
          'Content-Type': 'application/json',
        },
        connectTimeout: _defaultTimeout,
        receiveTimeout: _defaultTimeout,
        sendTimeout: _defaultTimeout,
      ),
    );

    // Add interceptors for logging and error handling
    dio.interceptors.addAll(
      [
        BaseErrorLoggerInterceptor(
          appLogger: appLogger,
          errorLogger: errorLogger,
        ),
      ],
    );

    return BackendDioHttpClient._(client: dio);
  }

  BackendDioHttpClient._({required super.client})
      : super(serverErrorMessageResolver: null);
}
