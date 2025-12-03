/// Parses backend error response and returns message and code.
({String? message, String? code})? backendErrorMessageParser(
  Object? response,
) => switch (response) {
  final Map<String, dynamic> map => (
    // Backend returns 'errorMessage' field, not 'message'
    message: map['errorMessage'] as String? ?? map['message'] as String?,
    code: map['code'] as String?,
  ),
  _ => null,
};
