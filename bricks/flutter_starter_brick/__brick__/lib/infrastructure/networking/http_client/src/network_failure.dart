sealed class NetworkFailure {
  const NetworkFailure({this.statusCode, this.serverErrorMessage});

  final int? statusCode;
  final String? serverErrorMessage;
}

final class NetworkError extends NetworkFailure {
  const NetworkError({super.statusCode, super.serverErrorMessage});

  @override
  String toString() =>
      'NetworkError{'
          'statusCode: $statusCode, '
          'serverErrorMessage: $serverErrorMessage}';
}

final class ServerError extends NetworkFailure {
  const ServerError({super.statusCode, super.serverErrorMessage});

  @override
  String toString() =>
      'ServerError{'
          'statusCode: $statusCode, '
          'serverErrorMessage: $serverErrorMessage}';
}

final class TimeoutError extends NetworkFailure {
  const TimeoutError({super.statusCode, super.serverErrorMessage});

  @override
  String toString() =>
      'TimeoutError{'
          'statusCode: $statusCode, '
          'serverErrorMessage: $serverErrorMessage}';
}

final class CancelError extends NetworkFailure {
  const CancelError({super.statusCode, super.serverErrorMessage});

  @override
  String toString() =>
      'CancelError{'
          'statusCode: $statusCode, '
          'serverErrorMessage: $serverErrorMessage}';
}

final class UnknownError extends NetworkFailure {
  const UnknownError({super.statusCode, super.serverErrorMessage});

  @override
  String toString() =>
      'UnknownError{'
          'statusCode: $statusCode, '
          'serverErrorMessage: $serverErrorMessage}';
}
