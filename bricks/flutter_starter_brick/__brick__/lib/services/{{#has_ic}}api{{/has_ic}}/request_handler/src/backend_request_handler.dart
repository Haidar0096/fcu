import 'package:{{proj_name}}/services/api/request_handler/src/base_request_handler.dart';
import 'package:{{proj_name}}/services/api/request_handler/src/interceptors.dart';
import 'package:{{proj_name}}/services/logger/app_logger.dart';
import 'package:{{proj_name}}/services/logger/error_logger.dart';
import 'package:dio/dio.dart';

const Duration _defaultTimeout = Duration(seconds: 10);

/// A request handler for backend requests.
///
/// This class is responsible for managing HTTP requests to the backend,
/// including setting up the Dio client with appropriate interceptors
/// and error handling mechanisms.
class BackendRequestHandler extends BaseRequestHandler {
  /// Creates a new backend request handler.
  /// - [appLogger] is the logger to be used for logging.
  /// - [errorLogger] is the error logger to be used for logging errors.
  /// - [baseUrl] is the base URL for the backend.
  /// - [cancellationErrorMessageResolver]
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.cancellation_error_message_resolver}
  /// - [networkErrorMessageResolver]
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.network_error_message_resolver}
  /// - [serverErrorMessageResolver]
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.server_error_message_resolver}
  /// - [generalErrorMessageResolver]
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.general_error_message_resolver}
  factory BackendRequestHandler({
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
    required String baseUrl,
    String? Function(dynamic response)? cancellationErrorMessageResolver,
    String? Function(dynamic response)? networkErrorMessageResolver,
    String? Function(dynamic response)? serverErrorMessageResolver,
    String? Function(dynamic response)? generalErrorMessageResolver,
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
        BaseRetryInterceptor(
          dio: dio,
          logger: appLogger,
        ),
        BaseLoggerInterceptor(),
        BaseErrorLoggerInterceptor(
          logger: appLogger,
          errorLogger: errorLogger,
        ),
      ],
    );

    return BackendRequestHandler._(
      client: dio,
      cancellationErrorMessageResolver: cancellationErrorMessageResolver,
      networkErrorMessageResolver: networkErrorMessageResolver,
      serverErrorMessageResolver: serverErrorMessageResolver,
      generalErrorMessageResolver: generalErrorMessageResolver,
    );
  }

  BackendRequestHandler._({
    required Dio client,
    super.cancellationErrorMessageResolver,
    super.networkErrorMessageResolver,
    super.serverErrorMessageResolver,
    super.generalErrorMessageResolver,
  }) : super(client);
}
