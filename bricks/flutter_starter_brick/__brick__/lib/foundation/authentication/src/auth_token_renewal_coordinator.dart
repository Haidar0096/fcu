import 'dart:async';

import 'package:{{proj_name}}/foundation/authentication/src/auth_token_renewal_outcome.dart';
import 'package:{{proj_name}}/foundation/authentication/src/auth_tokens.dart';

/// Presents [currentTokens] to the project's renewal endpoint and answers with
/// what came back.
///
/// It never throws for an ordinary refusal or an ordinary network problem:
/// both are outcomes, and telling them apart is the caller's whole job.
typedef OnRenewAuthTokensCallback =
    Future<AuthTokenRenewalOutcome> Function({required AuthTokens currentTokens});

/// Runs at most ONE token renewal at a time and lets every other caller join
/// the one already running.
///
/// Single-flight is the whole point. Ten requests refused at the same moment
/// must not fire ten renewals: the first one starts, the other nine wait on
/// the same [Completer], and all ten read the same answer. Without this, the
/// second renewal presents a refresh credential the first one already spent,
/// and the server logs the user out.
///
/// It is registered ONCE, as a lazy singleton. A per-request or per-client
/// copy would each hold its own in-flight completer, which is exactly no
/// single flight at all.
///
/// It does NOT save what comes back. A renewal announces its outcome on
/// [outcomes]; the project's auth bloc is the one place that saves the new
/// tokens and decides logout. The starter declares no login, so nothing
/// listens yet and nothing renews yet.
final class AuthTokenRenewalCoordinator {
  /// Creates the coordinator over the renewal it runs.
  AuthTokenRenewalCoordinator({required OnRenewAuthTokensCallback renewTokens})
    : _renewTokens = renewTokens;

  final OnRenewAuthTokensCallback _renewTokens;
  final StreamController<AuthTokenRenewalOutcome> _outcomes =
      StreamController<AuthTokenRenewalOutcome>.broadcast();

  Completer<AuthTokenRenewalOutcome>? _inFlight;

  /// Every renewal outcome, as it happens.
  ///
  /// The auth bloc a project adds with login listens here: it saves a renewed
  /// token set and logs the user out on a rejected one. Nothing listens in the
  /// starter, and a broadcast stream with no listener simply drops what it is
  /// given.
  Stream<AuthTokenRenewalOutcome> get outcomes => _outcomes.stream;

  /// Whether a renewal is running right now.
  bool get isRenewing => _inFlight != null;

  /// Renews [currentTokens], joining a renewal that is already running.
  Future<AuthTokenRenewalOutcome> renew({required AuthTokens currentTokens}) {
    final running = _inFlight;
    if (running != null) return running.future;

    final completer = Completer<AuthTokenRenewalOutcome>();
    _inFlight = completer;
    unawaited(_run(currentTokens: currentTokens, completer: completer));
    return completer.future;
  }

  /// Closes the announcement stream. Called by the container's dispose.
  Future<void> close() => _outcomes.close();

  Future<void> _run({
    required AuthTokens currentTokens,
    required Completer<AuthTokenRenewalOutcome> completer,
  }) async {
    try {
      final outcome = await _renewTokens(currentTokens: currentTokens);
      // The flight ends before the answer goes out, so a caller that starts a
      // fresh renewal from the announcement is not told one is still running.
      _inFlight = null;
      // This announces a renewed token set and saves nothing. The auth bloc a
      // project adds is the only saver. Until then there is no saver, by
      // design.
      if (!_outcomes.isClosed) _outcomes.add(outcome);
      completer.complete(outcome);
    } catch (error, stackTrace) {
      _inFlight = null;
      completer.completeError(error, stackTrace);
    }
  }
}
