/// Instance names for dependency injection when multiple instances
/// of the same type exist.
enum InstanceNames {
  /// HTTP client for public endpoints that don't require authentication
  /// (e.g., login, signup)
  publicBackendHttpClient,
}
