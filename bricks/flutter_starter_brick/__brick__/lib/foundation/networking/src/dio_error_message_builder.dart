import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/logging/logging.dart';

/// Builds a detailed error message from a DioException for logging
String buildDetailedErrorMessage(dio.DioException dioException, String path) {
  final sanitizedHeaders = SensitiveDataSanitizer.sanitizeHeaders(
    dioException.requestOptions.headers,
  );
  final sanitizedData = SensitiveDataSanitizer.sanitizeBody(
    dioException.requestOptions.data,
  );
  final sanitizedResponseData = SensitiveDataSanitizer.sanitizeBody(
    dioException.response?.data,
  );

  final buffer = StringBuffer()
    ..writeln('DioException for $path:')
    ..writeln('  Type: ${dioException.type}')
    ..writeln('  Message: ${dioException.message}')
    ..writeln('  Status Code: ${dioException.response?.statusCode}')
    ..writeln('  Response Data: $sanitizedResponseData')
    ..writeln('  Request Method: ${dioException.requestOptions.method}')
    ..writeln('  Request Full Path: ${dioException.requestOptions.uri}')
    ..writeln('  Request Headers: $sanitizedHeaders')
    ..writeln('  Request Data: $sanitizedData');

  if (dioException.error != null) {
    buffer.writeln('  Underlying Error: ${dioException.error}');
  }

  return buffer.toString();
}
