/// The endpoint paths every auth step of the logged-in client skips.
///
/// Matching is by path ENDING, and that choice is verified safe: a wrong match
/// can only OMIT the token, and a request that should have carried one then
/// fails loudly at the server. It can never attach a token where one does not
/// belong.
///
/// IT SHIPS EMPTY. The starter declares no login, so there is no sign-in or
/// renewal endpoint to exclude yet, and an invented ending would exclude a
/// path this project does not have. A project adds its own endings here when
/// it adds login. This is the one home the interceptors and the project's auth
/// API share, which is the only reason it is a constants holder at all.
abstract final class AuthExcludedPaths {
  /// The path endings every auth step skips.
  static const List<String> endings = <String>[];

  /// Whether [path] ends with one of [endings].
  static bool matches(String path) =>
      endings.any((ending) => path.endsWith(ending));
}
