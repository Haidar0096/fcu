/// The one home of the header a token rides under.
///
/// Two steps of the logged-in chain write it — the one that attaches the held
/// token, and the one that retries a refused request with a renewed token —
/// so the name and the scheme are named once here rather than typed twice.
abstract final class AuthorizationHeader {
  /// The header name.
  static const String name = 'Authorization';

  /// The scheme that precedes the value.
  static const String scheme = 'Bearer';

  /// The complete header value for [token].
  static String valueFor(String token) => '$scheme $token';
}
