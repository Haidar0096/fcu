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
  final sanitizedTarget = sanitizeRequestTarget(path);

  final buffer = StringBuffer()
    ..writeln('DioException for $sanitizedTarget:')
    ..writeln('  Type: ${dioException.type}')
    ..writeln('  Message: $sanitizedMessage')
    ..writeln('  Status Code: ${dioException.response?.statusCode}')
    ..writeln('  Response Data: $sanitizedResponseData')
    ..writeln('  Request Method: ${dioException.requestOptions.method}')
    ..writeln('  Request Path: $sanitizedTarget')
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

/// Removes every path segment and query value from a request target before it
/// enters a recorded trail. The remaining markers preserve only route shape.
String sanitizeRequestTarget(String requestTarget) {
  final uri = Uri.tryParse(requestTarget);
  if (uri == null) return '[REDACTED]';

  final redactedSegments = uri.pathSegments
      .map((_) => '[REDACTED]')
      .join('/');
  final redactedPath = uri.pathSegments.isEmpty
      ? '/'
      : '${uri.path.startsWith('/') ? '/' : ''}$redactedSegments';
  return uri.hasQuery ? '$redactedPath?[REDACTED]' : redactedPath;
}
