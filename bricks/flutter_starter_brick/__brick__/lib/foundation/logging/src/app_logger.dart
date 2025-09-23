import 'package:flutter/foundation.dart';

/// The AppLogger class provides a simple logging mechanism for the application.
class AppLogger {
  const AppLogger();

  /// Logs a message.
  void log(
    String message, {
    String? tag,
    StackTrace? stackTrace,
    bool prependDateTime = true,
  }) {
    final sb = StringBuffer();

    if (prependDateTime) {
      sb.write('[${DateTime.now().toIso8601String()}] ');
    }

    if (tag != null) {
      sb.write('[$tag] ');
    }

    sb.write(message);

    // Using debugPrint for proper console output in debug mode
    if (kDebugMode) {
      debugPrint(sb.toString());

      // Print stack trace if provided
      if (stackTrace != null) {
        final stackSb = StringBuffer();
        if (prependDateTime) {
          stackSb.write('[${DateTime.now().toIso8601String()}] ');
        }
        if (tag != null) {
          stackSb.write('[$tag] ');
        }
        stackSb.write('Stack trace:\n$stackTrace');
        debugPrint(stackSb.toString());
      }
    }
  }
}
