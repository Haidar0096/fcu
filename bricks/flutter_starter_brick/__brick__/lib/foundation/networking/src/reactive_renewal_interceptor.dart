import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/authentication/authentication.dart';
import 'package:{{proj_name}}/foundation/networking/src/authorization_header.dart';
import 'package:{{proj_name}}/foundation/networking/src/http_interceptor.dart';
import 'package:{{proj_name}}/foundation/networking/src/request_extras.dart';
import 'package:{{proj_name}}/foundation/networking/src/status_codes.dart';

/// STEP 4 of the logged-in chain: a refused request renews ONCE and is sent
/// again.
///
/// It retries on the transport it lives on — the same client that carried the
/// request — which is why the chain is built by a function handed that
/// transport.
///
/// One retry, and one only: the retried request is marked on its own side
/// data, so a second refusal ends it instead of looping between the server and
/// the renewal.
///
/// The retry rides the whole chain again — that is what sending it on the same
/// transport means — so it carries the renewed set on its own side data as
/// well. Without that note the step that attaches the token would read the
/// store, find the token the renewal replaced, and put the dead one back on
/// the retry.
///
/// It renews from the set the request itself carries whenever the early
/// step already renewed on that request, and from the store only otherwise.
/// The store still holds what that earlier renewal replaced, so reading it
/// here would present a spent refresh credential.
///
/// The three outcomes are kept apart on purpose. A rejected token logs the
/// user out — announced by the coordinator, acted on by the project's auth
/// bloc, never here. An unreachable renewal changes nothing: the request fails
/// like any other and the user stays logged in.
final class ReactiveRenewalInterceptor extends HttpInterceptor {
  /// Creates the step over [tokenStore], [renewalCoordinator] and the
  /// [transport] it retries on.
  const ReactiveRenewalInterceptor({
    required AuthTokenStore tokenStore,
    required AuthTokenRenewalCoordinator renewalCoordinator,
    required dio.Dio transport,
  }) : _tokenStore = tokenStore,
       _renewalCoordinator = renewalCoordinator,
       _transport = transport;

  final AuthTokenStore _tokenStore;
  final AuthTokenRenewalCoordinator _renewalCoordinator;
  final dio.Dio _transport;

  @override
  Future<void> onError(
    dio.DioException err,
    dio.ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final wasRefused = StatusCodes.isUnauthorized(err.response?.statusCode);
    final alreadyRetried = options.extra[RequestExtras.retriedAfterRenewal];

    if (!wasRefused ||
        alreadyRetried == true ||
        AuthExcludedPaths.matches(options.path)) {
      handler.next(err);
      return;
    }

    // The set this renewal presents is the one the request itself carries when
    // the early-renewal step already renewed on it, and the held one
    // otherwise. Reading the store first would present the refresh credential
    // that earlier renewal already spent, and the server answers that by
    // logging the user out — the same note, read the same way, as the step
    // that attaches the token.
    final carried = options.extra[RequestExtras.renewedTokens];
    final tokens = carried is AuthTokens ? carried : await _tokenStore.read();
    // Nothing held, so nothing to renew: the refusal is the honest answer.
    if (tokens == null) {
      handler.next(err);
      return;
    }

    final outcome = await _renewalCoordinator.renew(currentTokens: tokens);
    switch (outcome) {
      case AuthTokenRenewedOutcome(tokens: final renewed):
        await _retryOnce(options: options, tokens: renewed, handler: handler);
      case AuthTokenRejectedOutcome():
      case AuthTokenRenewalUnreachableOutcome():
        handler.next(err);
    }
  }

  Future<void> _retryOnce({
    required dio.RequestOptions options,
    required AuthTokens tokens,
    required dio.ErrorInterceptorHandler handler,
  }) async {
    options.extra[RequestExtras.retriedAfterRenewal] = true;
    // The retry runs the chain again, and the step that attaches the token
    // reads this note first. The store still holds the replaced set — only
    // the auth bloc saves — so without the note the retry would go out under
    // the very token the server just refused.
    options.extra[RequestExtras.renewedTokens] = tokens;
    options.headers[AuthorizationHeader.name] = AuthorizationHeader.valueFor(
      tokens.accessToken,
    );

    try {
      handler.resolve(await _transport.fetch<dynamic>(options));
    } on dio.DioException catch (retryFailure) {
      handler.next(retryFailure);
    }
  }
}
