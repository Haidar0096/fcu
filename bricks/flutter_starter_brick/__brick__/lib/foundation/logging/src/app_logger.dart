import 'package:flutter/foundation.dart';
import 'package:{{proj_name}}/foundation/logging/src/sensitive_data_sanitizer.dart';

class AppLogger {
  const AppLogger();

  /// Logs a message under [tag], which names the calling class or file so the
  /// caller stays searchable. Call sites pass a bare message; the line
  /// (timestamp, tag, message, stack as a second line) is composed here.
  void log({
    required String message,
    required String tag,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final sanitizedMessage = SensitiveDataSanitizer.sanitizeText(message);
      debugPrint('[$timestamp] [$tag] $sanitizedMessage');

      if (stackTrace != null) {
        final sanitizedStack = SensitiveDataSanitizer.sanitizeText(
          stackTrace.toString(),
        );
        debugPrint('[$timestamp] [$tag] Stack trace:\n$sanitizedStack');
      }
    }
  }
}
