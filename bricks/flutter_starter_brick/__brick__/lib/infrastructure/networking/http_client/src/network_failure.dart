import 'package:{{proj_name}}/infrastructure/networking/http_client/src/api_error_dto.dart';

sealed class NetworkFailure {
  const NetworkFailure({this.statusCode, this.apiErrorDTO});

  final int? statusCode;
  final ApiErrorDTO? apiErrorDTO;
}

final class NetworkError extends NetworkFailure {
  const NetworkError({super.statusCode, super.apiErrorDTO});

  @override
  String toString() =>
      'NetworkError{'
      'statusCode: $statusCode, '
      'apiErrorDTO: $apiErrorDTO}';
}

final class ServerError extends NetworkFailure {
  const ServerError({super.statusCode, super.apiErrorDTO});

  @override
  String toString() =>
      'ServerError{'
      'statusCode: $statusCode, '
      'apiErrorDTO: $apiErrorDTO}';
}

final class TimeoutError extends NetworkFailure {
  const TimeoutError({super.statusCode, super.apiErrorDTO});

  @override
  String toString() =>
      'TimeoutError{'
      'statusCode: $statusCode, '
      'apiErrorDTO: $apiErrorDTO}';
}

final class CancelError extends NetworkFailure {
  const CancelError({super.statusCode, super.apiErrorDTO});

  @override
  String toString() =>
      'CancelError{'
      'statusCode: $statusCode, '
      'apiErrorDTO: $apiErrorDTO}';
}

final class UnknownError extends NetworkFailure {
  const UnknownError({super.statusCode, super.apiErrorDTO});

  @override
  String toString() =>
      'UnknownError{'
      'statusCode: $statusCode, '
      'apiErrorDTO: $apiErrorDTO}';
}
