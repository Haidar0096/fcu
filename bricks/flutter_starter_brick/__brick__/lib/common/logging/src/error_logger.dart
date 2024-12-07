import 'dart:isolate';

import 'package:{{proj_name}}/common/dependency_injection/dependency_injection.dart';
import 'package:flutter/foundation.dart';

/// A singleton class that handles error logging and reporting.
@LazySingletonService()
class ErrorLogger {
  const ErrorLogger();

  /// Registers the error handlers.
  void registerErrorHandlers() {
    FlutterError.onError = _handleFlutterError;
    PlatformDispatcher.instance.onError = _handlePlatformError;
    _addIsolateErrorListener();
  }

  Future<void> _handleFlutterError(FlutterErrorDetails errorDetails) async {
    await recordError(
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
    );
    FlutterError.presentError(errorDetails);
  }

  bool _handlePlatformError(Object error, StackTrace stack) {
    recordError(
      error: error,
      stackTrace: stack,
    );
    return true;
  }

  void _addIsolateErrorListener() {
    Isolate.current.addErrorListener(
      RawReceivePort((List<dynamic> errorData) {
        final error = errorData.elementAtOrNull(0);
        final stackTrace = errorData.elementAtOrNull(1) is String
            ? StackTrace.fromString(errorData.elementAtOrNull(1) as String)
            : null;
        recordError(error: error, stackTrace: stackTrace);
      }).sendPort,
    );
  }

  /// Records the given error into error reporting system.
  Future<void> recordError({
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    // TODO({{dev_name}}): Implement this method to record errors in your chosen
    // error reporting system.
  }
}
