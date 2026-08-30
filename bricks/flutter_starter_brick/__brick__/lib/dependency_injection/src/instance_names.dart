/// Instance names for dependency injection when multiple instances
/// of the same type exist.
enum InstanceNames {
  /// HTTP client for public endpoints that carry no token (e.g., login,
  /// signup, and the token renewal itself). Renewal rides this one, so a
  /// renewal can never trigger another renewal.
  publicBackendHttpClient,

  /// HTTP client for endpoints that need a logged-in user. It runs the fixed
  /// chain — meta headers, proactive early renewal, attach bearer, reactive
  /// renew-once-and-retry — and it confines all token handling to that chain.
  ///
  /// It ships from birth, before any login exists: adding login then adds the
  /// screens and the API, never the plumbing.
  loggedInBackendHttpClient,

  /// Public client used only by the report sender. It debug-logs failures but
  /// cannot call the report road recursively.
  reportUploadHttpClient,
}
