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
    required ErrorLogger? errorLogger,
    required bool reportsFailures,
    this.serverErrorMessageParser,
  }) : assert(
         !reportsFailures || errorLogger != null,
         'A failure-reporting client requires an ErrorLogger.',
       ),
       _client = client,
       _appLogger = appLogger,
       _errorLogger = errorLogger,
       _reportsFailures = reportsFailures;

  final dio.Dio _client;
  final AppLogger _appLogger;
  final ErrorLogger? _errorLogger;
  final bool _reportsFailures;

  static const String _tag = 'DioHttpClient';

  /// The header the project's backend echoes its correlation id under, on
  /// every response — success and error alike. Reading it here is the one
  /// place the id enters the app: this is where a transport failure is
  /// classified, so this is where the id joins the failure it belongs to.
  static const String _correlationIdHeader = 'X-Correlation-Id';

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
    isMultipart: false,
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
    required bool isMultipart,
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
    isMultipart: false,
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
    required bool isMultipart,
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
    isMultipart: false,
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
    String? fieldName,
    Map<String, dynamic>? additionalFields,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    OnProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final fileName = filePath.baseName;
      final formData = dio.FormData.fromMap({
        fieldName ?? 'file': await dio.MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        ...?additionalFields,
      });

      return await _request(
        path: path,
        method: 'POST',
        isMultipart: false,
        body: formData,
        successResponseMapper: successResponseMapper,
        queryParameters: queryParameters,
        additionalHeaders: additionalHeaders,
        replacementHeaders: replacementHeaders,
        responseStatusCodeValidator: responseStatusCodeValidator,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } catch (error, stackTrace) {
      return _unexpectedFailure(
        operation: 'File upload preparation',
        method: 'POST',
        path: path,
        error: error,
        stackTrace: stackTrace,
        parseServerError: false,
      );
    }
  }

  @override
  Future<Result<NetworkFailure, S>> uploadBytes<S>({
    required String path,
    required Uint8List bytes,
    required String filename,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    String? fieldName,
    Map<String, dynamic>? additionalFields,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    OnProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    final formData = dio.FormData.fromMap({
      fieldName ?? 'file': dio.MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
      ...?additionalFields,
    });

    return _request(
      path: path,
      method: 'POST',
      isMultipart: false,
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
    required bool isMultipart,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    OnProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    if (additionalHeaders != null && replacementHeaders != null) {
      return _unexpectedFailure(
        operation: 'Request header validation',
        method: method,
        path: path,
        error: ArgumentError(
          'Cannot provide both additionalHeaders and replacementHeaders',
        ),
        stackTrace: StackTrace.current,
        parseServerError: false,
      );
    }

    try {
      final headers = <String, dynamic>{..._client.options.headers};
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final requestBody = isMultipart && body != null
          ? dio.FormData.fromMap(body as Map<String, dynamic>)
          : body;

      final options = dio.Options(
        headers: replacementHeaders ?? headers,
        method: method,
        validateStatus: responseStatusCodeValidator,
      );

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

      return Result.success(
        data: successResponseMapper(response.toHttpResponse),
      );
    } on dio.DioException catch (dioException) {
      final statusCode = dioException.response?.statusCode;
      final correlationId = _readCorrelationId(dioException.response);

      // A user backing out is not a failure: it is returned here, before the
      // log-and-report block, so a cancellation never reaches the crash
      // dashboard.
      if (dioException.type == dio.DioExceptionType.cancel) {
        return Result.failure(
          data: CancelError(
            statusCode: statusCode,
            message: null,
            code: null,
            backendCorrelationId: correlationId,
          ),
        );
      }

      final errorData = await _parseServerErrorSafely(
        response: dioException.response?.data,
        method: method,
        path: path,
        backendCorrelationId: correlationId,
      );

      final errorDetails = buildDetailedErrorMessage(
        dioException: dioException,
        path: path,
      );
      _appLogger.log(
        message: errorDetails,
        tag: _tag,
        stackTrace: dioException.stackTrace,
      );
      if (_reportsFailures) {
        await _errorLogger!.recordError(
          error: errorDetails,
          stackTrace: dioException.stackTrace,
          backendCorrelationId: correlationId,
        );
      }

      if (errorData.contractViolation) {
        return Result.failure(
          data: ContractViolationError(
            statusCode: statusCode,
            message: null,
            code: null,
            backendCorrelationId: correlationId,
          ),
        );
      }

      switch (dioException.type) {
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.transformTimeout:
          return Result.failure(
            data: TimeoutError(
              statusCode: statusCode,
              message: errorData.message,
              code: errorData.code,
              backendCorrelationId: correlationId,
            ),
          );
        case dio.DioExceptionType.connectionError:
        case dio.DioExceptionType.unknown
            when isSocketException(dioException.error):
          return Result.failure(
            data: NetworkError(
              statusCode: statusCode,
              message: errorData.message,
              code: errorData.code,
              backendCorrelationId: correlationId,
            ),
          );
        case dio.DioExceptionType.cancel:
          return Result.failure(
            data: CancelError(
              statusCode: statusCode,
              message: errorData.message,
              code: errorData.code,
              backendCorrelationId: correlationId,
            ),
          );
        case dio.DioExceptionType.badCertificate:
        case dio.DioExceptionType.badResponse:
          return Result.failure(
            data: ServerError(
              statusCode: statusCode,
              message: errorData.message,
              code: errorData.code,
              backendCorrelationId: correlationId,
            ),
          );
        case dio.DioExceptionType.unknown:
          return Result.failure(
            data: UnknownError(
              statusCode: statusCode,
              message: errorData.message,
              code: errorData.code,
              backendCorrelationId: correlationId,
            ),
          );
      }
    } catch (error, stackTrace) {
      return _unexpectedFailure(
        operation: 'Non-DioException during request',
        method: method,
        path: path,
        error: error,
        stackTrace: stackTrace,
        parseServerError: true,
      );
    }
  }

  Future<({String? message, String? code, bool contractViolation})>
  _parseServerErrorSafely({
    required dynamic response,
    required String method,
    required String path,
    required String? backendCorrelationId,
  }) async {
    final parser = serverErrorMessageParser;
    if (parser == null) {
      return (message: null, code: null, contractViolation: false);
    }

    try {
      final parsed = parser(response);
      return (
        message: parsed?.message,
        code: parsed?.code,
        contractViolation: false,
      );
    } catch (error, stackTrace) {
      final errorMessage = _sanitizedFailureMessage(
        operation: 'Server error response parsing during $method',
        path: path,
        error: error,
      );
      _appLogger.log(message: errorMessage, tag: _tag, stackTrace: stackTrace);
      if (_reportsFailures) {
        await _errorLogger!.recordError(
          error: errorMessage,
          stackTrace: stackTrace,
          backendCorrelationId: backendCorrelationId,
        );
      }
      return (message: null, code: null, contractViolation: true);
    }
  }

  Future<Result<NetworkFailure, S>> _unexpectedFailure<S>({
    required String operation,
    required String method,
    required String path,
    required Object error,
    required StackTrace stackTrace,
    required bool parseServerError,
  }) async {
    final errorMessage = _sanitizedFailureMessage(
      operation: '$operation during $method',
      path: path,
      error: error,
    );
    _appLogger.log(message: errorMessage, tag: _tag, stackTrace: stackTrace);
    if (_reportsFailures) {
      await _errorLogger!.recordError(
        error: errorMessage,
        stackTrace: stackTrace,
      );
    }

    final errorData = parseServerError
        ? await _parseServerErrorSafely(
            response: error,
            method: method,
            path: path,
            backendCorrelationId: null,
          )
        : (message: null, code: null, contractViolation: false);
    return Result.failure(
      data: errorData.contractViolation
          ? const ContractViolationError(
              statusCode: null,
              message: null,
              code: null,
              backendCorrelationId: null,
            )
          : UnknownError(
              statusCode: null,
              message: errorData.message,
              code: errorData.code,
              backendCorrelationId: null,
            ),
    );
  }

  static String _sanitizedFailureMessage({
    required String operation,
    required String path,
    required Object error,
  }) {
    final sanitizedOperation = SensitiveDataSanitizer.sanitizeText(operation);
    final sanitizedTarget = sanitizeRequestTarget(path);
    final sanitizedError = SensitiveDataSanitizer.sanitizeText('$error');
    return '$sanitizedOperation for $sanitizedTarget: $sanitizedError';
  }

  static String? _readCorrelationId(dio.Response<dynamic>? response) =>
      response?.headers.value(_correlationIdHeader);
}

extension DioResponseExtension<T> on dio.Response<T> {
  HttpResponse<T> get toHttpResponse =>
      HttpResponse<T>(statusCode: statusCode, headers: headers.map, data: data);
}
