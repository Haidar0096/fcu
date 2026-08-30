/// The constant keys the token store holds its values under.
///
/// They sit in their own holder beside the store, the way every other stored
/// concern in this app keeps its keys, so a key is never typed twice.
abstract final class AuthTokenStoreKeys {
  /// The one atomic record holding the complete token set.
  static const String tokens = 'auth_tokens';
}
