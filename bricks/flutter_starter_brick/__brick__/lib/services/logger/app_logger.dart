import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:flutter/foundation.dart';

/// The AppLogger class provides a simple logging mechanism for the application.
@LazySingletonService()
class AppLogger {
  const AppLogger();

  /// Logs a message.
  void log(
    String message, {
    String? tag,
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

    if (kDebugMode) {
      print(sb);
    }
  }
}
