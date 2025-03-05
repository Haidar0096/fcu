/// Represents the error body of an api response coming from the backend.
final class ApiErrorDTO {
  const ApiErrorDTO({this.message, this.code});

  final String? message;

  final String? code;

  @override
  String toString() => 'ApiErrorDTO{message: $message, code: $code}';
}
