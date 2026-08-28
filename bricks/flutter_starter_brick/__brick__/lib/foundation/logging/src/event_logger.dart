import 'package:flutter/foundation.dart';
import 'package:{{proj_name}}/foundation/logging/src/sensitive_data_sanitizer.dart';

class EventLogger {
  const EventLogger();

  static const String _tag = 'EventLogger';

  void recordEvent({
    required String message,
    required EventLoggerLevel level,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String();
    final sanitizedMessage = SensitiveDataSanitizer.sanitizeText(message);
    debugPrint('[$timestamp] [${level.name}] [$_tag] $sanitizedMessage');

    if (stackTrace != null) {
      final sanitizedStack = SensitiveDataSanitizer.sanitizeText(
        stackTrace.toString(),
      );
      debugPrint('[$timestamp] [${level.name}] [$_tag] $sanitizedStack');
    }
  }
}

enum EventLoggerLevel { debug, info, error }
