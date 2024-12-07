import 'package:{{proj_name}}/common/basic_types/basic_types.dart';

import 'http_response.dart';
import 'network_failure.dart';

// ignore: one_member_abstracts
abstract class HttpClientAdapter {
  /// - S is the returned success result's data type.
  Future<Result<NetworkFailure, S>> request<S>({
    required String path,
    required String method,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? replacementHeaders,
    Object? body,
    required S Function(HttpResponse<dynamic> response) successResponseMapper,
    bool Function(int? statusCode)? responseStatusCodeValidator,
  });
}
