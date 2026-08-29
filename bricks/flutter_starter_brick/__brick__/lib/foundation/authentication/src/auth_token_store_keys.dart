/// The constant keys the token store holds its values under.
///
/// They sit in their own holder beside the store, the way every other stored
/// concern in this app keeps its keys, so a key is never typed twice.
abstract final class AuthTokenStoreKeys {
  /// The key the access token is held under.
  static const String accessToken = 'auth_access_token';

  /// The key the refresh credential is held under.
  static const String refreshToken = 'auth_refresh_token';

  /// The key the access token's end moment is held under, written as an
  /// ISO 8601 string in UTC.
  static const String accessTokenEnd = 'auth_access_token_end';

  /// Every key this store owns, in the order a clear deletes them.
  static const List<String> all = <String>[
    accessToken,
    refreshToken,
    accessTokenEnd,
  ];
}
