import 'dart:io' hide HttpResponse;

import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/infrastructure/basic_types/basic_types.dart';
import 'package:{{proj_name}}/infrastructure/networking/http_client/http_client.dart';

/// An implementation of [HttpClient] that uses the Dio package for making
/// HTTP requests. The dio object can be provided to the constructor to allow
/// for customization of the client.
class DioHttpClient extends HttpClient {
  DioHttpClient({required dio.Dio client}) : _client = client;
  final dio.Dio _client;

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
              serverErrorMessage:
                  ApiErrorDTO.fromObject(dioException.response?.data)?.message,
            ),
          );
        case dio.DioExceptionType.cancel:
          return Result.failure(
            CancelError(
              statusCode: dioException.response?.statusCode,
              serverErrorMessage:
                  ApiErrorDTO.fromObject(dioException.response?.data)?.message,
            ),
          );
        case dio.DioExceptionType.badCertificate:
        case dio.DioExceptionType.badResponse:
          return Result.failure(
            ServerError(
              statusCode: dioException.response?.statusCode,
              serverErrorMessage:
                  ApiErrorDTO.fromObject(dioException.response?.data)?.message,
            ),
          );
        case dio.DioExceptionType.unknown:
          return Result.failure(
            UnknownError(
              statusCode: dioException.response?.statusCode,
              serverErrorMessage:
                  ApiErrorDTO.fromObject(dioException.response?.data)?.message,
            ),
          );
      }
    } catch (error) {
      return Result.failure(const UnknownError());
    }
  }
}

extension DioResponseExtension<T> on dio.Response<T> {
  HttpResponse<T> get toHttpResponse =>
      HttpResponse<T>(statusCode: statusCode, headers: headers.map, data: data);
}
