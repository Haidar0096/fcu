import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/networking/src/request_data_sanitizer.dart';

/// Builds a detailed error message from a DioException for logging
String buildDetailedErrorMessage(dio.DioException dioException, String path) {
  final sanitizedHeaders = RequestDataSanitizer.sanitizeHeaders(
    dioException.requestOptions.headers,
  );
  final sanitizedData = RequestDataSanitizer.sanitizeBody(
    dioException.requestOptions.data,
  );

  final buffer = StringBuffer()
    ..writeln('DioException for $path:')
    ..writeln('  Type: ${dioException.type}')
    ..writeln('  Message: ${dioException.message}')
    ..writeln('  Status Code: ${dioException.response?.statusCode}')
    ..writeln('  Response Data: ${dioException.response?.data}')
    ..writeln('  Request Method: ${dioException.requestOptions.method}')
    ..writeln('  Request Full Path: ${dioException.requestOptions.uri}')
    ..writeln('  Request Headers: $sanitizedHeaders')
    ..writeln('  Request Data: $sanitizedData');

  if (dioException.error != null) {
    buffer.writeln('  Underlying Error: ${dioException.error}');
  }

  return buffer.toString();
}
