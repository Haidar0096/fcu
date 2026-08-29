import 'package:flutter/foundation.dart';

/// The token set the app holds for a logged-in user.
///
/// A plain hand-written immutable carrier — it never becomes JSON here. The
/// WIRE shape a project's backend hands these values over in is not known to
/// the starter and is never guessed: the project's own refresher maps its
/// server's reply into this type when it adds login.
@immutable
class AuthTokens {
  /// Creates a token set.
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
  });

  /// The value attached to a logged-in request.
  final String accessToken;

  /// The credential a renewal presents to obtain a fresh [accessToken].
  final String refreshToken;

  /// The moment [accessToken] stops being accepted, in UTC.
  final DateTime accessTokenExpiresAt;

  /// Whether [accessToken] ends within [window] of [now] — or has ended
  /// already.
  ///
  /// [now] arrives as a parameter rather than being read here so the answer
  /// stays testable and this type keeps no hidden clock.
  bool isNearExpiry({required Duration window, required DateTime now}) =>
      !now.toUtc().add(window).isBefore(accessTokenExpiresAt);
}
