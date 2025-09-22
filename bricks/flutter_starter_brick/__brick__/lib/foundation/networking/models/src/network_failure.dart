import 'package:flutter/foundation.dart';
import 'package:{{proj_name}}/foundation/networking/http_client/src/status_codes.dart';

@immutable
sealed class NetworkFailure {
  const NetworkFailure({
    this.statusCode,
    this.message,
    this.code,
  });

  /// HTTP status code returned by the server (e.g., 404, 500)
  final int? statusCode;

  /// Human-readable error message describing what went wrong
  final String? message;

  /// Error code for programmatic error handling (e.g., 'USER_NOT_FOUND')
  final String? code;

  /// Returns true if this is a ServerError with unauthorized status code
  bool get isUnauthorizedServerError => switch (this) {
    ServerError() => StatusCodes.isUnauthorized(statusCode),
    _ => false,
  };

  bool get isCancelError => switch (this) {
    CancelError() => true,
    _ => false,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkFailure &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(statusCode, message, code);
}

class NetworkError extends NetworkFailure {
  const NetworkError({super.statusCode, super.message, super.code});

  @override
  String toString() =>
      'NetworkError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code}';
}

class ServerError extends NetworkFailure {
  const ServerError({super.statusCode, super.message, super.code});

  @override
  String toString() =>
      'ServerError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code}';
}

class TimeoutError extends NetworkFailure {
  const TimeoutError({super.statusCode, super.message, super.code});

  @override
  String toString() =>
      'TimeoutError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code}';
}

class CancelError extends NetworkFailure {
  const CancelError({super.statusCode, super.message, super.code});

  @override
  String toString() =>
      'CancelError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code}';
}

class UnknownError extends NetworkFailure {
  const UnknownError({super.statusCode, super.message, super.code});

  @override
  String toString() =>
      'UnknownError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code}';
}
