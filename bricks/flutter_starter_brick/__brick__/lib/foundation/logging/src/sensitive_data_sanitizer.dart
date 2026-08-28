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
  // The shared starter list. Project-specific forbidden fields join this one
  // home when they become known.
  static const Set<String> _forbiddenFieldNames = {
    'password',
    'passcode',
    'pin',
    'token',
    'authorization',
    'cookie',
    'secret',
    'apikey',
    'cardnumber',
    'cvv',
    'nationalid',
    'email',
    'phone',
  };

  static const _redactedValue = '[REDACTED]';

  /// Every forbidden name, longest first so a name that contains a shorter
  /// one is still matched whole.
  static final List<String> _forbiddenNames =
      _forbiddenFieldNames.toList()
        ..sort((a, b) => b.length.compareTo(a.length));

  /// A forbidden field NAME standing as a whole word, the separator after it,
  /// and the value it introduces up to the next delimiter.
  ///
  /// The word boundaries are what keep ordinary text out of it: `mapping`,
  /// `spinner` and the app's own `CancelToken` carry no forbidden name as a
  /// whole word, so none of them is touched. The already-redacted marker is
  /// matched first so running this twice changes nothing.
  static final RegExp _forbiddenAssignment = RegExp(
    '\\b(${_forbiddenNames.map(RegExp.escape).join('|')})\\b'
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
    // No forbidden names means nothing to redact. Without this the alternation
    // is empty, `\b()\b` matches at every word boundary, and the pattern
    // redacts the value of EVERY `name: value` pair in the text.
    if (_forbiddenNames.isEmpty) return text;
    return text.replaceAllMapped(
      _forbiddenAssignment,
      (match) => '${match[1]}${match[2]}$_redactedValue',
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
    final normalizedKey = key.toLowerCase().replaceAll(
      RegExp('[^a-z0-9]'),
      '',
    );
    return _forbiddenFieldNames.any(
      (forbiddenName) =>
          normalizedKey == forbiddenName ||
          normalizedKey.startsWith(forbiddenName) ||
          normalizedKey.endsWith(forbiddenName),
    );
  }
}
