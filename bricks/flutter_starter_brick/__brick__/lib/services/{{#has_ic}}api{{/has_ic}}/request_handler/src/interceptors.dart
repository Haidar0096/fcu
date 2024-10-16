import 'package:{{proj_name}}/services/logger/app_logger.dart';
import 'package:{{proj_name}}/services/logger/error_logger.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart' as dsr;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// A base class for Dio interceptors that delegates to a specific interceptor.
abstract class BaseWrapperInterceptor extends Interceptor {
  const BaseWrapperInterceptor(this._interceptor);

  final Interceptor _interceptor;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _interceptor.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _interceptor.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _interceptor.onError(err, handler);
  }
}

/// An interceptor that retries failed requests.
class BaseRetryInterceptor extends BaseWrapperInterceptor {
  BaseRetryInterceptor({
    required Dio dio,
    required AppLogger logger,
  }) : super(
          dsr.RetryInterceptor(
            dio: dio,
            logPrint: (message) => logger.log(
              message,
              tag: 'RetryInterceptor#logPrint',
            ),
            retries: 2,
            retryDelays: const [
              Duration(milliseconds: 100),
              Duration(milliseconds: 100),
            ],
          ),
        );
}

/// An interceptor that logs HTTP requests and responses.
class BaseLoggerInterceptor extends BaseWrapperInterceptor {
  BaseLoggerInterceptor()
      : super(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
          ),
        );
}

/// An interceptor for logging errors during API requests.
class BaseErrorLoggerInterceptor extends Interceptor {
  BaseErrorLoggerInterceptor({
    required this.logger,
    required this.errorLogger,
  });

  final AppLogger logger;
  final ErrorLogger errorLogger;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final message =
        'Request to "${err.requestOptions.uri}" failed with this error: $err,'
        '\nresponse was: ${err.response}';
    logger.log(message);
    await errorLogger.recordError(
      error: err,
      stackTrace: err.stackTrace,
    );
    return super.onError(err, handler);
  }
}
