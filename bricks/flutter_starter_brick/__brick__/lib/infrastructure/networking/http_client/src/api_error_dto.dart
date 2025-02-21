/// Represents the error body of an api response coming from the backend.
final class ApiErrorDTO {
  const ApiErrorDTO({this.message, this.code});

  final String? message;

  final String? code;

  // TODO({{dev_name}}): Edit fromJson and toJson methods to match your DTO class.
  factory ApiErrorDTO.fromJson(Map<String, dynamic> json) => switch (json) {
    <String, dynamic>{
      'message': final String? message,
      'code': final String? code,
    } =>
      ApiErrorDTO(message: message, code: code),
    _ => throw ArgumentError('Invalid json for ApiErrorDTO'),
  };

  // TODO({{dev_name}}): Edit fromJson and toJson methods to match your DTO class.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': message,
    'code': code,
  };

  /// Converts the given object to an [ApiErrorDTO] object, if possible.
  /// Else returns null.
  static ApiErrorDTO? fromObject(dynamic object) => switch (object) {
    <String, dynamic>{
      'errorMessage': final String? _,
      'code': final String? _,
    } =>
      ApiErrorDTO.fromJson(object),
    _ => null,
  };
}
