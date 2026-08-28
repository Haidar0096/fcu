import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/logging/logging.dart';

String buildDetailedErrorMessage({
  required dio.DioException dioException,
  required String path,
}) {
  final sanitizedHeaders = SensitiveDataSanitizer.sanitizeHeaders(
    dioException.requestOptions.headers,
  );
  final sanitizedData = SensitiveDataSanitizer.sanitizeBody(
    dioException.requestOptions.data,
  );
  final sanitizedResponseData = SensitiveDataSanitizer.sanitizeBody(
    dioException.response?.data,
  );
  final sanitizedMessage = SensitiveDataSanitizer.sanitizeText(
    '${dioException.message}',
  );

  final buffer = StringBuffer()
    ..writeln('DioException for $path:')
    ..writeln('  Type: ${dioException.type}')
    ..writeln('  Message: $sanitizedMessage')
    ..writeln('  Status Code: ${dioException.response?.statusCode}')
    ..writeln('  Response Data: $sanitizedResponseData')
    ..writeln('  Request Method: ${dioException.requestOptions.method}')
    ..writeln('  Request Path: $path')
    ..writeln('  Request Headers: $sanitizedHeaders')
    ..writeln('  Request Data: $sanitizedData');

  if (dioException.error != null) {
    final sanitizedError = SensitiveDataSanitizer.sanitizeText(
      '${dioException.error}',
    );
    buffer.writeln('  Underlying Error: $sanitizedError');
  }

  return buffer.toString();
}
