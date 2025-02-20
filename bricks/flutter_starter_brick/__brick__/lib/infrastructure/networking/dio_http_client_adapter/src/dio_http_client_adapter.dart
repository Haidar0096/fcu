import 'dart:io' hide HttpResponse;

import 'package:{{proj_name}}/infrastructure/basic_types/basic_types.dart';
import 'package:{{proj_name}}/infrastructure/networking/http_client_adapter/http_client_adapter.dart';
import 'package:dio/dio.dart' as dio;

class DioHttpClientAdapter extends HttpClientAdapter {
  DioHttpClientAdapter({
    required dio.Dio client,
    this.serverErrorMessageResolver,
  }) : _client = client;
  final dio.Dio _client;

  final String? Function(Object? error)? serverErrorMessageResolver;

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

      final options = dio.Options(
        headers: replacementHeaders ?? headers,
        method: method,
        validateStatus: responseStatusCodeValidator,
      );

      final response = await _client.request<dynamic>(
        path,
        queryParameters: queryParameters,
        data: body,
        options: options,
      );

      return Result.success(successResponseMapper(response.toHttpResponse));
    } on dio.DioException catch (dioException) {
      // Handle dio exceptions
      switch (dioException.type) {
        // Check for network errors
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.connectionError:
        case dio.DioExceptionType.unknown
            when dioException.error is SocketException:
          return Result.failure(
            NetworkError(
              statusCode: dioException.response?.statusCode,
              serverErrorMessage: serverErrorMessageResolver?.call(
                dioException.response?.toHttpResponse,
              ),
            ),
          );
        case dio.DioExceptionType.cancel:
          return Result.failure(
            CancelError(
              statusCode: dioException.response?.statusCode,
              serverErrorMessage: serverErrorMessageResolver?.call(
                dioException.response?.toHttpResponse,
              ),
            ),
          );
        case dio.DioExceptionType.badCertificate:
        case dio.DioExceptionType.badResponse:
          return Result.failure(
            ServerError(
              statusCode: dioException.response?.statusCode,
              serverErrorMessage: serverErrorMessageResolver?.call(
                dioException.response?.toHttpResponse,
              ),
            ),
          );
        case dio.DioExceptionType.unknown:
          return Result.failure(
            UnknownError(
              statusCode: dioException.response?.statusCode,
              serverErrorMessage: serverErrorMessageResolver?.call(
                dioException.response?.toHttpResponse,
              ),
            ),
          );
      }
    } catch (error) {
      return Result.failure(
        UnknownError(
          serverErrorMessage: serverErrorMessageResolver?.call(error),
        ),
      );
    }
  }
}

extension DioResponseExtension<T> on dio.Response<T> {
  HttpResponse<T> get toHttpResponse =>
      HttpResponse<T>(statusCode: statusCode, headers: headers.map, data: data);
}
