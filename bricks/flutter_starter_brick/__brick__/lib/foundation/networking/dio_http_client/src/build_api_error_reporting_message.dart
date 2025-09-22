import 'package:dio/dio.dart';
import 'package:{{proj_name}}/foundation/networking/dio_http_client/src/request_data_sanitizer.dart';

String buildApiErrorReportingMessageFromDioException(
  DioException dioException,
) {
  // Sanitize sensitive data before logging
  final sanitizedHeaders = RequestDataSanitizer.sanitizeHeaders(
    dioException.requestOptions.headers,
  );
  final sanitizedBody = RequestDataSanitizer.sanitizeBody(
    dioException.requestOptions.data,
  );

  final buffer =
      StringBuffer()
        ..writeln(
          'Request to "${dioException.requestOptions.uri}" failed with error: '
          '$dioException',
        )
        ..writeln('Request method was: ${dioException.requestOptions.method}')
        ..writeln('Request headers were: $sanitizedHeaders')
        ..writeln(
          'Request query parameters were: '
          '${dioException.requestOptions.queryParameters}',
        )
        ..writeln('Request data was: $sanitizedBody')
        ..writeln('Response was: ${dioException.response}');
  return buffer.toString();
}
