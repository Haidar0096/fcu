import 'package:flutter/foundation.dart';

class AppLogger {
  void log({
    String? runtimeType,
    String? callerName,
    required String message,
    StackTrace? stackTrace,
    bool prependDateTime = true,
  }) =>
      _logMessage(
        runtimeType: runtimeType,
        callerName: callerName,
        logMessage: message,
        stackTrace: stackTrace,
        prependDateTime: prependDateTime,
      );

  /// Logs a message using the given logger.
  /// - [logMessage] is the message to log.
  /// - [runtimeType] is the runtime type of the class that is calling this
  ///   function.
  /// - [callerName] is the name of the function that is calling this function.
  /// - [error] is the error object to log, if any.
  /// - [stackTrace] is the stack trace to log, if any.
  /// - [prependDateTime] indicates whether the current date and time should be
  ///   prepended to the log message.
  void _logMessage({
    String? runtimeType,
    String? callerName,
    required String logMessage,
    Object? error,
    StackTrace? stackTrace,
    bool prependDateTime = true,
  }) {
    final StringBuffer sb = StringBuffer();
    if (prependDateTime) {
      sb.write('[${DateTime.now().toIso8601String()}] ');
    }

    if (runtimeType != null || callerName != null) {
      sb.write('[');
      if (runtimeType != null) {
        sb.write(runtimeType);
        if (callerName != null) {
          sb.write('#');
        }
      }
      if (callerName != null) {
        sb.write(callerName);
      }
      sb.write('] ');
    }

    sb.writeln(logMessage);

    if (error != null) {
      sb.writeln('Error: $error');
    }

    if (stackTrace != null) {
      sb.writeln('StackTrace: $stackTrace');
    }

    if (kDebugMode) {
      print(sb.toString());
    }
  }
}
