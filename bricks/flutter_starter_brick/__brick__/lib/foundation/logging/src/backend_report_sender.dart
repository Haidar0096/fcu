import 'package:{{proj_name}}/foundation/logging/src/error_report_dto.dart';
import 'package:{{proj_name}}/foundation/logging/src/parked_report_store.dart';
import 'package:{{proj_name}}/foundation/logging/src/report_sender.dart';
import 'package:{{proj_name}}/foundation/networking/networking.dart';

/// Hands back the app's own HTTP client at the moment a report goes out.
///
/// The client reports its own failures through `ErrorLogger`, and
/// `ErrorLogger` hands its reports to this sender, so taking the client as a
/// plain constructor value closes a circle the container cannot resolve:
/// `ErrorLogger` needs the sender, the sender needs the client, the client
/// needs `ErrorLogger`. Resolving the client on first use — after every one
/// of the three exists — is what keeps the circle open. It changes nothing
/// about WHICH client the sender rides; that stays the dependency injection
/// file's one line.
typedef OnResolveHttpClientCallback = HttpClient Function();

/// The sender that ships by default: it posts every report to the project's
/// OWN receiver endpoint, through the app's own HTTP client — never a raw
/// transport call, and never a bought service.
final class BackendReportSender implements ReportSender {
  BackendReportSender({
    required OnResolveHttpClientCallback resolveHttpClient,
    required ParkedReportStore parkedReports,
    required String receiverPath,
  }) : _resolveHttpClient = resolveHttpClient,
       _parkedReports = parkedReports,
       _receiverPath = receiverPath;

  final OnResolveHttpClientCallback _resolveHttpClient;
  final ParkedReportStore _parkedReports;
  final String _receiverPath;

  @override
  Future<void> send(ErrorReportDto report) => _post(report.toJson());

  @override
  Future<void> sendParkedReports() async {
    try {
      final parked = await _parkedReports.takeAll();
      for (final report in parked) {
        await _post(report);
      }
    } catch (_) {
      // The drain never throws into the launch and never reports its own
      // failure: an unreadable store simply waits for the next launch.
    }
  }

  Future<void> _post(Map<String, dynamic> report) async {
    try {
      // No receiver address yet. The report waits on the device rather than
      // being posted at whatever the base URL currently points at — the
      // starter names no address it was not given.
      if (_receiverPath.isEmpty) {
        await _park(report);
        return;
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
        await _park(report);
      }
    } catch (_) {
      // Nothing may escape the sender into the caller's error road.
      await _park(report);
    }
  }

  Future<void> _park(Map<String, dynamic> report) async {
    try {
      await _parkedReports.park(report);
    } catch (_) {
      // Parking is already the fallback, and reporting this failure would
      // re-enter the road that just failed.
    }
  }
}
