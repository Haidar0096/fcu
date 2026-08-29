import 'package:dio/dio.dart' as dio;
import 'package:{{proj_name}}/foundation/authentication/authentication.dart';
import 'package:{{proj_name}}/foundation/networking/src/http_interceptor.dart';
import 'package:{{proj_name}}/foundation/networking/src/request_extras.dart';

/// STEP 2 of the logged-in chain: a token about to end is renewed BEFORE the
/// request goes out.
///
/// Renewing early is cheaper than being refused: a token that dies mid-flight
/// costs a failed round trip, a renewal, and a retry, and the user waits for
/// all three.
///
/// It short-circuits on the excluded paths, and it renews through the shared
/// coordinator, so ten requests leaving together still produce one renewal.
///
/// It also short-circuits on a request that already carries a renewed set —
/// the retry the reactive step sends runs this chain again, and the store it
/// would read still holds the replaced set. Renewing there would present a
/// refresh credential the retry's own renewal already spent, and the server
/// answers that by logging the user out.
final class ProactiveRenewalInterceptor extends HttpInterceptor {
  /// Creates the step over [tokenStore] and [renewalCoordinator].
  const ProactiveRenewalInterceptor({
    required AuthTokenStore tokenStore,
    required AuthTokenRenewalCoordinator renewalCoordinator,
  }) : _tokenStore = tokenStore,
       _renewalCoordinator = renewalCoordinator;

  final AuthTokenStore _tokenStore;
  final AuthTokenRenewalCoordinator _renewalCoordinator;

  @override
  Future<void> onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    if (AuthExcludedPaths.matches(options.path) ||
        options.extra.containsKey(RequestExtras.renewedTokens) ||
        options.extra.containsKey(RequestExtras.retriedAfterRenewal)) {
      handler.next(options);
      return;
    }

    final tokens = await _tokenStore.read();
    // Nothing held — the starter's standing case, since it declares no login.
    if (tokens == null) {
      handler.next(options);
      return;
    }

    final isNearEnd = tokens.isNearExpiry(
      window: AuthenticationDefaults.earlyRenewalWindow,
      now: DateTime.now().toUtc(),
    );
    if (!isNearEnd) {
      handler.next(options);
      return;
    }

    final outcome = await _renewalCoordinator.renew(currentTokens: tokens);
    switch (outcome) {
      case AuthTokenRenewedOutcome(tokens: final renewed):
        // Handed to the step that attaches it. The auth bloc saves the set
        // when it hears the announcement; this request must not wait for that.
        options.extra[RequestExtras.renewedTokens] = renewed;
      case AuthTokenRejectedOutcome():
      case AuthTokenRenewalUnreachableOutcome():
        break; // Do nothing: the request rides on with what is held, and the
      // server's own answer decides what happens next.
    }

    handler.next(options);
  }
}
