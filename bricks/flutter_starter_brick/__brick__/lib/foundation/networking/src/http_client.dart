import 'dart:typed_data';

import 'package:{{proj_name}}/foundation/basic_types/basic_types.dart';
import 'package:{{proj_name}}/foundation/networking/src/cancel_token.dart';
import 'package:{{proj_name}}/foundation/networking/src/http_response.dart';
import 'package:{{proj_name}}/foundation/networking/src/network_failure.dart';

/// The type of a progress listening callback when sending or receiving data.
///
/// [count] is the length of the bytes have been sent/received.
///
/// [total] is the content length of the response/request body.
/// 1. When sending data, [total] is the request body length.
/// 2. When receiving data, [total] will be -1 if the size of the response body,
///    typically with no `content-length` header.
typedef OnProgressCallback = void Function(int count, int total);

/// An interface specifying the contract for making HTTP requests.
abstract class HttpClient {
  /// Correlation id from the most recent successful response, when present.
  String? get lastSuccessfulCorrelationId;

  /// Makes a GET request to the specified [path].
  ///
  /// - [path]: The URL path for the request.
  /// - [successResponseMapper]: A function to map the successful response.
  /// - [queryParameters]: Optional query parameters to append to the URL.
  /// - [additionalHeaders]: Headers to add to the default headers.
  /// - [replacementHeaders]: Headers to replace the default headers entirely.
  /// - [responseStatusCodeValidator]: Custom status code validation function.
  /// - [cancelToken]: Token to cancel the request.
  Future<Result<NetworkFailure, S>> get<S>({
    required String path,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    CancelToken? cancelToken,
  });

  /// Makes a POST request to the specified [path].
  ///
  /// - [path]: The URL path for the request.
  /// - [successResponseMapper]: A function to map the successful response.
  /// - [body]: Optional request body (will be JSON encoded if Map).
  /// - [isMultipart]: If true, converts Map body to multipart/form-data.
  /// - [queryParameters]: Optional query parameters to append to the URL.
  /// - [additionalHeaders]: Headers to add to the default headers.
  /// - [replacementHeaders]: Headers to replace the default headers entirely.
  /// - [responseStatusCodeValidator]: Custom status code validation function.
  /// - [cancelToken]: Token to cancel the request.
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
  });

  /// Makes a PUT request to the specified [path].
  ///
  /// - [path]: The URL path for the request.
  /// - [successResponseMapper]: A function to map the successful response.
  /// - [body]: Optional request body (will be JSON encoded if Map).
  /// - [queryParameters]: Optional query parameters to append to the URL.
  /// - [additionalHeaders]: Headers to add to the default headers.
  /// - [replacementHeaders]: Headers to replace the default headers entirely.
  /// - [responseStatusCodeValidator]: Custom status code validation function.
  /// - [cancelToken]: Token to cancel the request.
  Future<Result<NetworkFailure, S>> put<S>({
    required String path,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    CancelToken? cancelToken,
  });

  /// Makes a PATCH request to the specified [path].
  ///
  /// - [path]: The URL path for the request.
  /// - [successResponseMapper]: A function to map the successful response.
  /// - [body]: Optional request body (will be JSON encoded if Map).
  /// - [isMultipart]: If true, converts Map body to multipart/form-data.
  /// - [queryParameters]: Optional query parameters to append to the URL.
  /// - [additionalHeaders]: Headers to add to the default headers.
  /// - [replacementHeaders]: Headers to replace the default headers entirely.
  /// - [responseStatusCodeValidator]: Custom status code validation function.
  /// - [cancelToken]: Token to cancel the request.
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
  });

  /// Makes a DELETE request to the specified [path].
  ///
  /// - [path]: The URL path for the request.
  /// - [successResponseMapper]: A function to map the successful response.
  /// - [queryParameters]: Optional query parameters to append to the URL.
  /// - [additionalHeaders]: Headers to add to the default headers.
  /// - [replacementHeaders]: Headers to replace the default headers entirely.
  /// - [responseStatusCodeValidator]: Custom status code validation function.
  /// - [cancelToken]: Token to cancel the request.
  Future<Result<NetworkFailure, S>> delete<S>({
    required String path,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    bool Function(int? statusCode)? responseStatusCodeValidator,
    CancelToken? cancelToken,
  });

  /// Uploads a file from the file system to the specified [path].
  ///
  /// Uses multipart/form-data encoding to send the file.
  ///
  /// - [path]: The URL path for the upload.
  /// - [filePath]: The local file system path to the file to upload.
  /// - [successResponseMapper]: A function to map the successful response.
  /// - [fieldName]: The form field name for the file (defaults to 'file').
  /// - [additionalFields]: Additional form fields to include in the request.
  /// - [queryParameters]: Optional query parameters to append to the URL.
  /// - [additionalHeaders]: Headers to add to the default headers.
  /// - [replacementHeaders]: Headers to replace the default headers entirely.
  /// - [responseStatusCodeValidator]: Custom status code validation function.
  /// - [onSendProgress]: Callback for upload progress tracking.
  /// - [cancelToken]: Token to cancel the upload.
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
  });

  /// Uploads bytes (in-memory data) to the specified [path].
  ///
  /// Uses multipart/form-data encoding to send the bytes as a file.
  ///
  /// - [path]: The URL path for the upload.
  /// - [bytes]: The bytes to upload.
  /// - [filename]: The filename to use for the uploaded bytes.
  /// - [successResponseMapper]: A function to map the successful response.
  /// - [fieldName]: The form field name for the file (defaults to 'file').
  /// - [additionalFields]: Additional form fields to include in the request.
  /// - [queryParameters]: Optional query parameters to append to the URL.
  /// - [additionalHeaders]: Headers to add to the default headers.
  /// - [replacementHeaders]: Headers to replace the default headers entirely.
  /// - [responseStatusCodeValidator]: Custom status code validation function.
  /// - [onSendProgress]: Callback for upload progress tracking.
  /// - [cancelToken]: Token to cancel the upload.
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
  });
}
