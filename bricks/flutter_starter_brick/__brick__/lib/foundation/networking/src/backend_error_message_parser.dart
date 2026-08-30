/// Parses the backend error response and returns the optional message and code.
///
/// A wrong field type raises a sanitized format error. The HTTP client's safe
/// parser boundary logs and reports that contract violation, then returns the
/// typed contract-violation result used by the critical-error road.
({String? message, String? code})? backendErrorMessageParser(
  Object? response,
) {
  if (response is! Map<String, dynamic>) return null;

  final errorMessage = response['errorMessage'];
  final message = response['message'];
  final code = response['code'];
  if ((errorMessage != null && errorMessage is! String) ||
      (message != null && message is! String) ||
      (code != null && code is! String)) {
    throw const FormatException(
      'Backend error envelope contains a non-string contract field.',
    );
  }

  final parsedErrorMessage = errorMessage is String ? errorMessage : null;
  final parsedMessage = message is String ? message : null;
  final parsedCode = code is String ? code : null;
  return (
    // The backend's preferred field is `errorMessage`; `message` is fallback.
    message: parsedErrorMessage ?? parsedMessage,
    code: parsedCode,
  );
}
