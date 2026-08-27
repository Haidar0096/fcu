import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/basic_types/basic_types.dart';
import 'package:{{proj_name}}/foundation/extensions/extensions.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/src/cancel_token.dart';
import 'package:{{proj_name}}/foundation/networking/src/dio_error_message_builder.dart';
import 'package:{{proj_name}}/foundation/networking/src/http_client.dart';
import 'package:{{proj_name}}/foundation/networking/src/http_response.dart';
import 'package:{{proj_name}}/foundation/networking/src/network_failure.dart';
import 'package:{{proj_name}}/foundation/networking/src/socket_exception.dart';

/// An implementation of [HttpClient] that uses the Dio package for making
/// HTTP requests. The dio object can be provided to the constructor to allow
/// for customization of the client.
class DioHttpClient extends HttpClient {
  DioHttpClient({
    required dio.Dio client,
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
    this.serverErrorMessageParser,
  }) : _client = client,
       _appLogger = appLogger,
       _errorLogger = errorLogger;

  final dio.Dio _client;
  final AppLogger _appLogger;
  final ErrorLogger _errorLogger;

  static const String _tag = 'DioHttpClient';

  /// The header the project's backend echoes its correlation id under, on
  /// every response — success and error alike. Reading it here is the one
  /// place the id enters the app: this is where a transport failure is
  /// classified, so this is where the id joins the failure it belongs to.
  static const String _correlationIdHeader = 'x-correlation-id';

  /// A function that parses error response and returns message and code.
  final ({String? message, String? code})? Function(dynamic response)?
  serverErrorMessageParser;

  @override
  Future<Result<NetworkFailure, S>> get<S>({
    required String path,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    CancelToken? cancelToken,
  }) => _request(
    path: path,
    method: 'GET',
    successResponseMapper: successResponseMapper,
    queryParameters: queryParameters,
    additionalHeaders: additionalHeaders,
    replacementHeaders: replacementHeaders,
    responseStatusCodeValidator: responseStatusCodeValidator,
    cancelToken: cancelToken,
  );

  @override
  Future<Result<NetworkFailure, S>> post<S>({
    required String path,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Object? body,
    bool isMultipart = false,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    CancelToken? cancelToken,
  }) => _request(
    path: path,
    method: 'POST',
    successResponseMapper: successResponseMapper,
    body: body,
    isMultipart: isMultipart,
    queryParameters: queryParameters,
    additionalHeaders: additionalHeaders,
    replacementHeaders: replacementHeaders,
    responseStatusCodeValidator: responseStatusCodeValidator,
    cancelToken: cancelToken,
  );

  @override
  Future<Result<NetworkFailure, S>> put<S>({
    required String path,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    CancelToken? cancelToken,
  }) => _request(
    path: path,
    method: 'PUT',
    successResponseMapper: successResponseMapper,
    body: body,
    queryParameters: queryParameters,
    additionalHeaders: additionalHeaders,
    replacementHeaders: replacementHeaders,
    responseStatusCodeValidator: responseStatusCodeValidator,
    cancelToken: cancelToken,
  );

  @override
  Future<Result<NetworkFailure, S>> patch<S>({
    required String path,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Object? body,
    bool isMultipart = false,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    CancelToken? cancelToken,
  }) => _request(
    path: path,
    method: 'PATCH',
    successResponseMapper: successResponseMapper,
    body: body,
    isMultipart: isMultipart,
    queryParameters: queryParameters,
    additionalHeaders: additionalHeaders,
    replacementHeaders: replacementHeaders,
    responseStatusCodeValidator: responseStatusCodeValidator,
    cancelToken: cancelToken,
  );

  @override
  Future<Result<NetworkFailure, S>> delete<S>({
    required String path,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    CancelToken? cancelToken,
  }) => _request(
    path: path,
    method: 'DELETE',
    successResponseMapper: successResponseMapper,
    queryParameters: queryParameters,
    additionalHeaders: additionalHeaders,
    replacementHeaders: replacementHeaders,
    responseStatusCodeValidator: responseStatusCodeValidator,
    cancelToken: cancelToken,
  );

  @override
  Future<Result<NetworkFailure, S>> uploadFile<S>({
    required String path,
    required String filePath,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final fileName = filePath.baseName;

    final formData = dio.FormData.fromMap({
      fieldName: await dio.MultipartFile.fromFile(filePath, filename: fileName),
      ...?additionalFields,
    });

    return _request(
      path: path,
      method: 'POST',
      body: formData,
      successResponseMapper: successResponseMapper,
      queryParameters: queryParameters,
      additionalHeaders: additionalHeaders,
      replacementHeaders: replacementHeaders,
      responseStatusCodeValidator: responseStatusCodeValidator,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Result<NetworkFailure, S>> uploadBytes<S>({
    required String path,
    required Uint8List bytes,
    required String filename,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    final formData = dio.FormData.fromMap({
      fieldName: dio.MultipartFile.fromBytes(bytes, filename: filename),
      ...?additionalFields,
    });

    return _request(
      path: path,
      method: 'POST',
      body: formData,
      successResponseMapper: successResponseMapper,
      queryParameters: queryParameters,
      additionalHeaders: additionalHeaders,
      replacementHeaders: replacementHeaders,
      responseStatusCodeValidator: responseStatusCodeValidator,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  /// Internal request method that handles all HTTP requests.
  ///
  /// All public methods delegate to this method.
  Future<Result<NetworkFailure, S>> _request<S>({
    required String path,
    required String method,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    Object? body,
    bool isMultipart = false,
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

      // Convert body to FormData if multipart is requested
      final requestBody = isMultipart && body != null
          ? dio.FormData.fromMap(body as Map<String, dynamic>)
          : body;

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
        data: requestBody,
        options: options,
        onSendProgress: onSendProgress,
        cancelToken: dioCancelToken,
      );

      return Result.success(successResponseMapper(response.toHttpResponse));
    } on dio.DioException catch (dioException) {
      // Parse error data once
      final errorData = serverErrorMessageParser?.call(
        dioException.response?.data,
      );
      final statusCode = dioException.response?.statusCode;
      final correlationId = _readCorrelationId(dioException.response);

      // A user backing out is not a failure: it is returned here, before the
      // log-and-report block, so a cancellation never reaches the crash
      // dashboard.
      if (dioException.type == dio.DioExceptionType.cancel) {
        return Result.failure(
          CancelError(
            statusCode: statusCode,
            message: errorData?.message,
            code: errorData?.code,
            backendCorrelationId: correlationId,
          ),
        );
      }

      // Log detailed error information before converting to NetworkFailure
      final errorDetails = buildDetailedErrorMessage(dioException, path);
      _appLogger.log(errorDetails, tag: _tag);
      await _errorLogger.recordError(
        error: errorDetails,
        stackTrace: dioException.stackTrace,
        backendCorrelationId: correlationId,
      );

      // Handle dio exceptions
      switch (dioException.type) {
        // Check for timeout errors
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.transformTimeout:
          return Result.failure(
            TimeoutError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
              backendCorrelationId: correlationId,
            ),
          );
        // Check for network errors
        case dio.DioExceptionType.connectionError:
        case dio.DioExceptionType.unknown
            when isSocketException(dioException.error):
          return Result.failure(
            NetworkError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
              backendCorrelationId: correlationId,
            ),
          );
        case dio.DioExceptionType.cancel:
          return Result.failure(
            CancelError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
              backendCorrelationId: correlationId,
            ),
          );
        case dio.DioExceptionType.badCertificate:
        case dio.DioExceptionType.badResponse:
          return Result.failure(
            ServerError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
              backendCorrelationId: correlationId,
            ),
          );
        case dio.DioExceptionType.unknown:
          return Result.failure(
            UnknownError(
              statusCode: statusCode,
              message: errorData?.message,
              code: errorData?.code,
              backendCorrelationId: correlationId,
            ),
          );
      }
    } catch (error, stackTrace) {
      // Log general errors that aren't DioExceptions
      final errorMessage = 'Non-DioException error for $method $path: $error';
      _appLogger.log(errorMessage, tag: _tag);
      await _errorLogger.recordError(
        error: errorMessage,
        stackTrace: stackTrace,
      );

      final errorData = serverErrorMessageParser?.call(error);
      return Result.failure(
        UnknownError(message: errorData?.message, code: errorData?.code),
      );
    }
  }

  static String? _readCorrelationId(dio.Response<dynamic>? response) =>
      response?.headers.value(_correlationIdHeader);
}

extension DioResponseExtension<T> on dio.Response<T> {
  HttpResponse<T> get toHttpResponse =>
      HttpResponse<T>(statusCode: statusCode, headers: headers.map, data: data);
}
