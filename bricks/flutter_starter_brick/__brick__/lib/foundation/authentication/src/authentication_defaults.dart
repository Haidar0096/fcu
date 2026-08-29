/// The tuning values the logged-in client's auth steps read.
abstract final class AuthenticationDefaults {
  /// How long before an access token's end the proactive step renews it.
  ///
  /// It only has to be longer than one request's round trip, so a token
  /// cannot die between leaving the phone and reaching the server. A project
  /// whose tokens are short-lived widens it here, in one place.
  ///
  /// A starting value. A project tunes it to its own token lifetime.
  static const Duration earlyRenewalWindow = Duration(minutes: 1);
}
