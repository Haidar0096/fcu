import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:{{proj_name}}/foundation/logging/src/error_report_dto.dart';
import 'package:{{proj_name}}/foundation/logging/src/flow_buffer.dart';
import 'package:{{proj_name}}/foundation/logging/src/report_sender.dart';
import 'package:{{proj_name}}/foundation/logging/src/sensitive_data_sanitizer.dart';

/// Hands back the app's live [ErrorLogger], or null when there is none yet.
///
/// The three global error channels are hooked before dependency injection
/// runs, so the road that reports has to CHECK its tools rather than demand
/// them: a lookup that throws inside an error handler turns a reportable
/// failure into a crash.
typedef OnResolveErrorLoggerCallback = ErrorLogger? Function();

/// The ONE class every report leaves the app through.
///
/// It composes the report, copies the flow list into it, strips it, and
/// hands it to the single sender behind it. No caller ever names a
/// destination, so switching destinations touches one registration line.
///
/// It is not `const`, unlike the two loggers beside it: it holds the sender
/// and the flow buffer. Its fields stay final and both arrive by
/// constructor — never fetched from the locator inside a method.
class ErrorLogger {
  ErrorLogger({
    required ReportSender reportSender,
    required FlowBuffer flowBuffer,
    required String appShortName,
  }) : _reportSender = reportSender,
       _flowBuffer = flowBuffer,
       _appShortName = appShortName;

  final ReportSender _reportSender;
  final FlowBuffer _flowBuffer;

  /// The short name this app puts on every report it sends, so the project's
  /// report table tells this app's reports from every other app's.
  final String _appShortName;

  /// Whether this build sends its reports at all.
  ///
  /// Silent in a DEBUG build and nowhere else. The BUILD KIND is the one
  /// signal: a profile or release build sends its reports to whatever server
  /// it points at, so a teammate's phone pointed at the development server
  /// still reports. The app's environment (development or production) picks
  /// the SERVER and never whether reporting happens — one signal, so nothing
  /// can disagree with anything.
  static bool get _reportingIsSilent => kDebugMode;

  /// Marks the zone the report road runs inside.
  ///
  /// The client the sender rides logs AND reports its own failures, so an
  /// upload that fails would raise a second report, which fails the same way:
  /// an error road that reports its own errors loops. Any failure raised
  /// inside the marked zone is therefore recorded nowhere.
  ///
  /// The marker rides the zone rather than a flag on this object on purpose:
  /// a flag would also drop an UNRELATED failure that happened to arrive
  /// while a report was on the wire, and a report is never thrown away.
  static final Object _reportRoadZoneKey = Object();

  /// Hooks the framework, platform-dispatcher and isolate channels once.
  ///
  /// Static because it runs BEFORE dependency injection can build an
  /// [ErrorLogger]: each channel resolves the live logger through
  /// [resolveErrorLogger] at the moment a failure arrives, and a failure
  /// raised before there is one still reaches the console.
  static void registerErrorHandlers(
    OnResolveErrorLoggerCallback resolveErrorLogger,
  ) {
    FlutterError.onError = (errorDetails) => _handleFlutterError(
      errorDetails: errorDetails,
      resolveErrorLogger: resolveErrorLogger,
    );
    PlatformDispatcher.instance.onError = (error, stackTrace) =>
        _handlePlatformError(
          error: error,
          stackTrace: stackTrace,
          resolveErrorLogger: resolveErrorLogger,
        );
    if (!kIsWeb) {
      _addIsolateErrorListener(resolveErrorLogger);
    }
  }

  static void _handleFlutterError({
    required FlutterErrorDetails errorDetails,
    required OnResolveErrorLoggerCallback resolveErrorLogger,
  }) {
    FlutterError.dumpErrorToConsole(errorDetails);
    unawaited(
      resolveErrorLogger()?.recordError(
        error: errorDetails.exception,
        stackTrace: errorDetails.stack,
      ),
    );
    FlutterError.presentError(errorDetails);
  }

  static bool _handlePlatformError({
    required Object error,
    required StackTrace stackTrace,
    required OnResolveErrorLoggerCallback resolveErrorLogger,
  }) {
    debugPrint('Platform error: $error\n$stackTrace');
    unawaited(
      resolveErrorLogger()?.recordError(error: error, stackTrace: stackTrace),
    );
    return true;
  }

  static void _addIsolateErrorListener(
    OnResolveErrorLoggerCallback resolveErrorLogger,
  ) {
    Isolate.current.addErrorListener(
      RawReceivePort((List<dynamic> errorData) {
        final error = errorData.elementAtOrNull(0);
        final stackTrace = errorData.elementAtOrNull(1) is String
            ? StackTrace.fromString(errorData.elementAtOrNull(1) as String)
            : null;
        debugPrint('Isolate error: $error\n$stackTrace');
        unawaited(
          resolveErrorLogger()?.recordError(
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }).sendPort,
    );
  }

  /// Records the given error into the reporting system.
  ///
  /// [backendCorrelationId] is the id the project's backend echoed on the
  /// response behind this failure; the caller that classified the failure
  /// carries it here. It is never minted on the device, and a failure with
  /// no backend call behind it leaves it null.
  ///
  Future<void> recordError({
    required dynamic error,
    StackTrace? stackTrace,
    String? backendCorrelationId,
  }) => _record(
    value: error,
    level: ErrorReportLevel.error,
    stackTrace: stackTrace,
    backendCorrelationId: backendCorrelationId,
  );

  Future<void> recordInfo({
    required dynamic info,
    StackTrace? stackTrace,
    String? backendCorrelationId,
  }) => _record(
    value: info,
    level: ErrorReportLevel.info,
    stackTrace: stackTrace,
    backendCorrelationId: backendCorrelationId,
  );

  Future<void> _record({
    required dynamic value,
    required ErrorReportLevel level,
    required StackTrace? stackTrace,
    required String? backendCorrelationId,
  }) async {
    // A debug build composes and sends nothing. The console still carries the
    // failure; only the report road is off.
    if (_reportingIsSilent) return;

    // The report road's own failure is not itself reported, so it can never
    // raise a report about failing to send a report.
    if (_isInsideReportRoad) return;

    // THE FIRST STRIP: everything is stripped here, before the sender is
    // called, so no unstripped shape can reach a sender. The backend strips
    // a second time on arrival; the sender is never trusted.
    final report = ErrorReportDto(
      app: _appShortName,
      level: level,
      message: SensitiveDataSanitizer.sanitizeText('$value'),
      stack: SensitiveDataSanitizer.sanitizeText(
        (stackTrace ?? StackTrace.current).toString(),
      ),
      correlationId: backendCorrelationId,
      occurredAt: DateTime.now().toUtc(),
      flow: List<Map<String, dynamic>>.unmodifiable(
        _flowBuffer.actions.map(
          (action) => Map<String, dynamic>.unmodifiable({
            'name': SensitiveDataSanitizer.sanitizeText(action.name),
            'occurredAt': action.occurredAt.toIso8601String(),
          }),
        ),
      ),
    );

    await _runInsideReportRoad(() => _reportSender.send(report));
  }

  /// Sends every report an earlier launch had to park, then clears them.
  ///
  /// The drain rides this class rather than the sender itself for two
  /// reasons: it puts the parked reports on the same guarded road a fresh
  /// report takes, and it keeps the sender's type named in the logging module
  /// and the dependency injection file, nowhere else.
  ///
  /// A debug build drains nothing: silent means nothing leaves this app, a
  /// parked report included. The parked reports simply wait, as they do after
  /// any failed launch — a report is never thrown away.
  Future<void> sendParkedReports() async {
    if (_reportingIsSilent) return;
    await _runInsideReportRoad(_reportSender.sendParkedReports);
  }

  bool get _isInsideReportRoad => Zone.current[_reportRoadZoneKey] == true;

  Future<T> _runInsideReportRoad<T>(Future<T> Function() body) =>
      runZoned(body, zoneValues: {_reportRoadZoneKey: true});
}
