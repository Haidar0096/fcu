import 'package:dio/dio.dart' as dio;

/// Abstract interface for cancelling HTTP requests and streams.
///
/// This abstraction allows us to cancel ongoing network operations
/// without coupling the rest of the app to Dio's implementation.
abstract class CancelToken {
  /// Creates a new cancel token
  factory CancelToken() = DioCancelToken;

  /// Whether the token has been cancelled
  bool get isCancelled;

  /// Cancels the operation associated with this token
  ///
  /// [reason] is an optional message explaining why the operation was cancelled
  void cancel([String? reason]);
}

/// Dio implementation of CancelToken that wraps Dio's native CancelToken.
///
/// This implementation delegates all operations to an internal Dio CancelToken
/// while providing an abstraction layer for the rest of the application.
class DioCancelToken implements CancelToken {
  DioCancelToken() : _dioToken = dio.CancelToken();

  final dio.CancelToken _dioToken;

  /// Gets the underlying Dio CancelToken for use in Dio operations
  dio.CancelToken get dioToken => _dioToken;

  @override
  bool get isCancelled => _dioToken.isCancelled;

  @override
  void cancel([String? reason]) => _dioToken.cancel(reason);
}
