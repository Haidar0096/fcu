/// A singleton class that handles event logging.
class EventLogger {
  const EventLogger();

  /// Logs the given event into the reporting system.
  Future<void> recordEvent({
    required String message,
    EventLoggerLevel? level,
    StackTrace? stackTrace,
  }) async {
    // TODO({{dev_name}}): Implement this method to log events in your chosen
    // reporting system.
  }
}

/// The level of an event that will be recorded by the [EventLogger]
enum EventLoggerLevel { debug, info, error }
