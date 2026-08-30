/// HTTP status codes and utilities for network operations
abstract final class StatusCodes {
  /// HTTP status code that indicates an unauthenticated request.
  static const unauthorizedStatusCodes = [401];

  /// Returns true if the given status code indicates unauthorized access
  static bool isUnauthorized(int? statusCode) =>
      statusCode != null && unauthorizedStatusCodes.contains(statusCode);
}
