/// The ONE home of the project's forbidden-field list, and the only thing
/// that strips against it.
///
/// It runs twice on two different shapes, and both are in this module on
/// purpose: over request headers, request bodies and response bodies before
/// any log line is composed, and over the outgoing report inside
/// `ErrorLogger` before the sender is called — so no unstripped shape can
/// reach a sender. A second copy of this list anywhere would be a second
/// answer to "what may never leave the device".
///
/// (Named `RequestDataSanitizer` while it only covered requests; the report
/// strip is why it now carries the wider name and lives beside the loggers.)
abstract final class SensitiveDataSanitizer {
  // The project-specific list starts empty. Project setup and later review
  // add only fields recorded for this project; no field is guessed.
  static const Set<String> _forbiddenFieldNames = <String>{};

  static const _redactedValue = '[REDACTED]';

  /// A possible field key, the separator after the key, and the value the key
  /// introduces up to the next delimiter.
  ///
  /// The captured key is normalized through [_isForbiddenKey] before the value
  /// is replaced. This catches camelCase, snake_case and kebab-case compound
  /// keys without treating a forbidden fragment in ordinary prose as a key.
  /// The already-redacted marker is matched first so running this twice changes
  /// nothing.
  static final RegExp _forbiddenAssignment = RegExp(
    r'([A-Za-z][A-Za-z0-9_.-]*)'
    '("?\\s*[:=]\\s*"?)'
    '(${RegExp.escape(_redactedValue)}|[^,;&}\\)\\]"\\n]*)',
    caseSensitive: false,
  );

  /// Sanitizes headers by redacting sensitive values
  static Map<String, dynamic>? sanitizeHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return null;

    return headers.map((key, value) {
      final isRedacted = _isForbiddenKey(key);
      return MapEntry(key, isRedacted ? _redactedValue : value);
    });
  }

  /// Sanitizes a request or response body by redacting sensitive fields
  static dynamic sanitizeBody(dynamic body) {
    if (body == null) return null;

    if (body is Map<String, dynamic>) {
      return _sanitizeMap(body);
    } else if (body is List) {
      return body.map(sanitizeBody).toList();
    } else if (body is String) {
      return sanitizeText(body);
    }

    return body;
  }

  /// Sanitizes one line of free text — a composed failure message, a stack,
  /// a recorded action — on its way into a report.
  ///
  /// What gets redacted is the VALUE a forbidden field name introduces, never
  /// the whole line. Wiping the line instead would defeat the rule the report
  /// exists for: the payload has to match the log line, and two different
  /// failures have to stay distinguishable — a report reading only
  /// `[REDACTED]` is neither.
  static String sanitizeText(String text) {
    // No recorded forbidden names means no assignment should be redacted.
    if (_forbiddenFieldNames.isEmpty) return text;
    return text.replaceAllMapped(
      _forbiddenAssignment,
      (match) => _isForbiddenKey(match[1]!)
          ? '${match[1]}${match[2]}$_redactedValue'
          : match[0]!,
    );
  }

  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    return map.map((key, value) {
      final isRedacted = _isForbiddenKey(key);

      if (isRedacted) {
        return MapEntry(key, _redactedValue);
      }

      if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeMap(value));
      } else if (value is List) {
        return MapEntry(key, value.map(sanitizeBody).toList());
      }

      return MapEntry(key, value);
    });
  }

  static bool _isForbiddenKey(String key) {
    final normalizedKey = _normalizeFieldName(key);
    return _forbiddenFieldNames.any((forbiddenName) {
      final normalizedForbiddenName = _normalizeFieldName(forbiddenName);
      return normalizedForbiddenName.isNotEmpty &&
          (normalizedKey == normalizedForbiddenName ||
              normalizedKey.startsWith(normalizedForbiddenName) ||
              normalizedKey.endsWith(normalizedForbiddenName));
    });
  }

  static String _normalizeFieldName(String name) =>
      name.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
}
