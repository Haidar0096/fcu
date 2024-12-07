import 'package:dio/dio.dart';
import 'package:{{proj_name}}/common/logging/logging.dart';

import 'build_api_error_reporting_message.dart';

/// An interceptor for logging errors during API requests.
class BaseErrorLoggerInterceptor extends Interceptor {
  BaseErrorLoggerInterceptor({
    required this.appLogger,
    required this.errorLogger,
  });

  final AppLogger appLogger;
  final ErrorLogger errorLogger;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final message = buildApiErrorReportingMessageFromDioException(err);
    appLogger.log(message);
    await errorLogger.recordError(
      error: message,
      stackTrace: err.stackTrace,
    );
    return super.onError(err, handler);
  }
}
