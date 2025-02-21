import 'package:{{proj_name}}/infrastructure/logging/logging.dart';
import 'package:{{proj_name}}/infrastructure/networking/dio_http_client/src/build_api_error_reporting_message.dart';
import 'package:dio/dio.dart';

/// An interceptor for logging errors during API requests.
class ErrorLoggerInterceptor extends Interceptor {
  ErrorLoggerInterceptor({required this.appLogger, required this.errorLogger});

  final AppLogger appLogger;
  final ErrorLogger errorLogger;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final message = buildApiErrorReportingMessageFromDioException(err);
    appLogger.log(message);
    await errorLogger.recordError(error: message, stackTrace: err.stackTrace);
    return super.onError(err, handler);
  }
}
