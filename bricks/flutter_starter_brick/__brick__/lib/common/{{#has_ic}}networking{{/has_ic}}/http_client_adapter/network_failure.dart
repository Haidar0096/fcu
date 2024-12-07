sealed class NetworkFailure {
  final int? statusCode;
  final String? serverErrorMessage;

  const NetworkFailure({
    this.statusCode,
    this.serverErrorMessage,
  });
}

final class NetworkError extends NetworkFailure {
  const NetworkError({
    super.statusCode,
    super.serverErrorMessage,
  });
}

final class ServerError extends NetworkFailure {
  const ServerError({
    super.statusCode,
    super.serverErrorMessage,
  });
}

final class TimeoutError extends NetworkFailure {
  const TimeoutError({
    super.statusCode,
    super.serverErrorMessage,
  });
}

final class CancelError extends NetworkFailure {
  const CancelError({
    super.statusCode,
    super.serverErrorMessage,
  });
}

final class UnknownError extends NetworkFailure {
  const UnknownError({
    super.statusCode,
    super.serverErrorMessage,
  });
}
