/// Sanitizer for removing sensitive data from request logs
class RequestDataSanitizer {
  RequestDataSanitizer._();

  // TODO({{dev_name}}): Add any custom sensitive headers specific to your API
  static const _sensitiveHeaders = {
    // 'authorization', // Example: Add your sensitive headers here
  };

  // TODO({{dev_name}}): Add any custom sensitive fields specific to your API
  static const _sensitiveBodyFields = {
    // 'password', // Example: Add your sensitive fields here
  };

  static const _redactedValue = '[REDACTED]';

  /// Sanitizes headers by redacting sensitive values
  static Map<String, dynamic>? sanitizeHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return null;

    return headers.map((key, value) {
      final isRedacted = _sensitiveHeaders.contains(key.toLowerCase());
      return MapEntry(key, isRedacted ? _redactedValue : value);
    });
  }

  /// Sanitizes request body by redacting sensitive fields
  static dynamic sanitizeBody(dynamic body) {
    if (body == null) return null;

    if (body is Map<String, dynamic>) {
      return _sanitizeMap(body);
    } else if (body is List) {
      return body.map(sanitizeBody).toList();
    } else if (body is String) {
      // For form data or string bodies, check if it contains sensitive patterns
      return _containsSensitiveData(body) ? _redactedValue : body;
    }

    // For other types (numbers, bools, etc.), return as-is
    return body;
  }

  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    return map.map((key, value) {
      final isRedacted = _sensitiveBodyFields.contains(key.toLowerCase());

      if (isRedacted) {
        return MapEntry(key, _redactedValue);
      }

      // Recursively sanitize nested objects
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeMap(value));
      } else if (value is List) {
        return MapEntry(key, value.map(sanitizeBody).toList());
      }

      return MapEntry(key, value);
    });
  }

  static bool _containsSensitiveData(String value) {
    final lowerValue = value.toLowerCase();
    return _sensitiveBodyFields.any(lowerValue.contains);
  }
}
