import 'package:flutter/foundation.dart';
import 'package:{{proj_name}}/foundation/networking/src/status_codes.dart';

@immutable
sealed class NetworkFailure {
  const NetworkFailure({
    required this.statusCode,
    required this.message,
    required this.code,
    required this.backendCorrelationId,
  });

  /// HTTP status code returned by the server (e.g., 404, 500)
  final int? statusCode;

  /// Error message from the backend response or client-side error description
  final String? message;

  /// Backend error code for programmatic error handling
  /// (e.g., 'USER_NOT_FOUND')
  final String? code;

  /// The correlation id the BACKEND minted for this request and echoed on
  /// its response. It rides here so the seam that reports this failure can
  /// hand it to the reporter and the report meets the server request that
  /// produced it. The app never mints one; it is null when the response
  /// carried none.
  final String? backendCorrelationId;

  /// Returns true if this is a ServerError with unauthorized status code
  bool get isUnauthorizedServerError => switch (this) {
    ServerError() => StatusCodes.isUnauthorized(statusCode),
    NetworkError() ||
    TimeoutError() ||
    CancelError() ||
    ContractViolationError() ||
    UnknownError() => false,
  };

  bool get isCancelError => switch (this) {
    CancelError() => true,
    NetworkError() ||
    ServerError() ||
    TimeoutError() ||
    ContractViolationError() ||
    UnknownError() => false,
  };

  /// Whether the backend response violated the shape the app must receive.
  bool get isContractViolation => switch (this) {
    ContractViolationError() => true,
    NetworkError() ||
    ServerError() ||
    TimeoutError() ||
    CancelError() ||
    UnknownError() => false,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkFailure &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          message == other.message &&
          code == other.code &&
          backendCorrelationId == other.backendCorrelationId;

  @override
  int get hashCode =>
      Object.hash(statusCode, message, code, backendCorrelationId);
}

final class NetworkError extends NetworkFailure {
  const NetworkError({
    required super.statusCode,
    required super.message,
    required super.code,
    required super.backendCorrelationId,
  });

  @override
  String toString() =>
      'NetworkError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code, '
      'backendCorrelationId: $backendCorrelationId}';
}

final class ServerError extends NetworkFailure {
  const ServerError({
    required super.statusCode,
    required super.message,
    required super.code,
    required super.backendCorrelationId,
  });

  @override
  String toString() =>
      'ServerError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code, '
      'backendCorrelationId: $backendCorrelationId}';
}

final class TimeoutError extends NetworkFailure {
  const TimeoutError({
    required super.statusCode,
    required super.message,
    required super.code,
    required super.backendCorrelationId,
  });

  @override
  String toString() =>
      'TimeoutError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code, '
      'backendCorrelationId: $backendCorrelationId}';
}

final class CancelError extends NetworkFailure {
  const CancelError({
    required super.statusCode,
    required super.message,
    required super.code,
    required super.backendCorrelationId,
  });

  @override
  String toString() =>
      'CancelError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code, '
      'backendCorrelationId: $backendCorrelationId}';
}

final class ContractViolationError extends NetworkFailure {
  const ContractViolationError({
    required super.statusCode,
    required super.message,
    required super.code,
    required super.backendCorrelationId,
  });

  @override
  String toString() =>
      'ContractViolationError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code, '
      'backendCorrelationId: $backendCorrelationId}';
}

final class UnknownError extends NetworkFailure {
  const UnknownError({
    required super.statusCode,
    required super.message,
    required super.code,
    required super.backendCorrelationId,
  });

  @override
  String toString() =>
      'UnknownError{'
      'statusCode: $statusCode, '
      'message: $message, '
      'code: $code, '
      'backendCorrelationId: $backendCorrelationId}';
}
