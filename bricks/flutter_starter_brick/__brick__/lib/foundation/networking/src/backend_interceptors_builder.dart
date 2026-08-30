import 'package:{{proj_name}}/foundation/authentication/authentication.dart';
import 'package:{{proj_name}}/foundation/networking/src/backend_http_client.dart';
import 'package:{{proj_name}}/foundation/networking/src/backend_meta_headers.dart';
import 'package:{{proj_name}}/foundation/networking/src/bearer_token_interceptor.dart';
import 'package:{{proj_name}}/foundation/networking/src/http_interceptor.dart';
import 'package:{{proj_name}}/foundation/networking/src/meta_headers_interceptor.dart';
import 'package:{{proj_name}}/foundation/networking/src/proactive_renewal_interceptor.dart';
import 'package:{{proj_name}}/foundation/networking/src/reactive_renewal_interceptor.dart';

/// THE PUBLIC CHAIN: meta headers, and nothing else.
///
/// It carries NO token, ever, and that is what makes it safe for the renewal
/// call itself to ride: a renewal on a token-carrying client would be refused,
/// renew, be refused again, and never stop.
///
/// The two builders live in one file on purpose. Which steps a client runs is
/// ONE decision with two answers, and the answers are only readable against
/// each other.
OnBuildInterceptorsCallback publicInterceptorsBuilder() =>
    (transport) => const <HttpInterceptor>[
      MetaHeadersInterceptor(headers: BackendMetaHeaders.values),
    ];

/// THE LOGGED-IN CHAIN, in this fixed order and no other:
///
/// 1. meta headers — the app's own headers, before anything reads them;
/// 2. proactive early renewal — a token about to end is renewed first;
/// 3. attach the current bearer before the send;
/// 4. reactive renew-once-and-retry — a refused request renews once, replaces
///    the bearer with the renewed token, and is sent again on this transport.
///
/// Every step short-circuits on the excluded-path list, which the auth module
/// owns.
///
/// The chain is built by a function handed the transport instance it will live
/// on, because step 4 has to send a request again on exactly the client that
/// carried it the first time.
OnBuildInterceptorsCallback loggedInInterceptorsBuilder({
  required AuthTokenStore tokenStore,
  required AuthTokenRenewalCoordinator renewalCoordinator,
}) =>
    (transport) => <HttpInterceptor>[
      const MetaHeadersInterceptor(headers: BackendMetaHeaders.values),
      ProactiveRenewalInterceptor(
        tokenStore: tokenStore,
        renewalCoordinator: renewalCoordinator,
      ),
      BearerTokenInterceptor(tokenStore: tokenStore),
      ReactiveRenewalInterceptor(
        tokenStore: tokenStore,
        renewalCoordinator: renewalCoordinator,
        transport: transport,
      ),
    ];
