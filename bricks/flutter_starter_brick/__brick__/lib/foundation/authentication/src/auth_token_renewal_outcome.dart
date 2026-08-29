import 'package:flutter/foundation.dart';
import 'package:{{proj_name}}/foundation/authentication/src/auth_tokens.dart';

/// How one token renewal ended.
///
/// Three endings, and they are not interchangeable — the whole point of the
/// type is that a caller must tell them apart:
///
/// 1. a new token came back — the caller carries on;
/// 2. the server says the held token is dead — the user is logged out;
/// 3. the renewal could not reach the server — the request fails normally
///    and the user stays logged in, retrying through the UI.
///
/// Collapsing 2 and 3 into one "failed" is the bug this family exists to
/// prevent: a phone in a lift would log the user out.
@immutable
sealed class AuthTokenRenewalOutcome {
  /// Creates an outcome.
  const AuthTokenRenewalOutcome();
}

/// A new token set came back: the caller carries on with it.
final class AuthTokenRenewedOutcome extends AuthTokenRenewalOutcome {
  /// Creates the renewed outcome carrying [tokens].
  const AuthTokenRenewedOutcome({required this.tokens});

  /// The token set the server handed back.
  final AuthTokens tokens;
}

/// The server says the held token is dead: the user is logged out.
final class AuthTokenRejectedOutcome extends AuthTokenRenewalOutcome {
  /// Creates the rejected outcome.
  const AuthTokenRejectedOutcome();
}

/// The renewal could not reach the server: nothing is known about the token,
/// so the user stays logged in and the request fails like any other.
final class AuthTokenRenewalUnreachableOutcome extends AuthTokenRenewalOutcome {
  /// Creates the unreachable outcome.
  const AuthTokenRenewalUnreachableOutcome();
}
