import 'package:{{proj_name}}/foundation/basic_types/basic_types.dart';
import 'package:{{proj_name}}/foundation/networking/http_client/src/http_response.dart';
import 'package:{{proj_name}}/foundation/networking/models/models.dart';

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
  });
}
