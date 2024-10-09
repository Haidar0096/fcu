import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';

/// A singleton class that handles event logging.
@LazySingletonService()
class EventLogger {
  const EventLogger();

  /// Logs the given event into the reporting system.
  Future<void> recordEvent({
    required String message,
    EventLoggerLevel? level,
    StackTrace? stackTrace,
  }) async {
    // TODO(dev): Implement this method to log events in your chosen
    // reporting system.
  }
}

/// The level of an event that will be recorded by the [EventLogger]
enum EventLoggerLevel {
  debug,
  info,
  error,
}
