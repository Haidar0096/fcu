/// The headers every backend request carries about the app itself.
///
/// THEY SHIP EMPTY, and empty is an answer. A header NAME is a contract with
/// the project's server: which name it reads the app version, the platform or
/// a build number under is the server's answer, not the starter's, and the
/// starter names none it was not given. An invented name would be sent on
/// every request and read by nobody.
///
/// Both backend clients read this one holder, so a project answers once.
abstract final class BackendMetaHeaders {
  /// The meta headers, by header name.
  static const Map<String, String> values = <String, String>{};
}
