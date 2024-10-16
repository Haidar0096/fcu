import 'dart:io';

import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/services/logger/error_logger.dart';
import 'package:dio/dio.dart';

/// Base class for request handlers.
abstract class BaseRequestHandler {
  /// Creates a new request handler.
  /// - [client] is the underlying client to be used for making requests.
  /// - [cancellationErrorMessageResolver]
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.cancellation_error_message_resolver}
  /// - [networkErrorMessageResolver]
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.network_error_message_resolver}
  /// - [serverErrorMessageResolver]
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.server_error_message_resolver}
  /// - [generalErrorMessageResolver]
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.general_error_message_resolver}
  const BaseRequestHandler(
    Dio client, {
    this.cancellationErrorMessageResolver,
    this.networkErrorMessageResolver,
    this.serverErrorMessageResolver,
    this.generalErrorMessageResolver,
  }) : _client = client;

  final Dio _client;

  // ignore: lines_longer_than_80_chars
  /// {@template {{org_name}}.{{proj_name}}.cancellation_error_message_resolver}
  /// Callback to be called to determine the error message to be returned when
  /// the request is cancelled.
  /// {@endtemplate}
  final String? Function(dynamic response)? cancellationErrorMessageResolver;
  
  // ignore: lines_longer_than_80_chars
  /// {@template {{org_name}}.{{proj_name}}.network_error_message_resolver}
  /// Callback to be called to determine the error message to be returned when
  /// the request fails due to network issues.
  /// {@endtemplate}
  final String? Function(dynamic response)? networkErrorMessageResolver;

  // ignore: lines_longer_than_80_chars
  /// {@template {{org_name}}.{{proj_name}}.server_error_message_resolver}
  /// Callback to be called to determine the error message to be returned when
  /// the request fails due to server issues.
  /// {@endtemplate}
  final String? Function(dynamic response)? serverErrorMessageResolver;

  // ignore: lines_longer_than_80_chars
  /// {@template {{org_name}}.{{proj_name}}.general_error_message_resolver}
  /// Callback to be called to determine the error message to be returned when
  /// the request fails due to other issues.
  /// {@endtemplate}
  final String? Function(dynamic response)? generalErrorMessageResolver;

  /// Executes an API request.
  /// - [S] is the type of the success data.
  /// - [replacementHeaders] if provided, are the headers that will replace the
  /// existing headers of the underlying client. If provided, then client
  /// headers and additional headers will be ignored.
  /// - [additionalHeaders] are the headers that will be added to the existing
  /// headers of the underlying client.
  /// - [successResultMapper] is a function that maps the response data to the
  /// desired success result type. It is passed the response.
  Future<ApiResponse<S>> executeRequest<S>({
    required String path,
    required String method,
    required S? Function(dynamic response) successResultMapper,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Map<String, String>? additionalHeaders,
    Map<String, String>? replacementHeaders,
    CancelToken? cancelToken,
    bool Function(int?)? validateStatus,
  }) async {
    assert(
      additionalHeaders == null || replacementHeaders == null,
      'Only one of additionalHeaders or replacementHeaders can be provided',
    );

    try {
      final headers = <String, dynamic>{..._client.options.headers};
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final options = Options(
        headers: replacementHeaders ?? headers,
        method: method,
        validateStatus: validateStatus,
      );

      final response = await _client.request<dynamic>(
        path,
        queryParameters: queryParameters,
        data: body,
        options: options,
        cancelToken: cancelToken,
      );

      return ApiResponseSuccess(
        data: successResultMapper(response),
        statusCode: response.statusCode,
      );
    } on DioException catch (dioException, stackTrace) {
      // Handle dio exceptions

      await ServiceProvider.get<ErrorLogger>()
          .recordError(error: dioException, stackTrace: stackTrace);

      switch (dioException.type) {
        // Check for network errors
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown
            when dioException.error is SocketException:
          return ApiNetworkFailure(
            error: dioException,
            stackTrace: stackTrace,
            statusCode: dioException.response?.statusCode,
            uiErrorMessage:
                networkErrorMessageResolver?.call(dioException.response) ??
                    'A network error has occurred',
          );
        case DioExceptionType.cancel:
          return ApiCancellationFailure(
            error: dioException,
            stackTrace: stackTrace,
            statusCode: dioException.response?.statusCode,
            uiErrorMessage:
                cancellationErrorMessageResolver?.call(dioException.response) ??
                    'The request has been cancelled',
          );
        case DioExceptionType.badCertificate:
        case DioExceptionType.badResponse:
          return ApiServerFailure(
            error: dioException,
            stackTrace: stackTrace,
            statusCode: dioException.response?.statusCode,
            uiErrorMessage:
                serverErrorMessageResolver?.call(dioException.response) ??
                    'An error has occurred',
          );
        case DioExceptionType.unknown:
          return ApiGeneralFailure(
            error: dioException,
            stackTrace: stackTrace,
            statusCode: dioException.response?.statusCode,
            uiErrorMessage:
                generalErrorMessageResolver?.call(dioException.response) ??
                    'An error has occurred',
          );
      }
    } catch (error, stackTrace) {
      // Handle other errors

      await ServiceProvider.get<ErrorLogger>().recordError(
        error: error,
        stackTrace: stackTrace,
      );

      return ApiGeneralFailure(
        error: error,
        stackTrace: stackTrace,
        uiErrorMessage:
            generalErrorMessageResolver?.call(error) ?? 'An error has occurred',
      );
    }
  }
}

/// Represents the result of an API call.
///
/// - [S] is the type of the success data.
sealed class ApiResponse<S> {
  const ApiResponse();
}

/// Represents a successful API call.
final class ApiResponseSuccess<S> extends ApiResponse<S> {
  const ApiResponseSuccess({
    this.data,
    this.statusCode,
  });

  /// The data returned by the API call.
  final S? data;

  /// The HTTP status code of the response.
  final int? statusCode;

  /// Maps the success data to a new type.
  ///
  /// - [T] is the type to map the success data to.
  /// - [mapper] is a function that converts from [S] to [T].
  ApiResponseSuccess<T> mapData<T>(T? Function(S?) mapper) =>
      ApiResponseSuccess<T>(data: mapper(data), statusCode: statusCode);
}

/// Represents a failed API call.
sealed class ApiResponseFailure extends ApiResponse<Never> {
  const ApiResponseFailure({
    required this.stackTrace,
    required this.uiErrorMessage,
    this.statusCode,
    this.error,
  });

  /// The HTTP status code of the response, if available.
  final int? statusCode;

  /// The error object, if any.
  final Object? error;

  /// The stack trace of the error.
  final StackTrace stackTrace;

  /// An error message suitable for displaying to the user.
  final String uiErrorMessage;
}

/// Represents network-related errors.
final class ApiNetworkFailure extends ApiResponseFailure {
  const ApiNetworkFailure({
    required super.stackTrace,
    required super.uiErrorMessage,
    super.statusCode,
    super.error,
  });
}

/// Represents server-related errors.
final class ApiServerFailure extends ApiResponseFailure {
  const ApiServerFailure({
    required super.stackTrace,
    required super.uiErrorMessage,
    super.statusCode,
    super.error,
  });
}

/// Represents cancellation errors, i.e., when the request is cancelled.
final class ApiCancellationFailure extends ApiResponseFailure {
  const ApiCancellationFailure({
    required super.stackTrace,
    required super.uiErrorMessage,
    super.statusCode,
    super.error,
  });
}

/// Represents general errors that cannot be classified as other error types.
///
/// This includes errors occurring in the client code or when the error
/// cannot be classified as one of the other specific error types.
final class ApiGeneralFailure extends ApiResponseFailure {
  const ApiGeneralFailure({
    required super.stackTrace,
    required super.uiErrorMessage,
    super.statusCode,
    super.error,
  });
}
