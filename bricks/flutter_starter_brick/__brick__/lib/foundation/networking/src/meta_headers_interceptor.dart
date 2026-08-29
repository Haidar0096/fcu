import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/networking/src/http_interceptor.dart';

/// STEP 1 of both backend chains: the app's own meta headers go on every
/// request.
///
/// It runs first so every later step — and every retry — sees them already
/// there.
final class MetaHeadersInterceptor extends HttpInterceptor {
  /// Creates the step over [headers].
  const MetaHeadersInterceptor({required Map<String, String> headers})
    : _headers = headers;

  final Map<String, String> _headers;

  @override
  void onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) {
    options.headers.addAll(_headers);
    handler.next(options);
  }
}
