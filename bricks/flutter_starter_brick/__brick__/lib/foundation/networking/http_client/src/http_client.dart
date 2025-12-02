import 'package:{{proj_name}}/foundation/basic_types/basic_types.dart';
import 'package:{{proj_name}}/foundation/networking/cancel_token/cancel_token.dart';
import 'package:{{proj_name}}/foundation/networking/http_client/src/http_response.dart';
import 'package:{{proj_name}}/foundation/networking/models/models.dart';

/// The type of a progress listening callback when sending or receiving data.
///
/// [count] is the length of the bytes have been sent/received.
///
/// [total] is the content length of the response/request body.
/// 1. When sending data, [total] is the request body length.
/// 2. When receiving data, [total] will be -1 if the size of the response body,
///    typically with no `content-length` header.
typedef ProgressCallback = void Function(int count, int total);

/// An interface specifying the contract for making HTTP requests.
// ignore: one_member_abstracts
abstract class HttpClient {
  /// - S is the returned success result's data type.
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
  });
}
