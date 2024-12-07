import 'package:dio/dio.dart';

String buildApiErrorReportingMessageFromGeneralError({
  Object? error,
  String? path,
  String? method,
  Map<String, dynamic>? queryParameters,
  Object? body,
  Map<String, dynamic>? headers,
}) {
  final buffer = StringBuffer()
    ..writeln('Request failed with error: $error')
    ..writeln('Request path was: $path')
    ..writeln('Request method was: $method')
    ..writeln('Request headers were: $headers')
    ..writeln('Request query parameters were: $queryParameters')
    ..writeln('Request data was: $body');
  return buffer.toString();
}

String buildApiErrorReportingMessageFromDioException(
  DioException dioException,
) {
  final buffer = StringBuffer()
    ..writeln(
      'Request to "${dioException.requestOptions.uri}" failed with error: '
      '$dioException',
    )
    ..writeln('Request method was: ${dioException.requestOptions.method}')
    ..writeln('Request headers were: ${dioException.requestOptions.headers}')
    ..writeln(
      'Request query parameters were: '
      '${dioException.requestOptions.queryParameters}',
    )
    ..writeln('Request data was: ${dioException.requestOptions.data}')
    ..writeln('Response was: ${dioException.response}');
  return buffer.toString();
}
