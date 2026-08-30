import 'package:{{proj_name}}/foundation/logging/src/app_logger.dart';
import 'package:{{proj_name}}/foundation/logging/src/error_report_dto.dart';
import 'package:{{proj_name}}/foundation/logging/src/parked_report_store.dart';
import 'package:{{proj_name}}/foundation/logging/src/report_sender.dart';
import 'package:{{proj_name}}/foundation/networking/networking.dart';

/// Hands back the app's own HTTP client at the moment a report goes out.
///
/// Dependency injection resolves the dedicated report-upload client here.
/// That client is wired with `errorLogger: null` and
/// `reportsFailures: false`, so upload failures reach only the debug logger
/// and never re-enter the report road. The resolver defers construction while
/// the dependency graph is assembled; the dependency injection file remains
/// the one place that chooses WHICH client the sender rides.
typedef OnResolveHttpClientCallback = HttpClient Function();

/// The sender that ships by default: it posts every report to the project's
/// OWN receiver endpoint, through the app's own HTTP client — never a raw
/// transport call, and never a bought service.
final class BackendReportSender implements ReportSender {
  BackendReportSender({
    required OnResolveHttpClientCallback resolveHttpClient,
    required AppLogger appLogger,
    required ParkedReportStore parkedReports,
    required String receiverPath,
  }) : _resolveHttpClient = resolveHttpClient,
       _appLogger = appLogger,
       _parkedReports = parkedReports,
       _receiverPath = receiverPath;

  static const String _tag = 'BackendReportSender';
  final OnResolveHttpClientCallback _resolveHttpClient;
  final AppLogger _appLogger;
  final ParkedReportStore _parkedReports;
  final String _receiverPath;

  @override
  Future<void> send(ErrorReportDto report) async {
    final encodedReport = report.toJson();
    if (!await _post(encodedReport)) {
      await _park(encodedReport);
    }
  }

  /// Delivery is at least once: an accepted report is acknowledged only after
  /// the response. A failed acknowledgement leaves it parked, so the receiver
  /// must tolerate the same report arriving again on a later launch.
  @override
  Future<void> sendParkedReports() async {
    while (true) {
      ({String encoded, Map<String, dynamic> report})? parked;
      try {
        parked = await _parkedReports.peek();
      } catch (error, stackTrace) {
        _logFailure(
          operation: 'Failed to read the next parked report',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }
      if (parked == null) return;

      if (!await _post(parked.report)) return;

      try {
        await _parkedReports.acknowledge(encoded: parked.encoded);
      } catch (error, stackTrace) {
        _logFailure(
          operation: 'Failed to acknowledge an accepted parked report',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }
    }
  }

  Future<bool> _post(Map<String, dynamic> report) async {
    try {
      // No receiver address yet. The report waits on the device rather than
      // being posted at whatever the base URL currently points at — the
      // starter names no address it was not given.
      if (_receiverPath.isEmpty) {
        return false;
      }

      final result = await _resolveHttpClient().post<bool>(
        path: _receiverPath,
        body: report,
        isMultipart: false,
        successResponseMapper: (_) => true,
      );

      final delivered = result.when(
        success: (_) => true,
        failure: (_) => false,
      );

      if (!delivered) {
        _logFailure(
          operation: 'Report upload was not accepted',
          error: StateError('The reporting client returned a failure.'),
          stackTrace: StackTrace.current,
        );
      }
      return delivered;
    } catch (error, stackTrace) {
      // Nothing may escape the sender into the caller's error road.
      _logFailure(
        operation: 'Report upload threw before acceptance',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _park(Map<String, dynamic> report) async {
    try {
      await _parkedReports.park(report);
    } catch (error, stackTrace) {
      _logFailure(
        operation: 'Failed to park an unsent report',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _logFailure({
    required String operation,
    required Object error,
    required StackTrace stackTrace,
  }) => _appLogger.log(
    message: '$operation: $error',
    tag: _tag,
    stackTrace: stackTrace,
  );
}
