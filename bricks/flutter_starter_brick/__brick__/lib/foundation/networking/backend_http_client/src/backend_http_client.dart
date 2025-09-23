import 'package:dio/dio.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/backend_http_client/src/backend_error_message_parser.dart';
import 'package:{{proj_name}}/foundation/networking/dio_http_client/src/dio_http_client.dart';

const Duration _defaultTimeout = Duration(seconds: 30);

/// A request handler for backend requests.
///
/// This class is responsible for managing HTTP requests to the backend,
/// including setting up the Dio client with appropriate interceptors
/// and error handling mechanisms.
final class BackendHttpClient extends DioHttpClient {
  /// Creates a new backend request handler.
  /// - [appLogger] is the logger to be used for logging.
  /// - [errorLogger] is the error logger to be used for logging errors.
  /// - [baseUrl] is the base URL for the backend.
  /// - [interceptorsBuilder] is an optional factory function that receives the
  /// Dio instance and returns the list of interceptors to be added.
  factory BackendHttpClient({
    required String baseUrl,
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
    List<Interceptor> Function(Dio dio)? interceptorsBuilder,
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

    // Get interceptors from factory if provided
    final interceptors = interceptorsBuilder?.call(dio) ?? [];
    if (interceptors.isNotEmpty) {
      dio.interceptors.addAll(interceptors);
    }

    return BackendHttpClient._(
      client: dio,
      serverErrorMessageParser: backendErrorMessageParser,
      appLogger: appLogger,
      errorLogger: errorLogger,
    );
  }

  BackendHttpClient._({
    required super.client,
    super.serverErrorMessageParser,
    super.appLogger,
    super.errorLogger,
  });
}
