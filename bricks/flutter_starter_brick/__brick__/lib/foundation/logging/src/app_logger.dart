import 'package:flutter/foundation.dart';

/// The AppLogger class provides a simple logging mechanism for the application.
class AppLogger {
  const AppLogger();

  /// Logs a message under [tag], which names the calling class or file so the
  /// caller stays searchable. Call sites pass a bare message; the line
  /// (timestamp, tag, message, stack as a second line) is composed here.
  void log(String message, {required String tag, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] [$tag] $message');

      if (stackTrace != null) {
        debugPrint('[$timestamp] [$tag] Stack trace:\n$stackTrace');
      }
    }
  }
}
