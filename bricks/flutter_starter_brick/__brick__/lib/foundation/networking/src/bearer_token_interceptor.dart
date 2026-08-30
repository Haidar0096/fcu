import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/authentication/authentication.dart';
import 'package:{{proj_name}}/foundation/networking/src/authorization_header.dart';
import 'package:{{proj_name}}/foundation/networking/src/http_interceptor.dart';
import 'package:{{proj_name}}/foundation/networking/src/request_extras.dart';

/// STEP 3 of the logged-in chain: the token goes on the request.
///
/// This is the chain's normal bearer-attachment step. The reactive retry may
/// replace this header with a renewed token; no screen, bloc or API class ever
/// sets it — a token set at a call site is a token that leaks into a log line,
/// a public request, or a screenshot of a review diff.
final class BearerTokenInterceptor extends HttpInterceptor {
  /// Creates the step over [tokenStore].
  const BearerTokenInterceptor({required AuthTokenStore tokenStore})
    : _tokenStore = tokenStore;

  final AuthTokenStore _tokenStore;

  @override
  Future<void> onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    if (AuthExcludedPaths.matches(options.path)) {
      handler.next(options);
      return;
    }

    final renewed = options.extra[RequestExtras.renewedTokens];
    final tokens = renewed is AuthTokens ? renewed : await _tokenStore.read();

    // Nothing held: the request rides without the header and the server
    // refuses it loudly. A guessed or empty value would fail quietly instead.
    if (tokens != null) {
      options.headers[AuthorizationHeader.name] = AuthorizationHeader.valueFor(
        tokens.accessToken,
      );
    }

    handler.next(options);
  }
}
