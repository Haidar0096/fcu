import 'dart:io' hide HttpResponse;

import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/basic_types/basic_types.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/cancel_token/cancel_token.dart';
import 'package:{{proj_name}}/foundation/networking/dio_http_client/src/request_data_sanitizer.dart';
import 'package:{{proj_name}}/foundation/networking/http_client/http_client.dart';
import 'package:{{proj_name}}/foundation/networking/models/models.dart';

/// An implementation of [HttpClient] that uses the Dio package for making
/// HTTP requests. The dio object can be provided to the constructor to allow
/// for customization of the client.
class DioHttpClient extends HttpClient {
  DioHttpClient({
    required dio.Dio client,
    this.serverErrorMessageParser,
    AppLogger? appLogger,
    ErrorLogger? errorLogger,
  }) : _client = client,
       _appLogger = appLogger,
       _errorLogger = errorLogger;

  final dio.Dio _client;
  final AppLogger? _appLogger;
  final ErrorLogger? _errorLogger;

  static const String _tag = 'DioHttpClient';

  /// A function that parses error response and returns message and code.
  final ({String? message, String? code})? Function(dynamic response)?
  serverErrorMessageParser;

  @override
  Future<Result<NetworkFailure, S>> request<S>({
    required String path,
    required String method,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    Object? body,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    if (additionalHeaders != null && replacementHeaders != null) {
      throw ArgumentError(
        'Cannot provide both additionalHeaders and replacementHeaders',
      );
    }

    try {
      final headers = <String, dynamic>{..._client.options.headers};
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final options = dio.Options(
        headers: replacementHeaders ?? headers,
        method: method,
        validateStatus: responseStatusCodeValidator,
      );

      // Extract Dio's CancelToken from our wrapper
      if (cancelToken != null && cancelToken is! DioCancelToken) {
        throw ArgumentError(
          'DioHttpClient requires DioCancelToken implementation',
        );
      }
      final dioCancelToken = (cancelToken as DioCancelToken?)?.dioToken;

      final response = await _client.request<dynamic>(
        path,
        queryParameters: queryParameters,
        data: body,
        options: options,
        onSendProgress: onSendProgress,
        cancelToken: dioCancelToken,
      );

      return Result.success(successResponseMapper(response.toHttpResponse));
    } on dio.DioException catch (dioException) {
      // Log detailed error information before converting to NetworkFailure
      final errorDetails = _buildDetailedErrorMessage(dioException, path);
      _appLogger?.log(errorDetails, tag: _tag);
      await _errorLogger?.recordError(
        error: errorDetails,
        stackTrace: dioException.stackTrace,
      );

      // Parse error data once
      final errorData = serverErrorMessageParser?.call(
        dioException.response?.data,
      );
      final statusCode = dioException.response?.statusCode;

      // Handle dio exceptions
      switch (dioException.type) {
        // Check for timeout errors
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
        case dio.DioExceptionType.connectionTimeout:
          return Result.failure(
            TimeoutError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
            ),
          );
        // Check for network errors
        case dio.DioExceptionType.connectionError:
        case dio.DioExceptionType.unknown
            when dioException.error is SocketException:
          return Result.failure(
            NetworkError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
            ),
          );
        case dio.DioExceptionType.cancel:
          return Result.failure(
            CancelError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
            ),
          );
        case dio.DioExceptionType.badCertificate:
        case dio.DioExceptionType.badResponse:
          return Result.failure(
            ServerError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
            ),
          );
        case dio.DioExceptionType.unknown:
          return Result.failure(
            UnknownError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
            ),
          );
      }
    } catch (error, stackTrace) {
      // Log general errors that aren't DioExceptions
      final errorMessage = 'Non-DioException error for $method $path: $error';
      _appLogger?.log(errorMessage, tag: _tag);
      await _errorLogger?.recordError(
        error: errorMessage,
        stackTrace: stackTrace,
      );

      final errorData = serverErrorMessageParser?.call(error);
      return Result.failure(
        UnknownError(message: errorData?.message, code: errorData?.code),
      );
    }
  }

  /// Builds a detailed error message from a DioException for logging
  String _buildDetailedErrorMessage(
    dio.DioException dioException,
    String path,
  ) {
    final sanitizedHeaders = RequestDataSanitizer.sanitizeHeaders(
      dioException.requestOptions.headers,
    );
    final sanitizedData = RequestDataSanitizer.sanitizeBody(
      dioException.requestOptions.data,
    );

    final buffer =
        StringBuffer()
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
}

extension DioResponseExtension<T> on dio.Response<T> {
  HttpResponse<T> get toHttpResponse =>
      HttpResponse<T>(statusCode: statusCode, headers: headers.map, data: data);
}
